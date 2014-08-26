# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Spec:: libraries/resource_hipache_service
#
# Copyright (C) 2014, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '../spec_helper'
require_relative '../../libraries/resource_hipache_service'

describe Chef::Resource::HipacheService do
  let(:init_system) { nil }
  let(:config_path) { nil }

  let(:resource) do
    r = described_class.new('my_hipache', nil)
    r.init_system(init_system) unless init_system.nil?
    r.config_path(config_path) unless config_path.nil?
    r
  end

  describe '#initialize' do
    it 'defaults to the create + enable + start actions' do
      expected = [:create, :enable, :start]
      expect(resource.instance_variable_get(:@action)).to eq(expected)
      expect(resource.action).to eq(expected)
    end

    it 'defaults the state to not created' do
      expect(resource.instance_variable_get(:@created)).to eq(false)
      expect(resource.created?).to eq(false)
    end

    it 'defaults the state to disabled' do
      expect(resource.instance_variable_get(:@enabled)).to eq(false)
      expect(resource.enabled?).to eq(false)
    end

    it 'defaults the state to stopped' do
      expect(resource.instance_variable_get(:@running)).to eq(false)
      expect(resource.running?).to eq(false)
    end
  end

  describe '#init_system' do
    context 'no override provided' do
      it 'returns the default' do
        expect(resource.init_system).to eq(:upstart)
      end
    end

    context 'a valid override provided' do
      let(:init_system) { 'upstart' }

      it 'returns the overridden value, symbolized' do
        expect(resource.init_system).to eq(:upstart)
      end
    end

    context 'an invalid override provided' do
      let(:init_system) { :systemd }

      it 'raises an exception' do
        expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end

  describe '#config_path' do
    context 'no override provided' do
      it 'returns the default' do
        expect(resource.config_path).to eq('/etc/hipache.json')
      end
    end

    context 'a valid override provided' do
      let(:config_path) { '/tmp/hip.ache' }

      it 'returns the overridden value' do
        expect(resource.config_path).to eq('/tmp/hip.ache')
      end
    end

    context 'an invalid override provided' do
      let(:config_path) { true }

      it 'raises an exception' do
        expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end
end
