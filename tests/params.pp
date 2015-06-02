# File::      <tt>params.pp</tt>
# Author::    UL HPC Team aka. S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2015 UL HPC Team aka. S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# You need the 'future' parser to be able to execute this manifest (that's
# required for the each loop below).
#
# Thus execute this manifest in your vagrant box as follows:
#
#      sudo puppet apply -t --parser future /vagrant/tests/params.pp
#
#

include 'sysadmins::params'

$names = ['ensure', 'login', 'email', 'purge_ssh_keys', 'filter_access', 'users', 'groups', 'ssh_keys', 'homebasedir', 'base_groups', 'configdir_mode', 'configfile', 'configfile_mode']

notice("sysadmins::params::ensure = ${sysadmins::params::ensure}")
notice("sysadmins::params::login = ${sysadmins::params::login}")
notice("sysadmins::params::email = ${sysadmins::params::email}")
notice("sysadmins::params::purge_ssh_keys = ${sysadmins::params::purge_ssh_keys}")
notice("sysadmins::params::filter_access = ${sysadmins::params::filter_access}")
notice("sysadmins::params::users = ${sysadmins::params::users}")
notice("sysadmins::params::groups = ${sysadmins::params::groups}")
notice("sysadmins::params::ssh_keys = ${sysadmins::params::ssh_keys}")
notice("sysadmins::params::homebasedir = ${sysadmins::params::homebasedir}")
notice("sysadmins::params::base_groups = ${sysadmins::params::base_groups}")
notice("sysadmins::params::configdir_mode = ${sysadmins::params::configdir_mode}")
notice("sysadmins::params::configfile = ${sysadmins::params::configfile}")
notice("sysadmins::params::configfile_mode = ${sysadmins::params::configfile_mode}")

#each($names) |$v| {
#    $var = "sysadmins::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}
