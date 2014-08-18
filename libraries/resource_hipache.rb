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
      include ::Hipache::Helpers

      attr_accessor :installed

      alias_method :installed?, :installed

      def initialize(name, run_context = nil)
        super
        @resource_name = :hipache
        @provider = Chef::Provider::Hipache
        @action = [:install, :enable, :start]
        @package_url = nil
        @allowed_actions = [
          :install, :uninstall, :enable, :disable, :start, :stop
        ]

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
      def self.define_attribute_method(method, attrs)
        define_method(method) do |arg = nil|
          set_or_return(
            method,
            arg.is_a?(String) && attrs[:kind_of] == Fixnum ? arg.to_i : arg,
            kind_of: attrs[:kind_of],
            default: attrs[:default],
            callbacks: { "A `config` and `#{method}` can't be used together" =>
                           ->(a) { a.nil? ? true : config.nil? } }
          )
        end
      end

      def self.all_valid_attribute_methods
        res = VALID_OPTIONS.each_with_object({}) do |(k, v), hsh|
          hsh[k] = v unless [:server, :http, :https].include?(k)
        end
        [:server, :https, :http].each do |subkey|
          res.merge!(VALID_OPTIONS[subkey].each_with_object({}) do |(k, v), hsh|
            hsh[:"#{subkey}_#{k}"] = v
          end)
        end
        res
      end

      all_valid_attribute_methods.each do |method, attrs|
        define_attribute_method(method, attrs)
      end

      #
      # Alternately, accept a complete Hipache config hash that blows away
      # any other configs offered
      #
      # @param [Hash]
      # @return [Hash, NilClass]
      #
      def config(arg = nil)
        arg && self.class.all_valid_attribute_methods.keys.each do |opt|
          instance_variable_set(:"@#{opt}", nil)
        end
        set_or_return(:config, arg, kind_of: Hash, default: nil)
      end
    end
  end
end
