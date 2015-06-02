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
    $ensure = $::sysadmins_ensure ? {
        ''      => 'present',
        default => $::sysadmins_ensure
    }

    # the actual login used for the local sysadmin account
    $login = $::sysadmins_login ? {
        ''      => 'localadmin',
        default => $::sysadmins_login,
    }

    # redirect all mails sent to the sysadmin account to this email address
    $email = $::sysadmins_email ? {
        ''      => '',
        default => $::sysadmin_email
    }

    # whether to purge the authorized_keys files or not 
    $purge_ssh_keys = $::sysadmins_purge_ssh_keys ? {
        ''      => false,
        default => $::sysadmins_purge_ssh_keys
    }

    # whether or not to prevent access to the sysadmin account for non-registered users
    # (via ~<login>/.sysadminrc)
    $filter_access = $::sysadmins_filter_access ? {
        ''      => true,
        default => $::sysadmins_filter_access
    }

    # # start uid / gid
    # $start_uid = $::sysadmins_start_uid {
    #     ''      => undef,
    #     default => $::sysadmins_start_uid
    # }
    # $start_gid = $::sysadmins_start_gid {
    #     ''      => undef,
    #     default => $::sysadmins_start_gid 
    # }
    
    # Hash of the users authorized to connect to the  local sysadmin account
    # i.e. the real users (system administrators). 
    $users = {}
    # Additonnal groups the sysadmin user is member of
    $groups = $::sysadmins_groups ? {
        ''      => [ ],
        default => $::sysadmins_groups
    }
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

