#/etc/puppet/modules/dist_archive_asf/manifests/init.pp

class dist_archive_asf (
  $uid           = 1025,
  $gid           = 1025,
  $group_present = 'present',
  $groupname     = 'archive',
  $groups        = [],
  $shell         = '/bin/bash',
  $user_present  = 'present',
  $username      = 'archive',
  $archiveroot   = '/var/www/archive.apache.org',
  $rsync_server  = 'rsync.apache.org',
) {

  
   user { "${username}":
        name       => "${username}",
        ensure     => "${user_present}",
        home       => "/home/${username}",
        shell      => "${shell}",
        uid        => "${uid}",
        gid        => "${groupname}",
        groups     => $groups,
        managehome => true,
        require    => Group["${groupname}"],
    }

    group { "${groupname}":
        name   => "${groupname}",
        ensure => "${group_present}",
        gid    => "${gid}",
    }

    file { 'archive profile': 
        path    => "/home/${username}/.profile",
        ensure  => 'present',
        mode    => '0644',
        owner   => "${username}",
        group   => "${groupname}",
        source  => 'puppet:///modules/dist_archive_asf/home/profile',
        require => User["${username}"],
    }
    
     file { 'archive root':
        ensure => directory,
        path => "${archiveroot}",
        mode   => 0755,
        owner  => "${username}",
        group  => "${groupname}",
    }
    
    file { 'archive dist dir':
        ensure => directory,
        path => "${archiveroot}/dist",
        mode   => 0755,
        owner  => "${username}",
        group  => "${groupname}",
    }
    
    file { 'archive front page': 
        path    => "${archiveroot}/index.html",
        ensure  => 'present',
        mode    => '0644',
        owner   => "${username}",
        group   => "${groupname}",
        source  => 'puppet:///modules/dist_archive_asf/index.html',
        require => User["${username}"],
    }
       
    
    rsync::get { "${archiveroot}/dist":
      source  => "rsync://${rsync_server}/apache-dist-for-archive/",
      require => File["${archiveroot}/dist"],
      chown => "${username}:${groupname}",
    }
    
    
}
