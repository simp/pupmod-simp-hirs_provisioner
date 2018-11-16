# == Class hirs_provisioner::service
#
# This class is meant to be called from hirs_provisioner.
# It ensure the service is running.
#
class hirs_provisioner::service {
  assert_private()

  service { $::hirs_provisioner::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true
  }
}
