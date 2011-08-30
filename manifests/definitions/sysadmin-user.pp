# File::      <tt>sysadmin-user.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Define: sysadmin::user
#
# Associate to a sysadmin account (see sysadmin) a real user.
#
# == Pre-requisites
#
# * The class 'sysadmin' should have been instanciated
# * the parameter 'ensure' of this class should have been set to 'present'
#
# == Parameters
#
# [*firstname*]
#  Firstname of the user. Ex: Sebastien
#
# [*lastname*]
#   Last Name of the user. Ex: Varrette
#
# [*email*]
#   Email of the user. Ex: Sebastien.Varrette@uni.lu
#
# [*sshkeys*]
#   A List of SSH (public) keys associated to the user.
#   It takes the form of an array of hashes, each hash having the following format:
#
#          {
#            type    => 'key type',    # encryption type used: 'ssh-dss' or 'ssh-rsa'.
#            key     => 'key content', # The key itself; generally a long string of hex digits.
#            comment => 'comment'      # The SSH key comment. It has to be unique
#          }
#
# == Examples
#
#         # You should instanciate the class 'sysadmin'
#         class { 'sysadmin':
#            ensure => 'present'
#         }
#         [...]
#         sysadmin::user{ 'svarrette':
#             firstname => 'Sebastien',
#             lastname  => 'Varrette',
#             email     => 'Sebastien.Varrette@uni.lu',
#             sshkeys   => [
                            # {
                            #   type    => 'ssh-dss',
                            #   key     => 'AAAAB3NzQS[...]skjdskf',
                            #   comment => 'key1 comment'
                            # },
                            # {
                            #   type    => 'ssh-dss',
                            #   key     => 'AAAAB3NzQS[...]skjdskf',
                            #   comment => 'key2 comment'
                            # }
                            #]
#         }
#
define sysadmin::user($firstname, $lastname, $email, $sshkeys = {}) {

    include sysadmin::params

    # $name is provided by define invocation
    # guid of this entry
    $username = $name

    # first checks
    if (! "${sysadmin::login}") {
        fail("The variable \$sysadmin::login is not set i.e. the class 'sysadmin' is not instancied")
    }
    if ($sysadmin::ensure != 'present') {
        fail("Cannot add the real user '${username}' as sysadmin::ensure is NOT set to present")
    }

    # Let's go
    info("attach user '$firstname $name' to the local sysadmin account '${sysadmin::login}'")

    $homedir = $sysadmin::common::homedir
    $usersdir = "${homedir}/${sysadmin::params::realuserdir}"

    file { "${usersdir}":
        ensure    => 'directory',
        recurse   => true,
        force     => true,
        owner     => "${sysadmin::login}",
        group     => "${sysadmin::login}",
        mode      => '0700',
        purge     => true,
        require   => User["${sysadmin::login}"]
    }

    file { "${usersdir}/${username}.yaml":
        owner  => "${sysadmin::login}",
        group  => "${sysadmin::login}",
        mode   => '0640',
        content => template("sysadmin/user_description.erb"),
        require => File["${usersdir}"]
    }

    # sysadminrc file
    $SYSADMIN_LIST = {
        "${username}" => {
            firstname => "${firstname}",
            lastname  => "${lastname}",
            email     => "${email}"
        }     
    }
    
    file { "${homedir}/.sysadminrc":
        ensure    => "${sysadmin::ensure}",
        owner     => "${sysadmin::login}",
        group     => "${sysadmin::login}",
        mode      => "${sysadmin::params::configfile_mode}",
        content   => template("sysadmin/sysadminrc.erb"),
    }



    if $sshkeys != {} {
        info ("NOT empty sshkeys")
        # Hint by http://jfried83.blogspot.com/2011/06/puppet-iterating-over-hash.html
        # $hashtest = {
        #     'key1' => 'val1',
        #     'key2' => 'val2'
        # }


    }
}

define sysadmin::user::sshkey($username, $type, $key) {
    $comment = $name

    $usersdir = "${sysadmin::common::homedir}/${sysadmin::params::realuserdir}"

    info ("Manage SSH key for the real user '${username}'  (type = ${type}; comment = ${comment})")
    ssh_authorized_key { "${comment}":
        ensure  => $sysadmin::ensure,
        type    => "${type}",
        key     => "${key}",
        user    => "${sysadmin::login}",
        #        target  => "${usersdir}/${username}_authorized_keys",
        #        require => File["${usersdir}"]
    }



}






