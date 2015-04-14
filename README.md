Hipache Cookbook
================
[![Cookbook Version](https://img.shields.io/cookbook/v/hipache.svg)][cookbook]
[![Build Status](https://img.shields.io/travis/RoboticCheese/hipache-chef.svg)][travis]
[![Code Climate](https://img.shields.io/codeclimate/github/RoboticCheese/hipache-chef.svg)][codeclimate]
[![Coverage Status](https://img.shields.io/coveralls/RoboticCheese/hipache-chef.svg)][coveralls]

[cookbook]: https://supermarket.chef.io/cookbooks/hipache
[travis]: https://travis-ci.org/RoboticCheese/hipache-chef
[codeclimate]: https://codeclimate.com/github/RoboticCheese/hipache-chef
[coveralls]: https://coveralls.io/r/RoboticCheese/hipache-chef

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

***hipache_application***

Used to install/uninstall the Hipache application itself.

Syntax:

    hipache_application 'hipache' do
      version '1.2.3'
    end

Actions:

| Action       | Description                       |
|--------------|-----------------------------------|
| `:install`   | Default; installs the application |
| `:uninstall` | Uninstalls the application        |

Attributes:

| Attribute | Default    |
|-----------|------------|
| `version` | `'latest'` |

***hipache_configuration***

Used to parse and write out a Hipache configuration file. Can either be given
a series of attributes to merge with an internal set of defaults or a
`config_hash` meant to represent the entirety of your Hipache config file.

Syntax:

    hipache_configuration 'hipache' do
      path '/etc/hipache/config.json'
    end

Actions:

| Action    | Description                      |
|-----------|----------------------------------|
| `:create` | Default; creates the config file |
| `:delete` | Deletes the config file          |

Attributes:

| Attribute                    | Default                         |
|------------------------------|---------------------------------|
| `path`                       | `'/etc/hipache.json'`           |
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
| `config_hash`                | `nil`                           |

***hipache_service***

Used to manage any init scripts and the Hipache service.

Actions:

| Action     | Description                               |
|------------|-------------------------------------------|
| `:create`  | Default; creates any init files           |
| `:delete`  | Stops + disables + deletes any init files |
| `:enable`  | Default; enables the Hipache service      |
| `:disable` | Disables the Hipache service              |
| `:start`   | Default; starts the Hipache service       |
| `:stop`    | Stops the Hipache service                 |

Attributes:

| Attribute     | Default               |
|---------------|-----------------------|
| `init_system` | `:upstart`            |
| `config_path` | `'/etc/hipache.json'` |

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

Copyright 2014-2015, Jonathan Hartman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
