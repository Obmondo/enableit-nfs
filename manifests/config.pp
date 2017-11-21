class nfs::config {
 augeas { $::nfs::idmapd_file:
   context => "/files/${::nfs::idmapd_file}/General",
   lens    => 'Puppet.lns',
   incl    => $::nfs::idmapd_file,
   changes => ["set Domain ${::nfs::server::nfs_v4_idmap_domain}"],
 }
}
