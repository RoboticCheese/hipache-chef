# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/hipache_helpers'

describe Hipache::Helpers do
  let(:test_object) { Class.new { include Hipache::Helpers }.new }

  describe 'VALID_OPTIONS' do
    it 'sets up a hash of recognized Hipache options' do
      expect(described_class::VALID_OPTIONS).to be_an_instance_of(Hash)
    end
  end

  describe '#init_system' do
    let(:platform) { nil }
    let(:node) { { 'platform' => platform } }

    before(:each) do
      allow_any_instance_of(test_object.class).to receive(:node)
        .and_return(node)
    end

    context 'a Ubuntu system' do
      let(:platform) { 'ubuntu' }

      it 'returns :upstart' do
        expect(test_object.init_system).to eq(:upstart)
      end
    end

    context 'an unsupported platform' do
      let(:platform) { 'centos' }

      it 'raises an error' do
        expected = Hipache::Exceptions::UnsupportedPlatform
        expect { test_object.init_system }.to raise_error(expected)
      end
    end
  end

  describe '#app_name' do
    it 'returns "hipache"' do
      expect(test_object.app_name).to eq('hipache')
    end
  end

  describe '#valid_version?' do
    let(:version) { nil }
    let(:res) { test_object.valid_version?(version) }

    context 'a valid version string' do
      let(:version) { '1.2.3' }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end

    context 'an invalid version string' do
      let(:version) { '1.2.3.4' }

      it 'returns false' do
        expect(res).to eq(false)
      end
    end
  end
end
