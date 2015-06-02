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

$names = ['ensure', 'protocol', 'port', 'packagename']

notice("sysadmins::params::ensure = ${sysadmins::params::ensure}")
notice("sysadmins::params::protocol = ${sysadmins::params::protocol}")
notice("sysadmins::params::port = ${sysadmins::params::port}")
notice("sysadmins::params::packagename = ${sysadmins::params::packagename}")

#each($names) |$v| {
#    $var = "sysadmins::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}
