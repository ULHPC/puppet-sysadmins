name       'sysadmin'
version    '0.1.4'
source     'git-admin.uni.lu:puppet-repo.git'
author     'Sebastien Varrette (Sebastien.Varrette@uni.lu)'
license    'GPL v3'
summary    'Configure a system administrator account for (potentially) several  users'
description 'Configure a system administrator account for (potentially) several  users'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes    'sysadmin::params, sysadmin, sysadmin::common, sysadmin::debian, sysadmin::redhat, sysadmin::mail::aliases'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'concat'
dependency 'bash'
dependency 'ssh'
dependency 'common'
dependency 'augeas'
defines    '["sysadmin::user", "sysadmin::user::sshkey"]'
