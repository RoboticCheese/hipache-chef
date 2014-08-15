# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Library:: resource/hipache
#
# Copyright 2014, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/resource'
require_relative 'hipache_helpers'
require_relative 'provider_hipache'

class Chef
  class Resource
    # A Chef resource for the Hipache Node.js package
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Hipache < Resource
      # Provide a hopefully sensible set of defaults for the config, courtesy
      # of https://github.com/hipache/hipache/blob/master/config/config.json and
      # https://github.com/hipache/hipache#2-configuration-configjson
      VALID_OPTIONS ||= {
        access_log: { kind_of: String, default: '/var/log/hipache_access.log' },
        workers: { kind_of: Fixnum, default: 10 },
        max_sockets: { kind_of: Fixnum, default: 100 },
        dead_backend_ttl: { kind_of: Fixnum, default: 30 },
        tcp_timeout: { kind_of: Fixnum, default: 30 },
        retry_on_error: { kind_of: Fixnum, default: 3 },
        dead_backend_on_500: { kind_of: [TrueClass, FalseClass],
                               default: true },
        http_keep_alive: { kind_of: [TrueClass, FalseClass], default: false },
        https_port: { kind_of: Fixnum, default: 443 },
        https_bind: { kind_of: [String, Array], default: ['127.0.0.1', '::1'] },
        https_key: { kind_of: String, default: '/etc/ssl/ssl.key' },
        https_cert: { kind_of: String, default: '/etc/ssl/ssl.crt' },
        http_port: { kind_of: Fixnum, default: 80 },
        http_bind: { kind_of: [String, Array], default: ['127.0.0.1', '::1'] },
        driver: { kind_of: String, default: 'redis://127.0.0.1:6379' }
      }

      include ::Hipache::Helpers

      attr_accessor :installed

      alias_method :installed?, :installed

      def initialize(name, run_context = nil)
        super
        @resource_name = :hipache
        @provider = Chef::Provider::Hipache
        @action = :install
        @package_url = nil
        @allowed_actions = [:install, :uninstall]

        @installed = false
      end

      #
      # The version of Hipache to install
      #
      # @param [String, Symbol, NilClass] arg
      # @return [String]
      #
      def version(arg = nil)
        set_or_return(:version,
                      arg.nil? ? arg : arg.to_s,
                      kind_of: String,
                      default: 'latest',
                      callbacks: {
                        "Valid versions are 'latest' or 'x.y.z'" =>
                          ->(a) { valid_version?(a) }
                      })
      end

      #
      # The path to the Hipache config file
      #
      # @param [String, NilClass]
      # @return [String]
      #
      def config_path(arg = nil)
        set_or_return(:config_path,
                      arg,
                      kind_of: String,
                      default: '/etc/hipache.json')
      end

      #
      # Set up a method for each of the valid Hipache config options
      #
      VALID_OPTIONS.each do |method, attrs|
        define_method(method) do |arg = nil|
          attrs[:callbacks] = {
            "A `config` and `#{method}` can't be used together" =>
              ->(a) { a.nil? ? true : config.nil? }
          }
          arg.is_a?(String) && attrs[:kind_of] == Fixnum && arg = arg.to_i
          set_or_return(method, arg, attrs)
        end
      end

      #
      # Alternately, accept a complete Hipache config hash that blows away
      # any other configs offered
      #
      # @param [Hash]
      # @return [Hash, NilClass]
      #
      def config(arg = nil)
        if arg
          VALID_OPTIONS.each { |opt, _| instance_variable_set(:"@#{opt}", nil) }
        end
        set_or_return(:config,
                      arg,
                      kind_of: Hash,
                      default: nil)
      end
    end
  end
end
