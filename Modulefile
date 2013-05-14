name    'sysadmin'
version '0.1.7'
source  'git-admin.uni.lu:puppet-repo.git'
author  'Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)'
license 'GPL v3'
summary      'Configure a system administrator account for (potentially) several  users'
description  'Configure a system administrator account for (potentially) several  users'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes     'sysadmin::params, sysadmin, sysadmin::common, sysadmin::debian, sysadmin::redhat, sysadmin::mail::aliases'
## List of the definitions defined in this module
definitions 'concat, bash, ssh, common, augeas'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'concat' 
dependency 'bash' 
dependency 'ssh' 
dependency 'common' 
dependency 'augeas' 
