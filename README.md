# deploygate-cli

[![Gem Version](https://badge.fury.io/rb/deploygate.svg)](https://badge.fury.io/rb/deploygate)

## :warning: This tool is no longer supported

This CLI tool is no longer actively maintained or supported. Please use the [DeployGate API](https://docs.deploygate.com/docs/api) instead for integrating DeployGate into your workflows.

---

dg: A command-line interface for DeployGate

## Requirements

- Ruby 2.6+ (Depends on [Ruby Maintenance Branches](https://www.ruby-lang.org/en/downloads/branches/))

## Installation

Add this line to your application's Gemfile:

```
gem 'deploygate'

# Only when you are using Ruby 2.x
gem 'multi_xml' '~> 0.6.0'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install 'multi_xml' -v '~> 0.6.0' # Run this only when you are using Ruby 2.x
$ gem install deploygate
```

## Usage

Please see [documents](https://docs.deploygate.com/docs/cli)

### Upload apps

```
$ dg deploy [apk/ipa file path]
```

### Android/iOS build and upload

```
$ dg deploy [Android/iOS project path]
```

## License

Copyright (C) 2015- DeployGate All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

## Release

- Bump the version of [./lib/deploygate/version.rb](./lib/deploygate/version.rb) and merge it
- Create a tag via GitHub Releases
- GitHub Actions will release the built gem to rubygems.org
