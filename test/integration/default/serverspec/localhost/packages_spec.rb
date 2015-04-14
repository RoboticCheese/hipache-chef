# Encoding: UTF-8

require_relative '../spec_helper'

describe 'Hipache packages' do
  describe package('nodejs') do
    it 'is installed' do
      expect(subject).to be_installed
    end
  end

  describe command('npm info hipache') do
    it 'exits 0 (npm::hipache is installed)' do
      expect(subject.exit_status).to eq(0)
    end
  end
end
