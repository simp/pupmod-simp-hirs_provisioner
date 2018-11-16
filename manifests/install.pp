# == Class hirs_provisioner::install
#
# This class is called from hirs_provisioner for install.
#
class hirs_provisioner::install {
  assert_private()

  package { $::hirs_provisioner::package_name:
    ensure => present
  }
}
