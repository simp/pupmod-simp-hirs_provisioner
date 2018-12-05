# == Class hirs_provisioner::config
#
# This class is called from hirs_provisioner for service config.
#
class hirs_provisioner::config {
  assert_private()

  exec {
    # generate hirs-site.config
    'hirs-provision-config':
      command => '/usr/sbin/hirs-provisioner -c',
      onlyif  => '/usr/bin/test ! -f /etc/hirs/hirs-site.config';
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
      line  => "TPM_ENABLED=$::tpm_enabled",
      match => "^TPM_ENABLED=.*$";

    # set IMA_ENABLED
    'ima-enabled':
      path  => '/etc/hirs/hirs-site.config',
      line  => "IMA_ENABLED=$::ima_enabled",
      match => "^IMA_ENABLED=.*$";

    # set ATTESTATION_CA_FQDN
    'aca-fqdn':
      path  => '/etc/hirs/hirs-site.config',
      line  => "ATTESTATION_CA_FQDN=$aca_fqdn",
      match => "^ATTESTATION_CA_FQDN=.*$";

    # set BROKER_FQDN
    'broker-fqdn':
      path  => '/etc/hirs/hirs-site.config',
      line  => "BROKER_FQDN=$broker_fqdn",
      match => "^BROKER_FQDN=.*$";

    # set PORTAL_FQDN
    'portal-fqdn':
      path  => '/etc/hirs/hirs-site.config',
      line  => "PORTAL_FQDN=$portal_fqdn",
      match => "^PORTAL_FQDN=.*$";

  } ~>

  exec {

    # provision hirs client
    'hirs-provision-client':
      command     => '/usr/sbin/hirs-provisioner -p',
      refreshonly => true;
  }

}
