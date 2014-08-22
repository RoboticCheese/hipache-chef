# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Spec:: libraries/resource_hipache_configuration
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
require_relative '../../libraries/resource_hipache_configuration'

describe Chef::Resource::Hipache::Configuration do
  let(:path) { nil }
  let(:config_hash) { nil }

  options =  [
    :server_access_log,
    :server_workers,
    :server_max_sockets,
    :server_dead_backend_ttl,
    :server_tcp_timeout,
    :server_retry_on_error,
    :server_dead_backend_on_500,
    :server_http_keep_alive,
    :https_port,
    :https_bind,
    :https_key,
    :https_cert,
    :http_port,
    :http_bind,
    :driver
  ]
  options.each { |o| let(o) { nil } }

  let(:resource) do
    r = described_class.new('my_hipache', nil)
    r.path(path) unless path.nil?
    r.config_hash(config_hash) unless config_hash.nil?
    options.each { |o| r.send(o, send(o)) }
    r
  end

  describe '#initialize' do
    it 'defaults to the create action' do
      expect(resource.instance_variable_get(:@action)).to eq(:create)
      expect(resource.action).to eq(:create)
    end

    it 'defaults the state to not created' do
      expect(resource.instance_variable_get(:@created)).to eq(false)
      expect(resource.created?).to eq(false)
    end
  end

  describe '#path' do
    context 'no override provided' do
      it 'returns the default' do
        expect(resource.path).to eq('/etc/hipache.json')
      end
    end

    context 'a valid override provided' do
      let(:path) { '/var/hip' }

      it 'returns the overridden value' do
        expect(resource.path).to eq('/var/hip')
      end
    end

    context 'an invalid override provided' do
      let(:path) { :test }

      it 'raises an exception' do
        expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end

  describe '#define_attribute_method' do
    it 'defines a new attribute method' do
      args = { kind_of: String, default: 'test' }
      described_class.define_attribute_method(:a_test, args)
      expect(resource.a_test).to eq('test')
    end
  end

  describe '#all_valid_attribute_methods' do
    options.each do |o|
      it "returns the #{o} method" do
        expect(described_class.all_valid_attribute_methods.keys).to include(o)
      end
    end
  end

  options.each do |method|
    describe "##{method}" do
      context 'no override provided' do
        it 'returns the default' do
          vopts = described_class::VALID_OPTIONS
          expected = if vopts[method]
                       vopts[method][:default]
                     elsif vopts[:server][method[7..-1].to_sym]
                       vopts[:server][method[7..-1].to_sym][:default]
                     elsif vopts[:https][method[6..-1].to_sym]
                       vopts[:https][method[6..-1].to_sym][:default]
                     elsif vopts[:http][method[5..-1].to_sym]
                       vopts[:http][method[5..-1].to_sym][:default]
                     end
          expect(resource.send(method)).to eq(expected)
        end
      end

      context 'a valid override provided' do
        let(method) do
          vopts = described_class::VALID_OPTIONS
          kind_of = if vopts[method]
                      vopts[method][:kind_of]
                    elsif vopts[:server][method[7..-1].to_sym]
                      vopts[:server][method[7..-1].to_sym][:kind_of]
                    elsif vopts[:https][method[6..-1].to_sym]
                      vopts[:https][method[6..-1].to_sym][:kind_of]
                    elsif vopts[:http][method[5..-1].to_sym]
                      vopts[:http][method[5..-1].to_sym][:kind_of]
                    end
          cls = kind_of.is_a?(Array) ? kind_of[0] : kind_of
          case cls.to_s
          when 'String'
            'so-crates'
          when 'Fixnum'
            98
          when 'TrueClass'
            false
          end
        end

        it 'returns the overridden value' do
          expect(resource.send(method)).to eq(send(method))
        end

        context 'an invalid option combo' do
          let(:config_hash) { { access_log: '/tmp/log.log' } }

          it 'raises an exception' do
            expected = Chef::Exceptions::ValidationFailed
            expect { resource }.to raise_error(expected)
          end
        end
      end

      context 'an invalid override provided' do
        let(method) do
          vopts = described_class::VALID_OPTIONS
          kind_of = if vopts[method]
                      vopts[method][:kind_of]
                    elsif vopts[:server][method[7..-1].to_sym]
                      vopts[:server][method[7..-1].to_sym][:kind_of]
                    elsif vopts[:https][method[6..-1].to_sym]
                      vopts[:https][method[6..-1].to_sym][:kind_of]
                    elsif vopts[:http][method[5..-1].to_sym]
                      vopts[:http][method[5..-1].to_sym][:kind_of]
                    end
          cls = kind_of.is_a?(Array) ? kind_of[0] : kind_of
          case cls.to_s
          when 'String'
            { twenty: 'one' }
          when 'Fixnum'
            :something
          when 'TrueClass'
            'nothing'
          end
        end

        it 'raises an exception' do
          expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
        end
      end
    end
  end

  describe '#config_hash' do
    context 'no override provided' do
      it 'returns the default' do
        expect(resource.config_hash).to eq(nil)
      end
    end

    context 'a valid override provided' do
      let(:config_hash) { { access_log: '/tmp/log.log' } }

      it 'returns the overridden value' do
        expect(resource.config_hash).to eq(config_hash)
      end

      options.each do |opt|
        it "sets #{opt} to nil" do
          expect(resource.send(opt)).to eq(nil)
        end
      end
    end

    context 'an invalid override provided' do
      let(:config_hash) { :monkeys }

      it 'raises an exception' do
        expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end
end
