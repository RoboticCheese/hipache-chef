# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Library:: hipache_helpers
#
# Copyright 2014-2015, Jonathan Hartman
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

module Hipache
  # A set of helper methods shared by all the resources and providers
  #
  # @author Jonathan Hartman <j@p4nt5.com>
  module Helpers
    #
    # All of the config options recognized, their respective acceptable
    # classes, and default values
    #
    VALID_OPTIONS ||= {
      server: {
        access_log: {
          kind_of: String,
          default: '/var/log/hipache_access.log',
          alt_name: :accessLog
        },
        workers: {
          kind_of: Fixnum,
          default: 10,
          alt_name: :workers
        },
        max_sockets: {
          kind_of: Fixnum,
          default: 100,
          alt_name: :maxSockets
        },
        dead_backend_ttl: {
          kind_of: Fixnum,
          default: 30,
          alt_name: :deadBackendTTL
        },
        tcp_timeout: {
          kind_of: Fixnum,
          default: 30,
          alt_name: :tcpTimeout
        },
        retry_on_error: {
          kind_of: Fixnum,
          default: 3,
          alt_name: :retryOnError
        },
        dead_backend_on_500: {
          kind_of: [TrueClass, FalseClass],
          default: true,
          alt_name: :deadBackendOn500
        },
        http_keep_alive: {
          kind_of: [TrueClass, FalseClass],
          default: false,
          alt_name: :httpKeepAlive
        }
      },
      https: {
        port: {
          kind_of: Fixnum,
          default: 443,
          alt_name: :port
        },
        bind: {
          kind_of: [String, Array],
          default: ['127.0.0.1', '::1'],
          alt_name: :bind
        },
        key: {
          kind_of: String,
          default: '/etc/ssl/ssl.key',
          alt_name: :key
        },
        cert: {
          kind_of: String,
          default: '/etc/ssl/ssl.crt',
          alt_name: :cert
        }
      },
      http: {
        port: {
          kind_of: Fixnum,
          default: 80,
          alt_name: :port
        },
        bind: {
          kind_of: [String, Array],
          default: ['127.0.0.1', '::1'],
          alt_name: :bind
        }
      },
      driver: {
        kind_of: String,
        default: 'redis://127.0.0.1:6379',
        alt_name: :driver
      }
    }

    #
    # Return the init system for use in this platform
    #
    # @return [Symbol]
    #
    def init_system
      # TODO: Add other platforms
      case node['platform']
      when 'ubuntu'
        :upstart
      else
        fail(Exceptions::UnsupportedPlatform, :init_system)
      end
    end

    #
    # The name of the Hipache application
    #
    # @return [String]
    #
    def app_name
      'hipache'
    end

    #
    # Is this symbol/string a valid version identifier?
    #
    # @param [String, Symbol]
    # @return [TrueClass, FalseClass]
    #
    def valid_version?(arg)
      return false unless arg.is_a?(String) || arg.is_a?(Symbol)
      return true if arg.to_s == 'latest'
      arg.match(/^[0-9]+\.[0-9]+\.[0-9]+$/) ? true : false
    end
  end

  class Exceptions
    # A custom exception class for not implemented methods
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MethodNotImplemented < NotImplementedError
      def initialize(method)
        super("Method '#{method}' needs to be implemented")
      end
    end

    # A custom exception class for unsupported platforms
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class UnsupportedPlatform < NotImplementedError
      def initialize(item)
        super("Unsupported platform for method '#{item}'")
      end
    end
  end
end
