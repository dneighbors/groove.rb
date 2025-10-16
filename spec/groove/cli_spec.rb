# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groove::CLI do
  describe '#version' do
    it 'displays the version' do
      expect { subject.version }.to output("Groove v#{Groove::VERSION}\n").to_stdout
    end
  end

  describe '#help' do
    it 'displays help information' do
      expect { subject.help }.to output(/Groove - Sync text lists to Spotify playlists/).to_stdout
    end
  end
end

RSpec.describe Groove::Auth do
  let(:config) { TestConfiguration.new }

  before do
    allow(Groove::Configuration).to receive(:new).and_return(config)
  end

  describe '#login' do
    it 'calls authentication login method' do
      auth_instance = double('Authentication')
      allow(Groove::Authentication).to receive(:new).with(config).and_return(auth_instance)
      allow(auth_instance).to receive(:login)

      expect { subject.login }.not_to raise_error
    end

    it 'handles authentication errors' do
      auth_instance = double('Authentication')
      allow(Groove::Authentication).to receive(:new).with(config).and_return(auth_instance)
      allow(auth_instance).to receive(:login).and_raise(Groove::Authentication::Error, 'Test error')

      expect do
        subject.login
      rescue SystemExit => e
        expect(e.status).to eq(1)
      end.to output(/Authentication failed/).to_stdout
    end
  end

  describe '#logout' do
    it 'calls authentication logout method' do
      auth_instance = double('Authentication')
      allow(Groove::Authentication).to receive(:new).with(config).and_return(auth_instance)
      allow(auth_instance).to receive(:logout)

      expect { subject.logout }.not_to raise_error
    end
  end

  describe '#status' do
    it 'calls authentication status method' do
      auth_instance = double('Authentication')
      allow(Groove::Authentication).to receive(:new).with(config).and_return(auth_instance)
      allow(auth_instance).to receive(:status)

      expect { subject.status }.not_to raise_error
    end
  end
end
