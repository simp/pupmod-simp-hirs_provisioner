# == Class hirs_provisioner::install
#
# This class is called from hirs_provisioner for install.
#
class hirs_provisioner::install {
  assert_private()

  simplib::install { 'hirs_provisioner':
    packages => $hirs_provisioner::_packages,
    defaults => { 'ensure' => $hirs_provisioner::package_ensure }
  }

  file { '/var/log/hirs':
    ensure => directory,
    mode   => '0750'
  }

  file { '/var/log/hirs/provisioner':
    ensure => directory,
    mode   => '0750'
  }

  if $::hirs_provisioner::tpm_version == '2.0' {
    file { '/usr/sbin/hirs-provisioner':
      ensure => 'link',
      target => '/usr/local/bin/hirs-provisioner-tpm2'
    }
  }

}
