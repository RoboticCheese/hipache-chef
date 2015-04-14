# Encoding: UTF-8

require_relative '../spec_helper'

describe 'Hipache processes' do
  describe command('hipache --help') do
    it 'is executable' do
      expect(subject.stdout).to match(/usage: hipache \[options\]/)
    end
  end

  describe service('hipache') do
    it 'is enabled' do
      expect(subject).to be_enabled
    end

    it 'is running' do
      expect(subject).to be_running
    end
  end
end
