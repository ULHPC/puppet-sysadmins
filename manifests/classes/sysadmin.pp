# File::      <tt>sysadmin.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
# ------------------------------------------------------------------------------
# = Class: sysadmin
#
# Configure a system administrator account for (potentially) several  users
#
# == Parameters: (cf sysadmin-params.pp)
#
# $login:: *Default*: 'localuser'. The actual login used for the account
#
# $groups:: *Default*: []. Additonnal groups the above user is member of
#
# $members:: *Default*: [ 'svarrette', 'hcartiaux' ]. The list of users authorized to connect to the above local account i.e. the real users (system administrators)
#
# $ensure:: *Default*: 'present'. The Puppet ensure attribute (can be either 'present' or 'absent') - absent will ensure the user is removed
#
# == Actions:
#
# Install and configure sysadmin
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import sysadmin
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'sysadmin':
#             login   => 'localuser',
#             ensure  => 'present',
#             members => [ 'svarrette', 'hcartiaux' ]
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class sysadmin(
    $login   = $sysadmin::params::login,
    $members = $sysadmin::params::members,
    $ensure  = $sysadmin::params::ensure
)
inherits sysadmin::params
{
    info ("Configuring sysadmin (login = ${login}, ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("sysadmin 'ensure' parameter must be either absent or present")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include sysadmin::debian }
        redhat, fedora, centos: { include sysadmin::redhat }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: sysadmin::common
#
# Base class to be inherited by the other sysadmin classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class sysadmin::common {

    # Load the variables used in this module. Check the ssh-server-params.pp file
    require sysadmin::params

    include concat::setup

    ############# VARIABLES ###########
    # sysadmin user homedir
    $homedir = "${sysadmin::params::homebasedir}/${sysadmin::login}"
    # main configuration file for sysadmin
    $sysadminrc = "${homedir}/${sysadmin::params::configfilename}"

    ####################################
    # Create the user
    user { "${sysadmin::login}":
        ensure     => "${sysadmin::ensure}",
        allowdupe  => false,
        comment    => 'Local System Administrator',
        home       => "${homedir}",
        managehome => true,
        groups     => $sysadmin::groups,
        shell      => '/bin/bash',
    }

    if $sysadmin::ensure == 'present' {

        file { "${homedir}":
            ensure    => 'directory',
            owner     => "${sysadmin::login}",
            group     => "${sysadmin::login}",
            mode      => "${sysadmin::params::dirmode}",
        }

        # Initialize ssh directory
        file { "${homedir}/.ssh":
            ensure    => 'directory',
            recurse   => true,
            force     => true,
            owner     => "${sysadmin::login}",
            group     => "${sysadmin::login}",
            mode      => "${sysadmin::params::dirmode}",
        }

        # prepare a bin/ directory
        file { "${homedir}/bin":
            ensure    => 'directory',
            owner     => "${sysadmin::login}",
            group     => "${sysadmin::login}",
            mode      => "${sysadmin::params::dirmode}",
        }

        # initialize the configuration file
        concat { "${sysadminrc}":
            owner => "${sysadmin::login}",
            group => "${sysadmin::login}",
            mode  => "${sysadmin::params::filemode}"
        }
        concat::fragment { "sysadminrc_header":
            target  => "${sysadminrc}",
            source  => "puppet:///modules/sysadmin/sysadminrc_header",
            order   => 01,
        }

        concat::fragment { "sysadminrc_footer":
            target  => "${sysadminrc}",
            source  => "puppet:///modules/sysadmin/sysadminrc_footer",
            order   => 99,
        }
    }

}

# ------------------------------------------------------------------------------
# = Class: sysadmin::debian
#
# Specialization class for Debian systems
class sysadmin::debian inherits sysadmin::common { }

# ------------------------------------------------------------------------------
# = Class: sysadmin::redhat
#
# Specialization class for Redhat systems
class sysadmin::redhat inherits sysadmin::common { }



