# == Class hirs_provisioner::config
#
# This class is called from hirs_provisioner for service config.
#
# @param aca_fqdn
#   The fully qualified domain name of the Attestation Certificate Authority
#   (ACA). This will also be used for the Broker and Portal FQDNs.
#
# @param aca_port
#   The configured listening port for the ACA.
#
# @param broker_port
#   The configured broker listening port for the ACA.
#
# @param portal_port
#   The configured portal listening port for the ACA.
#
class hirs_provisioner::config (
  Simplib::Hostname $aca_fqdn    = 'localhost',
  Simplib::Port     $aca_port    = 8443,
  Simplib::Port     $broker_port = 61616,
  Simplib::Port     $portal_port = 8443
) {
  assert_private()

  exec {
    # generate hirs-site.config
    'hirs-provision-config':
      command => '/usr/sbin/hirs-provisioner -c',
      onlyif  => '/usr/bin/test ! -f /etc/hirs/hirs-site.config'
  } ->

  file_line {

    # set CLIENT_HOSTNAME
    'client-hostname':
      path  => '/etc/hirs/hirs-site.config',
      line  => 'CLIENT_HOSTNAME=$HOSTNAME',
      match => "^CLIENT_HOSTNAME=.*$";

    # set TPM_ENABLED
    'tpm-enabled':
      path  => '/etc/hirs/hirs-site.config',
      line  => "TPM_ENABLED=$::hirs_provisioner::_tpm_enabled",
      match => "^TPM_ENABLED=.*$";

    # set IMA_ENABLED
    'ima-enabled':
      path  => '/etc/hirs/hirs-site.config',
      line  => "IMA_ENABLED=${facts['cmdline']['ima'] == 'on'}",
      match => "^IMA_ENABLED=.*$";

    # set ATTESTATION_CA_FQDN
    'aca-fqdn':
      path  => '/etc/hirs/hirs-site.config',
      line  => "ATTESTATION_CA_FQDN=$aca_fqdn",
      match => "^ATTESTATION_CA_FQDN=.*$";

    # set ATTESTATION_CA_Port
    'aca-port':
      path  => '/etc/hirs/hirs-site.config',
      line  => "ATTESTATION_CA_PORT=$aca_port",
      match => "^ATTESTATION_CA_PORT=.*$";

    # set BROKER_FQDN
    'broker-fqdn':
      path  => '/etc/hirs/hirs-site.config',
      line  => "BROKER_FQDN=$aca_fqdn",
      match => "^BROKER_FQDN=.*$";

    # set BROKER_PORT
    'broker-port':
      path  => '/etc/hirs/hirs-site.config',
      line  => "BROKER_PORT=$broker_port",
      match => "^BROKER_PORT=.*$";

    # set PORTAL_FQDN
    'portal-fqdn':
      path  => '/etc/hirs/hirs-site.config',
      line  => "PORTAL_FQDN=$aca_fqdn",
      match => "^PORTAL_FQDN=.*$";

    # set PORTAL_PORT
    'portal-port':
      path  => '/etc/hirs/hirs-site.config',
      line  => "PORTAL_PORT=$portal_port",
      match => "^PORTAL_PORT=.*$"

  } ~>

  # provision hirs client
  if $::hirs_provisioner::tpm_version == '2.0' {
    exec {
      'hirs-provision-client':
        command     => '/usr/sbin/hirs-provisioner-tpm2 provision',
        refreshonly => true;
    }
  } else {
    exec { 
      'hirs-provision-client':
        command     => '/usr/sbin/hirs-provisioner provision',
        refreshonly => true;
    }
  }
}
