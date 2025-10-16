# frozen_string_literal: true

require 'csv'
require 'json'
require 'fileutils'

module Groove
  # Handles parsing of various file formats containing song/artist information
  class FileParser
    class Error < Groove::Error; end
    class FileNotFoundError < Error; end
    class InvalidFormatError < Error; end
    class EncodingError < Error; end
    class ValidationError < Error; end

    SUPPORTED_FORMATS = %w[csv txt json].freeze
    ENCODINGS = %w[UTF-8 UTF-16 UTF-32 ASCII].freeze

    attr_reader :songs, :errors, :warnings

    def initialize
      @songs = []
      @errors = []
      @warnings = []
    end

    # Parse a single file
    def parse_file(file_path)
      reset_state
      parse_file_internal(file_path)
      self
    end

    # Internal method to parse a file without resetting state
    def parse_file_internal(file_path)
      unless File.exist?(file_path)
        @errors << "File not found: #{file_path}"
        return
      end

      begin
        content = read_file_content(file_path)
        format = detect_format(file_path, content)

        case format
        when 'csv'
          parse_csv_content(content)
        when 'txt'
          parse_txt_content(content)
        when 'json'
          parse_json_content(content)
        else
          @errors << "Unsupported file format: #{format}"
        end
      rescue StandardError => e
        @errors << "Error parsing file: #{e.message}"
      end
    end

    # Parse multiple files
    def parse_files(file_paths)
      reset_state

      file_paths.each do |file_path|
        parse_file_internal(file_path)
      end

      self
    end

    # Get parsing results
    def results
      {
        songs: @songs,
        errors: @errors,
        warnings: @warnings,
        success: @errors.empty?,
        total_songs: @songs.length
      }
    end

    private

    def reset_state
      @songs = []
      @errors = []
      @warnings = []
    end

    def read_file_content(file_path)
      # Try different encodings
      ENCODINGS.each do |encoding|
        return File.read(file_path, encoding: encoding)
      rescue Encoding::InvalidByteSequenceError, ArgumentError
        next
      end

      # Fallback to binary read and force UTF-8
      begin
        content = File.read(file_path, mode: 'rb')
        content.force_encoding('UTF-8')

        unless content.valid_encoding?
          content.encode!('UTF-8', 'UTF-8', invalid: :replace, undef: :replace)
          @warnings << "File encoding issues detected and corrected for: #{file_path}"
        end

        content
      rescue StandardError => e
        @warnings << "Could not read file #{file_path}: #{e.message}"
        ''
      end
    end

    def detect_format(file_path, content)
      extension = File.extname(file_path).downcase[1..]

      # Check file extension first
      return extension if SUPPORTED_FORMATS.include?(extension)

      # Detect by content
      content_stripped = content.strip
      if content_stripped.start_with?('{', '[')
        'json'
      elsif content.include?(',') && content.lines.first&.include?(',')
        'csv'
      else
        'txt'
      end
    end

    def parse_csv_content(content)
      csv = CSV.parse(content, headers: true, liberal_parsing: true)

      csv.each_with_index do |row, index|
        artist = row['artist'] || row['Artist'] || row[0]
        title = row['song'] || row['Song'] || row['title'] || row['Title'] || row[1]

        if artist && title
          song = Models::Song.new(artist: artist, title: title)
          if song.valid?
            @songs << song
          else
            @warnings << "Invalid song data at row #{index + 2}: #{song}"
          end
        else
          @warnings << "Missing artist or title at row #{index + 2}: #{row.to_h}"
        end
      end
    rescue CSV::MalformedCSVError => e
      @errors << "CSV parsing error: #{e.message}"
      # Try to parse as simple CSV without headers
      begin
        simple_csv = CSV.parse(content, headers: false)
        simple_csv.each_with_index do |row, index|
          next if row.length < 2

          artist = row[0]
          title = row[1]

          if artist && title
            song = Models::Song.new(artist: artist, title: title)
            if song.valid?
              @songs << song
            else
              @warnings << "Invalid song data at row #{index + 1}: #{song}"
            end
          else
            @warnings << "Missing artist or title at row #{index + 1}"
          end
        end
      rescue CSV::MalformedCSVError
        @warnings << 'Could not parse CSV content'
      end
    end

    def parse_txt_content(content)
      content.lines.each_with_index do |line, index|
        line = line.strip
        next if line.empty? || line.start_with?('#')

        # Try different separators
        if line.include?(' - ')
          parts = line.split(' - ', 2)
        elsif line.include?(' | ')
          parts = line.split(' | ', 2)
        elsif line.include?("\t")
          parts = line.split("\t", 2)
        else
          @warnings << "Could not parse line #{index + 1}: #{line}"
          next
        end

        if parts.length == 2
          artist, title = parts.map(&:strip)
          song = Models::Song.new(artist: artist, title: title)
          if song.valid?
            @songs << song
          else
            @warnings << "Invalid song data at line #{index + 1}: #{song}"
          end
        else
          @warnings << "Could not parse line #{index + 1}: #{line}"
        end
      end
    end

    def parse_json_content(content)
      data = JSON.parse(content)

      # Handle different JSON structures
      songs_data = case data
                   when Array
                     data
                   when Hash
                     data['songs'] || data['tracks'] || data['playlist'] || [data]
                   else
                     []
                   end

      songs_data.each_with_index do |song_data, index|
        if song_data.is_a?(Hash)
          artist = song_data['artist'] || song_data['Artist'] || song_data['name']
          title = song_data['title'] || song_data['Title'] || song_data['song'] || song_data['Song']

          if artist && title
            song = Models::Song.new(
              artist: artist,
              title: title,
              spotify_id: song_data['spotify_id'] || song_data['id'],
              metadata: song_data.except('artist', 'Artist', 'title', 'Title', 'song', 'Song', 'spotify_id', 'id')
            )
            if song.valid?
              @songs << song
            else
              @warnings << "Invalid song data at index #{index}: #{song}"
            end
          else
            @warnings << "Missing artist or title at index #{index}"
          end
        else
          @warnings << "Invalid song data format at index #{index}"
        end
      end
    rescue JSON::ParserError => e
      @errors << "JSON parsing error: #{e.message}"
    end
  end
end
