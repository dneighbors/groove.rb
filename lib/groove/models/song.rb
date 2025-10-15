# frozen_string_literal: true

module Groove
  module Models
    # Represents a song with artist and title information
    class Song
      attr_reader :artist, :title, :confidence, :spotify_id, :metadata

      def initialize(artist:, title:, confidence: 1.0, spotify_id: nil, metadata: {})
        @artist = artist.to_s.strip
        @title = title.to_s.strip
        @confidence = confidence.to_f
        @spotify_id = spotify_id
        @metadata = metadata.dup.freeze
      end

      def to_s
        "#{artist} - #{title}"
      end

      def ==(other)
        other.is_a?(Song) &&
          artist.downcase == other.artist.downcase &&
          title.downcase == other.title.downcase
      end

      def hash
        [artist.downcase, title.downcase].hash
      end

      def eql?(other)
        self == other
      end

      def valid?
        !artist.empty? && !title.empty?
      end

      def to_hash
        {
          artist: artist,
          title: title,
          confidence: confidence,
          spotify_id: spotify_id,
          metadata: metadata
        }
      end

      def self.from_hash(hash)
        new(
          artist: hash[:artist] || hash['artist'],
          title: hash[:title] || hash['title'],
          confidence: hash[:confidence] || hash['confidence'] || 1.0,
          spotify_id: hash[:spotify_id] || hash['spotify_id'],
          metadata: hash[:metadata] || hash['metadata'] || {}
        )
      end
    end
  end
end
