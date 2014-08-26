# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Spec:: libraries/provider_hipache_application
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
require_relative '../../libraries/provider_hipache_application'

describe Chef::Provider::HipacheApplication do
  let(:version) { nil }
  let(:installed) { nil }

  let(:new_resource) do
    r = Chef::Resource::HipacheApplication.new('hipache', nil)
    r.version(version) unless version.nil?
    r.installed(installed) unless installed.nil?
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
    it 'returns an application resource' do
      expected = Chef::Resource::HipacheApplication
      expect(provider.load_current_resource).to be_an_instance_of(expected)
    end
  end

  describe '#action_install' do
    let(:package) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:package)
        .and_return(package)
    end

    it 'installs the Hipache package' do
      expect(package).to receive(:run_action).with(:install)
      provider.action_install
    end

    it 'sets the resource state to installed' do
      expect(new_resource).to receive(:installed=).with(true)
      provider.action_install
    end
  end

  describe '#action_uninstall' do
    let(:package) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:package)
        .and_return(package)
    end

    it 'uninstalls the Hipache package' do
      expect(package).to receive(:run_action).with(:uninstall)
      provider.action_uninstall
    end

    it 'sets the resource state to uninstalled' do
      expect(new_resource).to receive(:installed=).with(false)
      provider.action_uninstall
    end
  end
end
