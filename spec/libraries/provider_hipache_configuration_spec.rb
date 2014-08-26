# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Spec:: libraries/provider_hipache_configuration
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
require_relative '../../libraries/provider_hipache_configuration'

describe Chef::Provider::HipacheConfiguration do
  options = [
    :created,
    :path,
    :server_access_log,
    :server_workers,
    :server_max_sockets,
    :server_dead_backend_ttl,
    :server_tcp_timeout,
    :server_retry_on_error,
    :server_dead_backend_on_500,
    :server_http_keep_alive,
    :http_port,
    :http_bind,
    :https_key,
    :https_cert,
    :https_port,
    :https_bind,
    :driver
  ]
  options.each { |o| let(o) { nil } }

  let(:new_resource) do
    r = Chef::Resource::HipacheConfiguration.new('hipache', nil)
    options.each do |o|
      r.send(o, send(o)) unless send(o).nil?
    end
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
    it 'returns a Configuration resource' do
      expected = Chef::Resource::HipacheConfiguration
      expect(provider.load_current_resource).to be_an_instance_of(expected)
    end
  end

  describe '#action_create' do
    let(:config_file) { double(run_action: true) }
    let(:config_dir) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:config_file)
        .and_return(config_file)
      allow_any_instance_of(described_class).to receive(:config_dir)
        .and_return(config_dir)
    end

    it 'creates the config file parent directory' do
      expect(config_dir).to receive(:run_action).with(:create)
      provider.action_create
    end

    it 'creates the config file' do
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
    let(:config_dir) { double(run_action: true, only_if: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:config_file)
        .and_return(config_file)
      allow_any_instance_of(described_class).to receive(:config_dir)
        .and_return(config_dir)
    end

    it 'deletes the config file' do
      expect(config_file).to receive(:run_action).with(:delete)
      provider.action_delete
    end

    it 'deletes the config file parent directory if empty' do
      expect(config_dir).to receive(:only_if)
      expect(config_dir).to receive(:run_action).with(:delete)
      provider.action_delete
    end

    it 'sets the resource state to deleted' do
      expect(new_resource).to receive(:created=).with(false)
      provider.action_delete
    end
  end

  describe '#config_file' do
    let(:path) { '/somewhere/on/the/filesystem' }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:generate_config_hash)
        .and_return(pants: 'sometimes', neckties: 'never')
    end

    it 'returns a File resource instance' do
      expected = Chef::Resource::File
      expect(provider.send(:config_file)).to be_an_instance_of(expected)
    end

    it 'points to the config file path' do
      expect(provider.send(:config_file).path).to eq(path)
    end

    it 'populates that file with our config JSONified' do
      expected = '{"pants":"sometimes","neckties":"never"}'
      expect(provider.send(:config_file).content).to eq(expected)
    end
  end

  describe '#config_dir' do
    let(:path) { '/etc/things/hipache' }

    it 'returns a Directory resource instance' do
      expected = Chef::Resource::Directory
      expect(provider.send(:config_dir)).to be_an_instance_of(expected)
    end

    it 'points to the config file parent directory' do
      expect(provider.send(:config_dir).path).to eq('/etc/things')
    end

    it 'is set up to be recursive' do
      expect(provider.send(:config_dir).recursive).to eq(true)
    end
  end

  describe '#generate_config_hash' do
    context 'all default attributes' do
      it 'returns a hash of all the default attributes' do
        expected = {
          server: {
            accessLog: '/var/log/hipache_access.log',
            workers: 10,
            maxSockets: 100,
            deadBackendTTL: 30,
            tcpTimeout: 30,
            retryOnError: 3,
            deadBackendOn500: true,
            httpKeepAlive: false
          },
          https: {
            port: 443,
            bind: %w(127.0.0.1 ::1),
            key: '/etc/ssl/ssl.key',
            cert: '/etc/ssl/ssl.crt'
          },
          http: {
            port: 80,
            bind: %w(127.0.0.1 ::1)
          },
          driver: 'redis://127.0.0.1:6379'
        }
        expect(provider.send(:generate_config_hash)).to eq(expected)
      end
    end
  end

  describe '#generate_server_hash' do
    context 'all default attributes' do
      it 'returns an all default server hash' do
        expected = {
          accessLog: '/var/log/hipache_access.log',
          workers: 10,
          maxSockets: 100,
          deadBackendTTL: 30,
          tcpTimeout: 30,
          retryOnError: 3,
          deadBackendOn500: true,
          httpKeepAlive: false
        }
        expect(provider.send(:generate_server_hash)).to eq(expected)
      end
    end

    context 'all overridden attributes' do
      let(:server_access_log) { '/tmp/log.log' }
      let(:server_workers) { 99 }
      let(:server_max_sockets) { 99 }
      let(:server_dead_backend_ttl) { 99 }
      let(:server_tcp_timeout) { 99 }
      let(:server_retry_on_error) { 99 }
      let(:server_dead_backend_on_500) { false }
      let(:server_http_keep_alive) { true }

      it 'returns the overridden server hash' do
        expected = {
          accessLog: '/tmp/log.log',
          workers: 99,
          maxSockets: 99,
          deadBackendTTL: 99,
          tcpTimeout: 99,
          retryOnError: 99,
          deadBackendOn500: false,
          httpKeepAlive: true
        }
        expect(provider.send(:generate_server_hash)).to eq(expected)
      end
    end
  end

  describe '#generate_https_hash' do
    context 'all default attributes' do
      it 'returns an all default HTTPS hash' do
        expected = { port: 443,
                     bind: %w(127.0.0.1 ::1),
                     key: '/etc/ssl/ssl.key',
                     cert: '/etc/ssl/ssl.crt' }
        expect(provider.send(:generate_https_hash)).to eq(expected)
      end
    end

    context 'all overridden attributes' do
      let(:https_port) { 42 }
      let(:https_bind) { '1.2.3.4' }
      let(:https_key) { '/tmp/key' }
      let(:https_cert) { '/tmp/cert' }

      it 'returns the overridden HTTPS hash' do
        expected = { port: https_port,
                     bind: https_bind,
                     key: https_key,
                     cert: https_cert }
        expect(provider.send(:generate_https_hash)).to eq(expected)
      end
    end
  end

  describe '#generate_http_hash' do
    context 'all default attributes' do
      it 'returns an all default HTTP hash' do
        expected = { port: 80, bind: %w(127.0.0.1 ::1) }
        expect(provider.send(:generate_http_hash)).to eq(expected)
      end
    end

    context 'all overridden attributes' do
      let(:http_port) { 42 }
      let(:http_bind) { '1.2.3.4' }

      it 'returns the overridden HTTP hash' do
        expected = { port: http_port, bind: http_bind }
        expect(provider.send(:generate_http_hash)).to eq(expected)
      end
    end
  end
end
