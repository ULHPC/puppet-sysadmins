# File::      <tt>sysadmin-user.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Define: sysadmin::user
#
# Associate to a sysadmin account (see sysadmin) a real user.
# In practice, this will configure the file ~/.sysadminrc accoridingly
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
# [*ensure*]
#   Present/Absent (default: $sysadmin::ensure)
#
# [*notifications*]
#   Wheteher or not to notify the user by mail (i.e. to put is email in /etc/aliases).
#   Default: true
#
# [*sshkeys*]
#   An SSH (public) key associated to the user.
#   It takes the form of hash that SHOULD respect the following format:
#
#          {
#            type    => 'key type',    # encryption type used: 'ssh-dss' or 'ssh-rsa'.
#            key     => 'key content', # The key itself; generally a long string of hex digits.
#            comment => 'comment'      # The SSH key comment. It has to be unique
#          }
#
# == Examples
#
#         # You should have instanciate the class 'sysadmin' somewhere
#         class { 'sysadmin':
#            login  => 'localadmin',
#            ensure => 'present'
#         }
#         [...]
#         # Now you can add a real user, associated to the 'localadmin' account:
#         sysadmin::user{ 'svarrette':
#             firstname => 'Sebastien',
#             lastname  => 'Varrette',
#             email     => 'Sebastien.Varrette@uni.lu',
#             sshkeys   => {
#                             comment => 'key1 comment'
#                             type    => 'ssh-dss',
#                             key     => 'AAAAB3NzQS[...]skjdskf',
#                           }
#         }
#
#         # You can add later another SSH key to this user:
#         sysadmin::user::sshkey{'key2 comment':
#             username => 'svarrette',   # an existing username
#             type     => 'ssh-rsa',
#             key      => 'AAAAB3NzaC1yc.... fxC7+/uTJinSmQ=='
#         }
#
#         # Obviously, you can attach other real users to the 'localadmin' account:
#         sysadmin::user{ 'hcartiaux':
#             firstname => 'Hyacinthe',
#             lastname  => 'Cartiaux',
#             email     => 'Hyacinthe.Cartiaux@uni.lu'
#         }
#
#
define sysadmin::user(
    $firstname,
    $lastname,
    $email,
    $sshkeys = {},
    $ensure = $sysadmin::ensure,
    $notifications = true
)
{

    include sysadmin::params

    # $name is provided by define invocation
    # guid of this entry
    $username = $name

    # first checks
    if (! "${sysadmin::login}") {
        fail("The variable \$sysadmin::login is not set i.e. the class 'sysadmin' is not instancied")
    }

    if ($sysadmin::ensure != $ensure) {
        if ($sysadmin::ensure == 'present') {
            warning(" sysadmin::ensure (value '${sysadmin::ensure}') differs from the ensure parameter ('${ensure}'): the real user '${username}' will be removed")
        }
        else {
            fail("Cannot add the real user '${username}' as sysadmin::ensure is NOT set to present")
        }
    }

    # Let's go
    info("attach user '$firstname $name' to the local sysadmin account '${sysadmin::login}' (with ensure = ${ensure} and notification=${notification})")

    $homedir = $sysadmin::common::homedir

    # complete sysadminrc file
    $sysadminrc = "${homedir}/${sysadmin::params::configfilename}"

    if ($sysadmin::ensure == 'present') {
        concat::fragment { "sysadminrc_adduser_${username}":
            target  => "${sysadminrc}",
            ensure  => "${ensure}",
            content => template("sysadmin/sysadminrc-adduser.erb"),
            order   => 50,
            require => User["${sysadmin::login}"]
        }
    }
    # Eventually add an SSH key
    if $sshkeys != {} {
        #info ("NOT empty sshkeys")
        # Hint by http://jfried83.blogspot.com/2011/06/puppet-iterating-over-hash.html is not working ;(

        # $comment = $sshkeys[comment]
        # $type    = $sshkeys[type]
        # $key     = $sshkeys[key]

        sysadmin::user::sshkey { $sshkeys[comment]:
            username => "${username}",
            type     => $sshkeys[type],
            key      => $sshkeys[key],
            ensure   => $ensure
        }
    }

    # Complete the /etc/aliases files for the '${sysadmin::login}' entry
    # i.e. add this mail to the array of mails
    if ($ensure == 'present') and ($email != '') and ($notifications) {
        notice("adding ${email} to the mailist [ $sysadmin::params::maillist ]")
        $sysadmin::params::maillist += "${email}"
    }
    # here the 'localadmin' entry contains only 'none' value
    # for some reason, the 'onlyif' directive fail (whereas it works in augtool)
    # I kept the entry for historical reason
    # augeas { "/etc/aliases/${sysadmin::login}/none changed to ${email}":
    #     context => '/files/etc/aliases',
    #     onlyif  => "match *[name = '${sysadmin::login}' and count(value)=1]/value == [ 'none' ]",
    #     changes => "set   *[name = '${sysadmin::login}' and value='none']/value '${email}'",
    #     #notify  => Mailalias['root'],
    #     require => Exec["mailalias ${sysadmin::login}"]
    # }


}


