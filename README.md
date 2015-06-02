-*- mode: markdown; mode: visual-line;  -*-

# Sysadmins Puppet Module 

[![Puppet Forge](http://img.shields.io/puppetforge/v/ULHPC/sysadmins.svg)](https://forge.puppetlabs.com/ULHPC/sysadmins)
[![License](http://img.shields.io/:license-GPL3.0-blue.svg)](LICENSE)
![Supported Platforms](http://img.shields.io/badge/platform-debian-lightgrey.svg)
[![Documentation Status](https://readthedocs.org/projects/ulhpc-puppet-sysadmins/badge/?version=latest)](https://readthedocs.org/projects/ulhpc-puppet-sysadmins/?badge=latest)
[![By ULHPC](https://img.shields.io/badge/by-ULHPC-blue.svg)](http://hpc.uni.lu)

Configuration of a single system administrator account (localadmin by default) attached to (potentially) several  users

      Copyright (c) 2015 UL HPC Team aka. S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl <hpc-sysadmins@uni.lu>
      

| [Project Page](https://github.com/ULHPC/puppet-sysadmins) | [Sources](https://github.com/ULHPC/puppet-sysadmins) | [Documentation](https://ulhpc-puppet-sysadmins.readthedocs.org/en/latest/) | [Issues](https://github.com/ULHPC/puppet-sysadmins/issues) |

## Synopsis

This puppet module configures a single system administrator account (`localadmin` by default) attached to (potentially) several users for which one or more SSH keys can be configured. 

This module implements the following elements: 

* __Puppet classes__:
    - `sysadmins` 
    - `sysadmins::common` 
    - `sysadmins::common::debian`: specific implementation under Debian 
    - `sysadmins::common::redhat`: specific implementation under Redhat-like system 
    - `sysadmins::params`:  module parameters 

All these components are configured through a set of variables you will find in
[`manifests/params.pp`](manifests/params.pp). 

_Note_: the various operations that can be conducted from this repository are piloted from a [`Rakefile`](https://github.com/ruby/rake) and assumes you have a running [Ruby](https://www.ruby-lang.org/en/) installation.
See `docs/contributing.md` for more details on the steps you shall follow to have this `Rakefile` working properly. 

## Dependencies

See [`metadata.json`](metadata.json). In particular, this module depends on 

* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [puppetlabs/concat](https://forge.puppetlabs.com/puppetlabs/concat)
* [ULHPC/bash](https://forge.puppetlabs.com/ULHPC/bash)
* [ULHPC/sudo](https://forge.puppetlabs.com/ULHPC/sudo)
* [camptocamp/accounts](https://forge.puppetlabs.com/camptocamp/accounts)

## Overview and Usage

### Class `sysadmins`

This is the main class defined in this module.
It accepts the following parameters: 

* `$ensure`: default to 'present', can be 'absent'
* `$login`: the actual login used for the local sysadmin account
  - _Default_: `localadmin`
* `$email`: redirect all mails sent to the sysadmin account to this email address
* `$purge_ssh_keys`: whether to purge the authorized_keys files or not 
* `$filter_access`: whether or not to prevent access to the sysadmin account for non-registered users (via `~<login>/.sysadminrc`)
   - _Default_: true
* `$users`:  hash of the users authorized to connect to the  local sysadmin account _i.e._ the real users (system administrators). The format of each entry is as follows:

         <login>:
           firstname: <firstname>
		   lastname: <lastname>
		   email: <email>
		   office: <address>

* `$groups`: Additonnal groups the sysadmin user is member of
* `$ssh_keys`: Hash of the SSH keys -- each entry should be prefixed by the appropriate login defined in `sysadmins::users` as follows:

          <login>[@<comment>]:
             type: <key_type>
             public: <public_key>

Use it as follows:

      class { 'sysadmins':
          ensure         => 'present',
          groups         => [ 'vagrant' ],   # can be a string
          users          => hiera_hash('sysadmins::users', {}),
          ssh_keys       => hiera_hash('sysadmins::ssh_keys', {}),
          purge_ssh_keys => true,
	  }
		 
Example hiera YAML file (see also [`tests/hiera/common.yaml`](tests/hiera/common.yaml)):

```yaml
#
# Example of Users definitions
#
sysadmins::users:
  svarrette:
    firstname: Sébastien
    lastname: Varrette
    email: Sebastien.Varrette@domain.org
    office: Campus Kirchberg, E-007
  hcartiaux:
    firstname: Hyacinthe
    lastname: Cartiaux
    email: Hyacinthe.Cartiaux@domain.org
    office: Campus Kirchberg, E-008
#
# SSH keys -- should be prefixed by the appropriate login defined in sysadmins::users
#   Format: <login>[@<comment>]:
#               type:
#               public:
#
sysadmins::ssh_keys:
  svarrette:
    type: ssh-dss
    public: AAAAB3NzaC1kc3MA...
  svarrette@workstation:
    type: ssh-rsa
    public: 5reQfxIMsEU/4336qUHY0wAAAIBFs...
  hcartiaux:
    type: ssh-dss
    public: MAAACBAKQMf834bHh4TFMecBKK...
  sdiehl:
    type: ssh-dss
    public: QMf834bHh4T...
  vplugaru:
    type: ssh-rsa
    public: HY0wAAAIBF...
```
	
See also [`tests/init.pp`](tests/init.pp)

This will create the `localadmin` account. In the example above, the `~localadmin/.ssh/authorized_keys` holds the SSH keys of only `svarrette` and `hcartiaux` users as they are the ones listed in `sysadmins::users`. Example:

       $> cat ~localadmin/.ssh/authorized_keys
	   # HEADER: This file was autogenerated at 2015-06-02 20:40:46 +0000
	   # HEADER: by puppet.  While it can still be managed manually, it
	   # HEADER: is definitely not recommended.
	   environment="SYSADMIN_USER=svarrette" ssh-rsa 5reQfxIMsEU/4336qUHY0wAAAIBFs... svarrette@debugkey-on-localadmin
	   environment="SYSADMIN_USER=hcartiaux" ssh-dss MAAACBAKQMf834bHh4TFMecBKK... hcartiaux-on-localadmin
	   environment="SYSADMIN_USER=svarrette" ssh-dss AAAAB3NzaC1kc3MA... svarrette@falkor.uni.lux-on-localadmin

As you can notice, the special environment variable `SYSADMIN_USER` is set.
It is used to eventually restrict the access to the `localadmin` account (see `~localadmin/.sysadminrc`). 

## Librarian-Puppet / R10K Setup

You can of course configure the sysadmins module in your `Puppetfile` to make it available with [Librarian puppet](http://librarian-puppet.com/) or
[r10k](https://github.com/adrienthebo/r10k) by adding the following entry:

     # Modules from the Puppet Forge
     mod "ULHPC/sysadmins"

or, if you prefer to work on the git version: 

     mod "ULHPC/sysadmins", 
         :git => 'https://github.com/ULHPC/puppet-sysadmins',
         :ref => 'production' 

## Issues / Feature request

You can submit bug / issues / feature request using the [ULHPC/sysadmins Puppet Module Tracker](https://github.com/ULHPC/puppet-sysadmins/issues). 

## Developments / Contributing to the code 

If you want to contribute to the code, you shall be aware of the way this module is organized. 
These elements are detailed on [`docs/contributing.md`](contributing/index.md).

You are more than welcome to contribute to its development by [sending a pull request](https://help.github.com/articles/using-pull-requests). 

## Puppet modules tests within a Vagrant box

The best way to test this module in a non-intrusive way is to rely on [Vagrant](http://www.vagrantup.com/).
The `Vagrantfile` at the root of the repository pilot the provisioning various vagrant boxes available on [Vagrant cloud](https://atlas.hashicorp.com/boxes/search?utf8=%E2%9C%93&sort=&provider=virtualbox&q=svarrette) you can use to test this module.

See [`docs/vagrant.md`](vagrant.md) for more details. 

## Online Documentation

[Read the Docs](https://readthedocs.org/) aka RTFD hosts documentation for the open source community and the [ULHPC/sysadmins](https://github.com/ULHPC/puppet-sysadmins) puppet module has its documentation (see the `docs/` directly) hosted on [readthedocs](http://ulhpc-puppet-sysadmins.rtfd.org).

See [`docs/rtfd.md`](rtfd.md) for more details.

## Licence

This project and the sources proposed within this repository are released under the terms of the [GPL-3.0](LICENCE) licence.


[![Licence](https://www.gnu.org/graphics/gplv3-88x31.png)](LICENSE)
