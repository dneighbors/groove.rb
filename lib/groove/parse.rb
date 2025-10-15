# frozen_string_literal: true

require "thor"
require "groove"

module Groove
  class Parse < Thor
    desc "file FILE_PATH", "Parse a single file containing songs"
    def file(file_path)
      parser = Groove::FileParser.new
      result = parser.parse_file(file_path)
      
      if result.results[:success]
        say "✅ Successfully parsed #{result.results[:total_songs]} songs from #{file_path}"
        
        if result.results[:warnings].any?
          say "\n⚠️  Warnings:"
          result.results[:warnings].each { |warning| say "  - #{warning}" }
        end
        
        if result.results[:songs].any?
          say "\n📝 Songs found:"
          result.results[:songs].each { |song| say "  - #{song}" }
        end
      else
        say "❌ Failed to parse #{file_path}"
        result.results[:errors].each { |error| say "  - #{error}" }
        exit 1
      end
    end

    desc "files FILE_PATHS", "Parse multiple files containing songs"
    def files(*file_paths)
      if file_paths.empty?
        say "❌ Please provide at least one file path"
        exit 1
      end

      parser = Groove::FileParser.new
      result = parser.parse_files(file_paths)
      
      if result.results[:success]
        say "✅ Successfully parsed #{result.results[:total_songs]} songs from #{file_paths.length} files"
        
        if result.results[:warnings].any?
          say "\n⚠️  Warnings:"
          result.results[:warnings].each { |warning| say "  - #{warning}" }
        end
        
        if result.results[:songs].any?
          say "\n📝 Songs found:"
          result.results[:songs].each { |song| say "  - #{song}" }
        end
      else
        say "❌ Failed to parse files"
        result.results[:errors].each { |error| say "  - #{error}" }
        exit 1
      end
    end

    desc "validate FILE_PATH", "Validate file format without parsing songs"
    def validate(file_path)
      unless File.exist?(file_path)
        say "❌ File not found: #{file_path}"
        exit 1
      end

      begin
        content = File.read(file_path)
        parser = Groove::FileParser.new
        format = parser.send(:detect_format, file_path, content)
        
        say "✅ File format detected: #{format.upcase}"
        say "📁 File: #{file_path}"
        say "📊 Size: #{File.size(file_path)} bytes"
        say "📝 Lines: #{content.lines.count}"
        
        if format == 'csv'
          begin
            csv = CSV.parse(content, headers: true)
            say "📋 CSV Headers: #{csv.headers.join(', ')}"
            say "📋 CSV Rows: #{csv.count}"
          rescue CSV::MalformedCSVError => e
            say "⚠️  CSV validation warning: #{e.message}"
          end
        elsif format == 'json'
          begin
            data = JSON.parse(content)
            say "📋 JSON Structure: #{data.class}"
            if data.is_a?(Hash)
              say "📋 JSON Keys: #{data.keys.join(', ')}"
            elsif data.is_a?(Array)
              say "📋 JSON Array Length: #{data.length}"
            end
          rescue JSON::ParserError => e
            say "⚠️  JSON validation warning: #{e.message}"
          end
        end
        
      rescue StandardError => e
        say "❌ Error validating file: #{e.message}"
        exit 1
      end
    end
  end
end
