# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Library:: resource_hipache_service
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

require 'chef/resource'
require_relative 'hipache_helpers'
require_relative 'provider_hipache_service'

class Chef
  class Resource
    # A Chef resource for the Hipache Node.js package
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class HipacheService < Resource
      include ::Hipache::Helpers

      attr_accessor :created
      attr_accessor :enabled
      attr_accessor :running
      alias_method :created?, :created
      alias_method :enabled?, :enabled
      alias_method :running?, :running

      def initialize(name, run_context = nil)
        super
        @resource_name = :hipache_service
        @provider = Chef::Provider::HipacheService
        @action = [:create, :enable, :start]
        @allowed_actions = [
          :create, :delete, :enable, :disable, :start, :stop
        ]

        @created, @enabled, @running = false, false, false
      end

      #
      # Allow overridding of the init system to use for the service
      #
      # @param [String, NilClass]
      # @return [Symbol]
      #
      def init_system(arg = nil)
        set_or_return(:init_system,
                      arg.nil? ? arg : arg.to_sym,
                      kind_of: Symbol,
                      equal_to: [:upstart],
                      default: :upstart)
      end

      #
      # A path to the config file so the service can be pointed at it
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
    end
  end
end
