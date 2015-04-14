# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Library:: resource_hipache_application
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

require 'chef/mixin/params_validate'
require 'chef/resource'
require_relative 'hipache_helpers'
require_relative 'provider_hipache_application'

class Chef
  class Resource
    # A Chef resource for the Hipache application
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class HipacheApplication < Resource
      include ::Hipache::Helpers

      attr_accessor :installed
      alias_method :installed?, :installed

      def initialize(name, run_context = nil)
        super
        @resource_name = :hipache_application
        @provider = Chef::Provider::HipacheApplication
        @action = :install
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
    end
  end
end
