# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groove::Search do
  let(:sample_file) { File.join(__dir__, '..', '..', 'examples', 'sample_songs.csv') }
  let(:test_tokens_path) { File.join(Dir.tmpdir, 'groove_test', 'tokens.json') }

  before do
    # Stub Configuration to use test credentials so tests don't use user's real tokens
    allow(Groove::Configuration).to receive(:new).and_return(TestConfiguration.new)
  end

  describe '#song' do
    it 'requires authentication' do
      expect do
        subject.song('Artist', 'Song')
      rescue SystemExit => e
        expect(e.status).to eq(1)
        raise
      end.to raise_error(SystemExit).and output(/Not authenticated/).to_stdout
    end
  end

  describe '#file' do
    it 'requires authentication' do
      expect do
        subject.file(sample_file)
      rescue SystemExit => e
        expect(e.status).to eq(1)
        raise
      end.to raise_error(SystemExit).and output(/Not authenticated/).to_stdout
    end

    it 'handles non-existent file' do
      expect do
        subject.file('nonexistent.txt')
      rescue SystemExit => e
        expect(e.status).to eq(1)
        raise
      end.to raise_error(SystemExit).and output(/File not found/).to_stdout
    end
  end

  describe '#stats' do
    it 'requires authentication' do
      expect do
        subject.stats
      rescue SystemExit => e
        expect(e.status).to eq(1)
        raise
      end.to raise_error(SystemExit).and output(/Not authenticated/).to_stdout
    end
  end
end
