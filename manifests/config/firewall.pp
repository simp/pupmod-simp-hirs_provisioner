# == Class hirs_provisioner::config::firewall
#
# This class is meant to be called from hirs_provisioner.
# It ensures that firewall rules are defined.
#
class hirs_provisioner::config::firewall {
  assert_private()

  # FIXME: ensure your module's firewall settings are defined here.
  iptables::listen::tcp_stateful { 'allow_hirs_provisioner_tcp_connections':
    trusted_nets => $::hirs_provisioner::trusted_nets,
    dports       => $::hirs_provisioner::tcp_listen_port
  }
}
