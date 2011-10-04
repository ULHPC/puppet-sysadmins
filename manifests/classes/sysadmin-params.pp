# File::      <tt>sysadmin-params.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
# ------------------------------------------------------------------------------
# = Class: sysadmin::params
#
# In this class are defined as variables values that are used in other
# sysadmin classes.
# This class should be included, where necessary, and eventually be enhanced
# with support for more OS
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
class sysadmin::params {

    ######## DEFAULTS FOR VARIABLES USERS CAN SET ##########################
    # (Here are set the defaults, provide your custom variables externally)
    # (The default used is in the line with '')
    ###########################################

    # the actual login used for the account
    $login = $sysadmin_login ? {
        ''      => 'localuser',
        default => "${sysadmin_login}",
    }

    # Additonnal groups the above user is member of
    $groups = $sysadmin_groups ? {
        ''      => [ ],
        default => $sysadmin_groups
    }

    # The list of users authorized to connect to the above local account
    # i.e. the real users (system administrators) identified by their respective
    # directory (under files/users/)
    $members = $localsysadmin_members ? {
        ''      => [ 'svarrette', 'hcartiaux' ],
        default => $sysadmin_members
    }

    # ensure attribute ('present' or 'absent')
    $ensure = $sysadmin_ensure ? {
        ''      => 'present',
        default => "${sysadmin_ensure}"
    }



    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################
    $homebasedir = "/var/lib"

    $maillist = []
    
    # Main configuration file (relative to the homedir)
    $configfilename = ".sysadminrc"


    $dirmode = $::operatingsystem ? {
        default => '0700',
    }

    $filemode = $::operatingsystem ? {
        default => '0644',
    }

    $utils_packages = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/	=> [
                                    'apticron',
                                    'logcheck', 'logcheck-database'
                                    ],
        default => []
    }

    # $configfile = $::operatingsystem ? {
    #     default => '/path/to/sysadmin.conf',
    # }


    # $configfile_owner = $::operatingsystem ? {
    #     default => 'root',
    # }

    # $configfile_group = $::operatingsystem ? {
    #     default => 'root',
    # }

    # $configdir = $::operatingsystem ? {
    #     default => "/etc/ssh",
    # }

    # $configdir_owner = $::operatingsystem ? {
    #     default => 'root',
    # }

    # $configdir_group = $::operatingsystem ? {
    #     default => 'root',
    # }



}

