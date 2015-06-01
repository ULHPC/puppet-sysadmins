# File::      <tt>init.pp</tt>
# Author::    UL HPC Team aka. S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2011-2015 UL HPC Team aka. S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl
# License::   GPL-3.0
#
# ------------------------------------------------------------------------------
# = Class: sysadmins
#
# Configuration of a single system administrator account (localadmin by default) attached to (potentially) several  users
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of sysadmins
#
# == Actions:
#
# Install and configure sysadmins
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     include 'sysadmins'
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'sysadmins':
#             ensure => 'present'
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
class sysadmins(
    $ensure         = $sysadmins::params::ensure,
    $login          = $sysadmins::params::login,
    $email          = $sysadmins::params::email,
    $purge_ssh_keys = $sysadmins::params::purge_ssh_keys,
    $start_uid      = $sysadmins::params::start_uid,
    $start_gid      = $sysadmins::params::start_gid,
    $groups         = $sysadmins::params::groups,
    $users          = $sysadmins::params::users,
    $ssh_keys       = $sysadmins::params::ssh_keys
)
inherits sysadmins::params
{
    info ("Configuring sysadmins (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("sysadmins 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include sysadmins::common::debian }
        redhat, fedora, centos: { include sysadmins::common::redhat }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}



