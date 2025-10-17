# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

RSpec.describe Groove::FileParser do
  let(:parser) { described_class.new }
  let(:sample_dir) { File.join(__dir__, '..', '..', 'examples') }

  describe '#parse_file' do
    context 'with CSV file' do
      let(:csv_file) { File.join(sample_dir, 'sample_songs.csv') }

      it 'parses CSV file successfully' do
        result = parser.parse_file(csv_file)

        expect(result.results[:success]).to be true
        expect(result.results[:total_songs]).to eq(5)
        expect(result.results[:errors]).to be_empty

        songs = result.results[:songs]
        expect(songs.first.artist).to eq('The Beatles')
        expect(songs.first.title).to eq('Hey Jude')
        expect(songs.last.artist).to eq('The Rolling Stones')
        expect(songs.last.title).to eq('Satisfaction')
      end
    end

    context 'with TXT file' do
      let(:txt_file) { File.join(sample_dir, 'sample_songs.txt') }

      it 'parses TXT file successfully' do
        result = parser.parse_file(txt_file)

        expect(result.results[:success]).to be true
        expect(result.results[:total_songs]).to eq(5)
        expect(result.results[:errors]).to be_empty

        songs = result.results[:songs]
        expect(songs.first.artist).to eq('The Beatles')
        expect(songs.first.title).to eq('Hey Jude')
      end

      it 'parses TXT file with en dash separator (–)' do
        temp_file = Tempfile.new(['songs_en_dash', '.txt'])
        temp_file.write("Anderson .Paak – Come Down\n")
        temp_file.write("Silk Sonic – Fly as Me\n")
        temp_file.write("Bruno Mars – Versace on the Floor\n")
        temp_file.close

        result = parser.parse_file(temp_file.path)

        expect(result.results[:success]).to be true
        expect(result.results[:total_songs]).to eq(3)
        expect(result.results[:errors]).to be_empty

        songs = result.results[:songs]
        expect(songs[0].artist).to eq('Anderson .Paak')
        expect(songs[0].title).to eq('Come Down')
        expect(songs[1].artist).to eq('Silk Sonic')
        expect(songs[1].title).to eq('Fly as Me')

        temp_file.unlink
      end

      it 'parses TXT file with em dash separator (—)' do
        temp_file = Tempfile.new(['songs_em_dash', '.txt'])
        temp_file.write("The Beatles — Hey Jude\n")
        temp_file.write("Queen — Bohemian Rhapsody\n")
        temp_file.close

        result = parser.parse_file(temp_file.path)

        expect(result.results[:success]).to be true
        expect(result.results[:total_songs]).to eq(2)

        songs = result.results[:songs]
        expect(songs[0].artist).to eq('The Beatles')
        expect(songs[0].title).to eq('Hey Jude')

        temp_file.unlink
      end
    end

    context 'with JSON file' do
      let(:json_file) { File.join(sample_dir, 'sample_songs.json') }

      it 'parses JSON file successfully' do
        result = parser.parse_file(json_file)

        expect(result.results[:success]).to be true
        expect(result.results[:total_songs]).to eq(5)
        expect(result.results[:errors]).to be_empty

        songs = result.results[:songs]
        expect(songs.first.artist).to eq('The Beatles')
        expect(songs.first.title).to eq('Hey Jude')
        expect(songs.first.spotify_id).to eq('0mJiKSvD8P4WwYyieWXoGu')
      end
    end

    context 'with non-existent file' do
      it 'returns error for missing file' do
        result = parser.parse_file('nonexistent.txt')

        expect(result.results[:success]).to be false
        expect(result.results[:errors]).to include('File not found: nonexistent.txt')
        expect(result.results[:total_songs]).to eq(0)
      end
    end

    context 'with invalid CSV' do
      let(:temp_file) { Tempfile.new(['test', '.csv']) }

      before do
        temp_file.write("artist,song\n,missing_title\ninvalid_artist,\n")
        temp_file.close
      end

      after do
        temp_file.unlink
      end

      it 'handles malformed CSV gracefully' do
        result = parser.parse_file(temp_file.path)

        expect(result.results[:success]).to be true
        expect(result.results[:warnings]).not_to be_empty
      end
    end

    context 'with invalid JSON' do
      let(:temp_file) { Tempfile.new(['test', '.json']) }

      before do
        temp_file.write('{"invalid": json content}')
        temp_file.close
      end

      after do
        temp_file.unlink
      end

      it 'returns error for malformed JSON' do
        result = parser.parse_file(temp_file.path)

        expect(result.results[:success]).to be false
        expect(result.results[:errors]).not_to be_empty
      end
    end
  end

  describe '#parse_files' do
    let(:files) do
      [
        File.join(sample_dir, 'sample_songs.csv'),
        File.join(sample_dir, 'sample_songs.txt'),
        File.join(sample_dir, 'sample_songs.json')
      ]
    end

    it 'parses multiple files successfully' do
      result = parser.parse_files(files)

      expect(result.results[:success]).to be true
      expect(result.results[:total_songs]).to eq(15) # 5 songs × 3 files
      expect(result.results[:errors]).to be_empty
    end

    it 'handles mixed valid and invalid files' do
      mixed_files = files + ['nonexistent.txt']
      result = parser.parse_files(mixed_files)

      expect(result.results[:success]).to be false
      expect(result.results[:total_songs]).to eq(15)
      expect(result.results[:errors]).to include('File not found: nonexistent.txt')
    end
  end

  describe 'format detection' do
    it 'detects CSV format by extension' do
      temp_file = Tempfile.new(['test', '.csv'])
      temp_file.write('artist,song')
      temp_file.close

      content = File.read(temp_file.path)
      format = parser.send(:detect_format, temp_file.path, content)

      expect(format).to eq('csv')

      temp_file.unlink
    end

    it 'detects JSON format by content' do
      temp_file = Tempfile.new(['test', '.unknown'])
      temp_file.write('{"songs": []}')
      temp_file.close

      content = File.read(temp_file.path)
      format = parser.send(:detect_format, temp_file.path, content)

      expect(format).to eq('json')

      temp_file.unlink
    end

    it 'defaults to TXT format' do
      temp_file = Tempfile.new(['test', '.txt'])
      temp_file.write('Artist - Song')
      temp_file.close

      content = File.read(temp_file.path)
      format = parser.send(:detect_format, temp_file.path, content)

      expect(format).to eq('txt')

      temp_file.unlink
    end
  end

  describe 'error handling' do
    it 'handles encoding issues gracefully' do
      temp_file = Tempfile.new(['test', '.txt'])
      # Write binary data that will cause encoding issues
      temp_file.write("\xFF\xFE\x00\x00")
      temp_file.close

      result = parser.parse_file(temp_file.path)

      # Should either have warnings or errors, but should not crash
      expect(result.results[:warnings].any? || result.results[:errors].any?).to be true

      temp_file.unlink
    end
  end
end
