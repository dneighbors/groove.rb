# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groove::Search do
  let(:sample_file) { File.join(__dir__, '..', '..', 'examples', 'sample_songs.csv') }

  describe '#song' do
    it 'requires authentication' do
      expect { subject.song('Artist', 'Song') }.to output(/Not authenticated/).to_stdout
    end
  end

  describe '#file' do
    it 'requires authentication' do
      expect { subject.file(sample_file) }.to output(/Not authenticated/).to_stdout
    end

    it 'handles non-existent file' do
      expect { subject.file('nonexistent.txt') }.to output(/File not found/).to_stdout
    end
  end

  describe '#stats' do
    it 'requires authentication' do
      expect { subject.stats }.to output(/Not authenticated/).to_stdout
    end
  end
end
