Hipache Cookbook
================
[![Cookbook Version](http://img.shields.io/cookbook/v/hipache.svg)][cookbook]
[![Build Status](http://img.shields.io/travis/RoboticCheese/hipache-chef.svg)][travis]

[cookbook]: https://supermarket.getchef.com/cookbooks/hipache
[travis]: http://travis-ci.org/RoboticCheese/hipache-chef

A cookbook for installing the [Hipache](https://github.com/hipache/hipache)
HTTP and websocket proxy.

Requirements
============

Usage
=====

This cookbook can be implemented either by calling its resource directly, or
adding the recipe that wraps it to your run_list.

Recipes
=======

***default***

Installs Node.js and calls the `hipache` resource (below) to install and
configure Hipache based on a set of attributes.

Attributes
==========

***default***

Defaults all the possible attributes to be used by the default recipe to nil,
i.e. use all the resource's defaults (see below).

Resources
=========

***hipache***

Wraps the installation and configuration of Hipache in a single resource.

Configuration can be offered with a series of attributes:

    hipache 'my_hipache' do
      server_access_log: '/path/to/file'
      server_workers: 30
    end

| Attribute                    | Default                         |
|------------------------------|---------------------------------|
| `server_access_log`          | `'/var/log/hipache_access.log'` |
| `server_workers`             | `10`                            |
| `server_max_sockets`         | `100`                           |
| `server_dead_backend_ttl`    | `30`                            |
| `server_tcp_timeout`         | `30`                            |
| `server_retry_on_error`      | `3`                             |
| `server_dead_backend_on_500` | `true`                          |
| `http_keep_alive`            | `false`                         |
| `https_port`                 | `443`                           |
| `https_bind`                 | `['127.0.0.1', '::1']`          |
| `https_key`                  | `'/etc/ssl/ssl.key'`            |
| `https_cert`                 | `'/etc/ssl/ssl.crt'`            |
| `http_port`                  | `80`                            |
| `http_bind`                  | `['127.0.0.1', '::1']`          |
| `driver`                     | `'redis://127.0.0.1:6379'`      |

...or with a configuration hash that represents the entirety of your desired
configuration (i.e. no default values will be applied for anything else):

    hipache 'my_hipache' do
      # access_log: '/path/to/file' # Don't set anything else, it'll be ignored
      config(
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
          bind: ['127.0.0.1', '::1'],
          key: '/etc/ssl/ssl.key',
          cert: '/etc/ssl/ssl.crt'
        },
        http: {
          port: 80,
          bind: ['127.0.0.1', '::1'],
        },
        driver: 'redis://127.0.0.1:6379'
      )
    end

See the [Hipache](https://github.com/hipache/hipache) documentation for further
info on all its options.

Providers
=========

Contributing
============

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run style checks and RSpec tests (`bundle exec rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

License & Authors
=================
- Author: Jonathan Hartman <j@p4nt5.com>

Copyright 2014, Jonathan Hartman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
