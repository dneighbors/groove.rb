# frozen_string_literal: true

module Groove
  module Models
    # Represents an artist with name and optional metadata
    class Artist
      attr_reader :name, :spotify_id, :metadata

      def initialize(name:, spotify_id: nil, metadata: {})
        @name = name.to_s.strip
        @spotify_id = spotify_id
        @metadata = metadata.dup.freeze
      end

      def to_s
        name
      end

      def ==(other)
        other.is_a?(Artist) && name.downcase == other.name.downcase
      end

      def hash
        name.downcase.hash
      end

      def eql?(other)
        self == other
      end

      def valid?
        !name.empty?
      end

      def to_hash
        {
          name: name,
          spotify_id: spotify_id,
          metadata: metadata
        }
      end

      def self.from_hash(hash)
        new(
          name: hash[:name] || hash['name'],
          spotify_id: hash[:spotify_id] || hash['spotify_id'],
          metadata: hash[:metadata] || hash['metadata'] || {}
        )
      end
    end
  end
end
