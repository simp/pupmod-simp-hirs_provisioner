# Full description of SIMP module 'hirs_provisioner' here.
#
# === Welcome to SIMP!
#
# This module is a component of the System Integrity Management Platform, a
# managed security compliance framework built on Puppet.
#
# ---
# *FIXME:* verify that the following paragraph fits this module's characteristics!
# ---
#
# This module is optimally designed for use within a larger SIMP ecosystem, but
# it can be used independently:
#
# * When included within the SIMP ecosystem, security compliance settings will
#   be managed from the Puppet server.
#
# * If used independently, all SIMP-managed security subsystems are disabled by
#   default, and must be explicitly opted into by administrators.  Please
#   review the +trusted_nets+ and +$enable_*+ parameters for details.
#
# @param enable_hirs
#   This module will install and mangage HIRS unless `false`
#
# @param package_ensure 
#   The dedefault ensure parameter for packages.
#
# @param tpm12_packages
#   A hash of packages needed for HIRS with TPM 1.2.  The hash format is:
#
#        ```yaml
#        <package_name>':
#           ensure: <ensure_value>
#        ```     
#
# @param tpm20_packages
#   A hash of packages needed for HIRS with TPM 2.0.  The hash format is:
#
#        ```yaml
#        <package_name>':
#           ensure: <ensure_value>
#        ```     
#
# @author SIMP Team <https://simp-project.com/>
#
class hirs_provisioner (
  Boolean                          $enable_hirs        = true,
  String                           $package_ensure     = simplib::lookup('simp_options::package_ensure', {'default_value' => 'installed'}),
  Hash[String,Hash[String,String]] $tpm12_packages     = simplib::lookup('hirs_provisioner::tpm12_packages'),
  Hash[String,Hash[String,String]] $tpm20_packages     = simplib::lookup('hirs_provisioner::tpm20_packages'),
) {

  simplib::assert_metadata($module_name)

  if defined('$facts["tpm_version"]') and $facts['tpm_version' == 'tpm1'] {
    tpm_version = "12"
  } elsif defined('$facts["tpm2"]) {
    tpm_version = "20"
  } else {
    notify { "NOTICE: No enabled TPM device detected in host": }
  }

  if $enable_hirs {
    if !defined($tpm_version) {
      notify { "NOTICE: No TPM; skipping installation": }
    } else {
      $$::hirs_provisioner::packages = $$::hirs_provision::tpm${tpm_version}_packages
      include '::hirs_provisioner::install'
      include '::hirs_provisioner::config'

      Class[ '::hirs_provisioner::install' ]
      -> Class[ '::hirs_provisioner::config' ]

      exec {
        # provision hirs client
        'hirs-provision-client':
          command     => '/usr/sbin/hirs-provisioner -p',
          refreshonly => true;
      }
    }
  }
}