# ------------------------------------------------------------------------------
# = Define: sysadmin::user::sshkey
#
# Configure an additionnal SSH key under the account ${sysadmin::login} for the
# user 'username'
# In practice, this will add an entry to ~${sysadmin::login}/.ssh/authorized_keys
# as follows:
#
#      environment="SYSADMIN_USER=<username>" <type> <key> <comment>
#
# the environment variable is important because it helps to identify who logged
# on the ${sysadmin::login} account. You'll notice that each connection is log
# in /var/log/auth.log as follows:
#
#   <date> <hostname> <sysadminlogin>[xxx]: local sysadmin logged from <ip> port <port> is <username>
#
# == Pre-requisites
#
# * The class 'sysadmin' should have been instanciated
# * The user 'username' should have been configured and attached to this account
#   via sysadmin::user
#
# == Parameters
#
# [*username*]
#  An existing username (NOT a valid login!) of the user associated to this SSH
#  key.
#
# [*type*]
#   encryption type used: 'ssh-dss' or 'ssh-rsa'.
#
# [*key*]
#   The key itself; generally a long string of hex digits.
#
# [*ensure*]
#   Present/Absent (default: $sysadmin::ensure)

# == Name
#
# the name you will associate to sysadmin::user::sshkey will become the SSH key
# comment. It has therefore to be unique
#
# == Examples
#
#         # You should have instanciate the class 'sysadmin' somewhere
#         class { 'sysadmin':
#            login  => 'localadmin',
#            ensure => 'present'
#         }
#         [...]
#         # you should have added a real user, associated to the 'localadmin' account:
#         sysadmin::user{ 'svarrette':
#             firstname => 'Sebastien',
#             lastname  => 'Varrette',
#             email     => 'Sebastien.Varrette@uni.lu',
#
#         # Now you can add an SSH key to this user:
#         sysadmin::user::sshkey{'svarrette@falkormacbook2.uni.lux':
#             username => 'svarrette',
#             type     => 'ssh-rsa',
#             key      => 'AAAAB3NzaC1yc.... fxC7+/uTJinSmQ=='
#         }
#
define sysadmin::user::sshkey(
    $username,
    $type,
    $key,
    $ensure = $sysadmin::ensure
)
{

    # $name is provided by define invocation
    # guid of this entry
    $comment = $name

    if (! "${sysadmin::login}") {
        fail("The variable \$sysadmin::login is not set i.e. the class 'sysadmin' is not instancied")
    }

    if ($sysadmin::ensure != $ensure) {
        if ($sysadmin::ensure == 'present') {
            warning(" sysadmin::ensure (value '${sysadmin::ensure}') differs from the ensure parameter ('${ensure}'): the key '${comment}' will be removed")
        }
        else {
            fail("Cannot add the SSH key '${comment}' as sysadmin::ensure is NOT set to present")
        }
    }

    # TODO: ensure username exists!
    info ("Manage SSH key for the real user '${username}'  (type = ${type}; comment = ${comment}; ensure = ${ensure})")
    ssh_authorized_key { "${comment}":
        ensure  => $ensure,
        type    => "${type}",
        key     => "${key}",
        user    => "${sysadmin::login}",
        options => "environment=\"SYSADMIN_USER=${username}\" ",
        require => [
                    Class['ssh::server']
                    ]
        #        target  => "${usersdir}/${username}_authorized_keys",
        #        require => File["${usersdir}"]
    }

}

