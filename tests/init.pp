# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# You can execute this manifest as follows in your vagrant box
#
#      sudo puppet apply -t /vagrant/tests/init.pp
#
node default {
    include 'bash'
    sudo::directive { 'vagrant':
        content => "vagrant    ALL=(ALL)   NOPASSWD:ALL\n",
    }
    
    class { 'sysadmins':
        ensure         => 'present',
        filter_access  => false,
        groups         => [ 'vagrant' ],   # can be a string
        users          => hiera_hash('sysadmins::users', {}),
        ssh_keys       => hiera_hash('sysadmins::ssh_keys', {}),
        purge_ssh_keys => true,
    }
}
