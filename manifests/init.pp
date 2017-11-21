# NFS class
class nfs (
  String $nfs_v4_idmap_domain       = pick($::domain, 'example.org'),
  Stdlib::Absolutepath $idmapd_file = '/etc/idmapd.conf',
) {

  # This module is accessed via the nfs::server and nfs::client
  # classes.

}
