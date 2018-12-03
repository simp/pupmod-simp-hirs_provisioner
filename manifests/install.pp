# == Class hirs_provisioner::install
#
# This class is called from hirs_provisioner for install.
#
class hirs_provisioner::install {
  assert_private()

  $$::hirs_provisioner::packages.each | $pkg_name, $parameters | {
    $_ensure = defined('$parameters["ensure"]' ? {
      true    => regsubst($parameters["ensure"], '^package_ensure$', $hirs_provisioner::package_ensure ),
      default => hirs_provisioner::package_ensure,
    }

    package { $pkg_name:
      ensure => $_ensure,
    }
  }
}
