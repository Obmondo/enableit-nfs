# == Class: nfs::server
#
# Installs the NFS server software, allowing usage of the nfs::export
# resource type.
#
# === Variables
#
# This module requires no variables.
#
# === Examples
#
#  class { 'nfs::server':
#    ensure => true,
#    enable => true,
#  }

# === Authors
# - Rune Juhl Jacobsen <runejuhl@enableit.dk>
#
# Module based on work by:
#  - Joseph Beard <joseph@josephbeard.net>
#
# === Copyright
#
# Copyright 2014 Joseph Beard
#
class nfs::server (
  Boolean $ensure                                  = true,
  Boolean $enable                                  = true,
  Boolean $manage_firewall                         = true,
  String $service_name,         # provided by hiera
  Array[String] $packages,      # provided by hiera
  Array[String] $additional_services               = [],
  Array[String] $rpc_nfsd_args                     = [],
  Array[String] $rpc_mountd_opts                   = [],
  Array[String] $rpc_statd_args                    = [],
  Array[String] $lockd_args                        = [],
  Integer[0, default] $rpc_nfsd_count              = 8,
  Integer[0, default] $nfsd_v4_grace               = 90,
  Integer[0, default] $nfsd_v4_lease               = 90,
  Nfs::Port $nfs_port                              = 2049,
  Nfs::Port $rpcbind_port                          = 111,
  Nfs::Port $mountd_port                           = 892,
  Nfs::Port $statd_port                            = 662,
  Optional[Nfs::Port] $statd_outgoing_port         = 2020,
  Optional[Nfs::Port] $lockd_tcp_port              = 32803,
  Optional[Nfs::Port] $lockd_udp_port              = 32769,
  Boolean $gss_use_proxy                           = true,
  Array[String] $sm_notify_args                    = [],
  Array[String] $rpc_idmapd_args                   = [],
  Array[String] $rpc_gssd_args                     = [],
  Array[String] $rpc_svcgssd_args                  = [],
  Array[String] $rpc_blkmapd_args                  = [],
  Optional[Stdlib::AbsolutePath] $statd_ha_callout = undef,
  Optional[Array[String]] $listen_interfaces       = undef,
) {

  unless ($facts['os']['family'] in ['RedHat', 'Debian']) {
    fail('nfs::server not supported')
  }

  package { $packages:
    ensure => $ensure,
    before => Class['::nfs::server::config'],
  }

  class { '::nfs::server::config':
    ensure => $ensure,
  }

  service { $service_name:
    ensure  => $ensure,
    enable  => $enable,
    require => [
      Class['::nfs::server::config'],
      Service[$additional_services],
    ],
  }

  if $manage_firewall {
    $_interfaces = pick($listen_interfaces, $facts['networking']['primary'])

    ['tcp', 'udp'].map |$proto| {
      firewall {
        default:
          action  => accept,
          iniface => $_interfaces,
          ;

        "000 allow nfs ${proto}":
          dport => [$mountd_port, $statd_port, $nfs_port, $rpcbind_port],
          proto => $proto,
          ;

        "000 allow nfs lockd ${proto}":
          dport => $lockd_tcp_port,
          proto => $proto,
          ;

      }
    }
  }
}
