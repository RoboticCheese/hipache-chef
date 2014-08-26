# Encoding: UTF-8
#
# Cookbook Name:: hipache
# Spec:: support/matchers/hipache_service
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

module ChefSpec
  module API
    # Some simple matchers for the hipache_service resource
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    module HipacheServiceMatchers
      ChefSpec::Runner.define_runner_method :hipache_service

      def enable_hipache(resource_name)
        ChefSpec::Matchers::ResourceMatcher.new(:hipache_service,
                                                :enable,
                                                resource_name)
      end

      def start_hipache(resource_name)
        ChefSpec::Matchers::ResourceMatcher.new(:hipache_service,
                                                :start,
                                                resource_name)
      end
    end
  end
end