# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Spec:: libraries/provider_hipache_service
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
require_relative '../../libraries/provider_hipache_service'

describe Chef::Provider::Hipache::Service do
  let(:init_system) { nil }
  let(:new_resource) do
    r = Chef::Resource::Hipache::Service.new('my_hipache', nil)
    r.init_system(init_system) if init_system
    r
  end

  let(:provider) { described_class.new(new_resource, nil) }

  before(:each) do
    allow(provider).to receive(:new_resource).and_return(new_resource)
  end

  describe '#whyrun_supported?' do
    it 'advertises WhyRun mode support' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#load_current_resource' do
    it 'returns a Service resource' do
      expected = Chef::Resource::Hipache::Service
      expect(provider.load_current_resource).to be_an_instance_of(expected)
    end
  end

  describe '#action_create' do
    let(:config_file) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:config_file)
        .and_return(config_file)
    end

    it 'creates the service config' do
      expect(config_file).to receive(:run_action).with(:create)
      provider.action_create
    end

    it 'sets the resource state to created' do
      expect(new_resource).to receive(:created=).with(true)
      provider.action_create
    end
  end

  describe '#action_delete' do
    let(:config_file) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:config_file)
        .and_return(config_file)
    end

    it 'deletes the service config' do
      expect(config_file).to receive(:run_action).with(:delete)
      provider.action_delete
    end

    it 'sets the resource state to deleted' do
      expect(new_resource).to receive(:created=).with(false)
      provider.action_delete
    end
  end

  {
    enable: [:enabled, true],
    disable: [:enabled, false],
    start: [:running, true],
    stop: [:running, false]
  }.each do |action, (state, status)|
    describe "#action_#{action}" do
      let(:service) { double(run_action: true) }

      before(:each) do
        allow_any_instance_of(described_class).to receive(:service)
          .and_return(service)
      end

      it "#{action}s the Hipache service" do
        expect(service).to receive(:run_action).with(action)
        provider.send(:"action_#{action}")
      end

      it "sets the #{state} state to #{status}" do
        expect(new_resource).to receive(:"#{state}=").with(status)
        provider.send(:"action_#{action}")
      end
    end
  end
end
