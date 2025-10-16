# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groove::Parse do
  let(:sample_dir) { File.join(__dir__, '..', '..', 'examples') }
  let(:csv_file) { File.join(sample_dir, 'sample_songs.csv') }
  let(:txt_file) { File.join(sample_dir, 'sample_songs.txt') }
  let(:json_file) { File.join(sample_dir, 'sample_songs.json') }

  describe '#file' do
    it 'parses a CSV file successfully' do
      expect { subject.file(csv_file) }.to output(/Successfully parsed 5 songs/).to_stdout
    end

    it 'parses a TXT file successfully' do
      expect { subject.file(txt_file) }.to output(/Successfully parsed 5 songs/).to_stdout
    end

    it 'parses a JSON file successfully' do
      expect { subject.file(json_file) }.to output(/Successfully parsed 5 songs/).to_stdout
    end

    it 'handles non-existent file' do
      expect do
        subject.file('nonexistent.txt')
      rescue SystemExit => e
        expect(e.status).to eq(1)
        raise
      end.to raise_error(SystemExit).and output(/Failed to parse nonexistent.txt/).to_stdout
    end
  end

  describe '#files' do
    it 'parses multiple files successfully' do
      files = [csv_file, txt_file, json_file]
      expect { subject.files(*files) }.to output(/Successfully parsed 15 songs from 3 files/).to_stdout
    end

    it 'handles empty file list' do
      expect do
        subject.files
      rescue SystemExit => e
        expect(e.status).to eq(1)
        raise
      end.to raise_error(SystemExit).and output(/Please provide at least one file path/).to_stdout
    end

    it 'handles mixed valid and invalid files' do
      files = [csv_file, 'nonexistent.txt']
      expect do
        subject.files(*files)
      rescue SystemExit => e
        expect(e.status).to eq(1)
        raise
      end.to raise_error(SystemExit).and output(/Failed to parse files/).to_stdout
    end
  end

  describe '#validate' do
    it 'validates CSV file' do
      expect { subject.validate(csv_file) }.to output(/File format detected: CSV/).to_stdout
    end

    it 'validates TXT file' do
      expect { subject.validate(txt_file) }.to output(/File format detected: TXT/).to_stdout
    end

    it 'validates JSON file' do
      expect { subject.validate(json_file) }.to output(/File format detected: JSON/).to_stdout
    end

    it 'handles non-existent file' do
      expect do
        subject.validate('nonexistent.txt')
      rescue SystemExit => e
        expect(e.status).to eq(1)
        raise
      end.to raise_error(SystemExit).and output(/File not found: nonexistent.txt/).to_stdout
    end
  end
end
