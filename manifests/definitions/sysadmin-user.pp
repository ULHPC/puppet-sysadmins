# File::      <tt>sysadmin-user.pp</tt> 
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
# 
# Time-stamp: <Fri 2011-08-26 17:31 svarrette>
# ------------------------------------------------------------------------------
# = Define: sysadmin::realuser
#
# Associate to a sysadmin account a 

define sysadmin::realuser($firstname, $name,$email,$sysadmin) {

    include sysadmin::params

    # $name is provided by define invocation
    # guid of this entry
    $key = $name

    $realuserdir = "${sysadmin::params::homebasedir}/${sysadmin}/.ssh/${firstname}.${name}"

    notice("realuserdir = ${realuserdir}")
    
    # Sysadmin[$sysadmin] {
    #     ensure => 'present'        
    # }

    file { "${realuserdir}":
        ensure  => directory,
        owner   => "${sysadmin}",
        group   => "${sysadmin}",
        mode    => '0700',
    }

    file { "${realuserdir}/description.yaml":
        owner  => "${sysadmin}",
        group  => "${sysadmin}",
        mode   => '0640',
        content => template("sysadmin/user_description.erb"),
    }
    
    #ssh_authorized_keys { "${realuserdir}/authorized_keys":
    #    target => "$name",
        
    #}
    
    


    
    
}




