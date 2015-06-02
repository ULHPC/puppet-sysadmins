# File::      <tt>common.pp</tt>
# Author::    UL HPC Team aka. S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2011-2015 UL HPC Team aka. S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl
# License::   GPL-3.0
#
# ------------------------------------------------------------------------------
# = Class: sysadmins::common
#
# Base class to be inherited by the other sysadmins classes, containing the common code.
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]

class sysadmins::common {

    # Load the variables used in this module. Check the params.pp file
    require sysadmins::params

    ############# VARIABLES ###########
    # sysadmin user homedir
    $homedir = "${sysadmins::params::homebasedir}/${sysadmins::login}"
    # main configuration file for sysadmin
    $sysadminrc = "${homedir}/${sysadmins::params::configfile}"
    # Merge default groups with the provided onces
    $sysgroups = unique(flatten([ $::sysadmins::params::base_groups, $::sysadmins::groups ]))
    # prepare the hash for the SSH keys
    # * restrict to the SSH keys having a key matching the users listed in sysadmins::users
    $auth_keys = parseyaml(inline_template('<%= scope.lookupvar("sysadmins::ssh_keys").select { |k,v| scope.lookupvar("sysadmins::users").keys.find{ |e| k =~ /^#{e}/ } }.to_yaml %>'))
    # * specialize the options field for these SSH keys
    $real_ssh_keys = parseyaml(inline_template('<%= @auth_keys.each{ |k,v| v["options"] = "environment=\"SYSADMIN_USER=#{k.gsub(/@.*/, "")}\" "}.to_yaml %>'))
    notice($real_ssh_keys)

    $real_users = {
        "${sysadmins::login}" =>
        {
            ensure         => $::sysadmins::ensure,
            comment        => 'Local System Administrator',
            home           => $homedir,
            shell          => '/bin/bash',
            groups         => $sysgroups, #$::sysadmins::params::base_groups,
            purge_ssh_keys => $::sysadmins::purge_ssh_keys,
        }
    }

    # Create the user using camptocamp/account
    class { 'accounts':
        users          => $real_users,
        ssh_keys       => $real_ssh_keys,
        purge_ssh_keys => $::sysadmins::purge_ssh_keys,
    }

    accounts::account{ $sysadmins::login:
        authorized_keys => keys($real_ssh_keys) #$auth_keys)
    }

    # Initialize bash
    include bash

    bash::setup { $homedir:
        ensure  => $sysadmins::ensure,
        user    => $sysadmins::login,
        group   => $sysadmins::login,
        require => Accounts::Account[$::sysadmins::login]
    }

    $bash_source_sysadminrc_ensure = $sysadmins::filter_access ? {
        true    => $sysadmins::ensure,
        default => 'absent'
    }

    bash::config { 'sysadminrc':
        ensure      => $bash_source_sysadminrc_ensure,
        warn        => true,
        before_hook => true,
        rootdir     => $homedir,
        owner       => $sysadmins::login,
        group       => $sysadmins::login,
        content     => inline_template("
        # Read sysadmin configuration
        if [ -f \"\$HOME/<%= scope.lookupvar('sysadmins::params::configfile') %>\" ]; then
        .  ~/<%= scope.lookupvar('sysadmins::params::configfile') %>
        fi
        "),
    }


    # initialize the configuration file
    concat { $sysadminrc:
        owner   => $sysadmins::login,
        group   => $sysadmins::login,
        mode    => $sysadmins::params::configfile_mode,
        require => Accounts::Account[$::sysadmins::login]
    }
    concat::fragment { 'sysadminrc_header':
        target => $sysadminrc,
        source => "puppet:///modules/${module_name}/sysadminrc_header",
        order  => 01,
    }

    concat::fragment { 'sysadminrc_footer':
        target => $sysadminrc,
        source => "puppet:///modules/${module_name}/sysadminrc_footer",
        order  => 99,
    }

    # Add the sysadmin to the sudoers file
    include sudo
    sudo::directive { "${sysadmins::login}_in_sudoers":
        content => "${sysadmins::login}    ALL=(ALL)   NOPASSWD:ALL\n",
    }

    if $sysadmins::ensure == 'present' {
        exec { "Lock the password of the ${sysadmins::login} account":
            path    => '/sbin:/usr/bin:/usr/sbin:/bin',
            command => "passwd --lock ${sysadmins::login}",
            unless  => "passwd -S ${sysadmins::login} | grep '^${sysadmins::login} L'",
            user    => 'root',
            require => Accounts::Account[$::sysadmins::login]
        }
    }
    else {
        # Unlock the root account
        exec { "Unlock the password of the ${sysadmins::login} account":
            path    => '/sbin:/usr/bin:/usr/sbin:/bin',
            command => "passwd --unlock ${sysadmins::login}",
            onlyif  => "passwd -S ${sysadmins::login} | grep '^${sysadmins::login} L'",
            user    => 'root'
        }
    }



}
