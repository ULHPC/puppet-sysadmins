# File::      <tt>params.pp</tt>
# Author::    UL HPC Team aka. S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2015 UL HPC Team aka. S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: sysadmins::params
#
# In this class are defined as variables values that are used in other sysadmins classes.
# This class should be included, where necessary, and eventually be enhanced with support
# for more OS
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# The usage of a dedicated param classe is advised to better deal with
# parametrized classes, see
# http://docs.puppetlabs.com/guides/parameterized_classes.html
#
# [Remember: No empty lines between comments and class definition]
#
class sysadmins::params {

    ######## DEFAULTS FOR VARIABLES USERS CAN SET ##########################
    # (Here are set the defaults, provide your custom variables externally)
    # (The default used is in the line with '')
    ###########################################

    # ensure the presence (or absence) of sysadmins
    $ensure = 'present'

    # the actual login used for the local sysadmin account
    $login = 'localadmin'

    # redirect all mails sent to the sysadmin account to this email address
    $email = ''

    # whether to purge the authorized_keys files or not
    $purge_ssh_keys = true

    # whether or not to prevent access to the sysadmin account for non-registered users
    # (via ~<login>/.sysadminrc)
    $filter_access = true

    # Sets the lowest uid (resp. gid) for non system users (resp. groups).
    # This is a system setting and also affects users (resp. groups) created outside of this module.
    $start_uid = undef
    $start_gid = undef

    # Manage the homedir
    $managehome = true

    # Set the resource "user" parameter so that the users are not created/supressed
    # in external user directories (i.e. LDAP).
    $forcelocal = true

    # Hash of the users authorized to connect to the  local sysadmin account
    # i.e. the real users (system administrators).
    $users = {}
    # Additonnal groups the sysadmin user is member of
    $groups = [ ]
    # Hash of the SSH keys.
    $ssh_keys = {}


    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################
    $homebasedir = $::osfamily ?  {
        'Redhat' => '/home',      # Simpler to handle SELinux on Redhat-like systems
        default  => '/var/lib'
    }

    $base_groups = $::osfamily ? {
        'Redhat' => [ 'wheel'],
        'Debian' => [ 'adm' ],
        default  => []
    }

    # $extra_packages = $::operatingsystem ? {
    #     /(?i-mx:ubuntu|debian)/        => [],
    #     /(?i-mx:centos|fedora|redhat)/ => [],
    #     default => []
    # }

    $configdir_mode = $::operatingsystem ? {
        default => '0700',
    }
    # $configdir_owner = $::operatingsystem ? {
    #     default => 'root',
    # }
    # $configdir_group = $::operatingsystem ? {
    #     default => 'root',
    # }

    $configfile = $::operatingsystem ? {
        default => '.sysadminrc',
    }
    $configfile_mode = $::operatingsystem ? {
        default => '0644',
    }

}
