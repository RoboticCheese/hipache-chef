# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Spec:: recipes/default
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

require 'spec_helper'

describe 'hipache::default' do
  let(:runner) { ChefSpec::Runner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'installs Node.js' do
    expect(chef_run).to include_recipe('nodejs')
  end

  context 'a default version' do
    it 'installs the default version of Hipache' do
      expect(chef_run).to install_hipache('hipache').with(version: 'latest')
    end
  end

  context 'an overridden version' do
    let(:runner) do
      ChefSpec::Runner.new do |node|
        node.set['hipache']['version'] = '1.2.3'
      end
    end

    it 'installs Hipache with the overridden version' do
      expect(chef_run).to install_hipache('hipache').with(version: '1.2.3')
    end
  end

  context 'a default config_path' do
    it 'installs Hipache with the default config_path' do
      expect(chef_run).to install_hipache('hipache')
        .with(config_path: '/etc/hipache.json')
    end
  end

  context 'an overridden config_path' do
    let(:runner) do
      ChefSpec::Runner.new do |node|
        node.set['hipache']['config_path'] = '/tmp/test.json'
      end
    end

    it 'installs Hipache with the overridden config_path' do
      expect(chef_run).to install_hipache('hipache')
        .with(config_path: '/tmp/test.json')
    end
  end

  context 'a default config hash' do
    it 'installs Hipache with the default config hash' do
      expect(chef_run).to install_hipache('hipache').with(config: nil)
    end
  end

  context 'an overridden config hash' do
    let(:override) { { 'access_log' => '/var/log/log.log' } }
    let(:workers) { nil }
    let(:runner) do
      ChefSpec::Runner.new do |node|
        node.set['hipache']['config'] = override
        node.set['hipache']['workers'] = workers
      end
    end

    context 'no config conflicts' do
      it 'installs Hipache with the overridden config hash' do
        expect(chef_run).to install_hipache('hipache').with(config: override)
      end
    end

    context 'a config conflict' do
      let(:workers) { 200 }

      it 'raises an error' do
        expect { chef_run }.to raise_error
      end
    end
  end

  Hipache::Helpers::VALID_OPTIONS.each do |method, attrs|
    context "a default #{method}" do
      it "installs Hipache with the default #{method}" do
        expect(chef_run).to install_hipache('hipache')
          .with(method => attrs[:default])
      end
    end

    context "an overridden #{method}" do
      let(:override) do
        case attrs[:kind_of].to_s
        when 'Fixnum'
          10_001
        when '[TrueClass, FalseClass]'
          false
        else
          'testables'
        end
      end
      let(:runner) do
        ChefSpec::Runner.new do |node|
          if method.to_s.start_with?('https')
            key = method.to_s.split('_')[1..-1].join('_')
            node.set['hipache']['https'][key] = override
          elsif method.to_s.start_with?('http')
            key = method.to_s.split('_')[1..-1].join('_')
            node.set['hipache']['http'][key] = override
          else
            node.set['hipache'][method] = override
          end
        end
      end

      it "installs Hipache with the overridden #{method}" do
        expect(chef_run).to install_hipache('hipache').with(method => override)
      end
    end
  end
end
