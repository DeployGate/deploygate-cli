# deploygate-cli

[![Gem Version](https://badge.fury.io/rb/deploygate.svg)](https://badge.fury.io/rb/deploygate)
[![Build Status](https://travis-ci.org/DeployGate/deploygate-cli.svg?branch=master)](https://travis-ci.org/DeployGate/deploygate-cli)

dg: A command-line interface for DeployGate

## Requirements

*dg* runs with a minimal set of requirements.

- Ruby 2.4+ (Depends on [Ruby Maintenance Branches](https://www.ruby-lang.org/en/downloads/branches/))
- Bundler

## Installation

Install *dg* as a non-system standalone binary. (Recommended)

```bash
curl -sL 'https://github.com/DeployGate/deploygate-cli/blob/master/install.bash' | [DG_VERSION=...] bash
# You can uninstall dg by running `cd ~/.dg && rm -fr .bundle vendor link Gemfile Gemfile.lock && rm /usr/local/bin/dg`
```

Or run `gem install deploygate` to install *dg*.

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
