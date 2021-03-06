# NFS config
class nfs::server::config (
  Boolean $ensure = true,
  Stdlib::AbsolutePath $defaults_path, # from hiera
) {

  file { $defaults_path:
    ensure  => if $ensure { 'file' } else { 'absent' },
    content => epp('nfs/nfs.conf.epp'),
    notify  => Service[$::nfs::server::service_name],
  }

  concat { '/etc/exports':
    ensure => if $ensure { 'present' } else { 'absent' },
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    warn   => true,
    notify => Service[$::nfs::server::service_name],

  }
}
