# Installs HIRS_Provisioner RPM and configures and registers with HIRS ACA
#
# @param enable_hirs
#   This module will install and mangage HIRS unless `false`
#
# @param package_ensure 
#   The default ensure parameter for packages.
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
  Boolean                          $enable         = true,
  String[1]                        $package_ensure = simplib::lookup('simp_options::package_ensure', {'default_value' => 'installed'}),
  Hash[String,Hash[String,String]] $tpm12_packages = simplib::lookup('hirs_provisioner::tpm12_packages'),
  Hash[String,Hash[String,String]] $tpm2_packages  = simplib::lookup('hirs_provisioner::tpm2_packages'),
) {

  simplib::assert_metadata($module_name)

  if $facts['tpm12_enabled'] {
    $tpm_version = '1.2'
    $_packages = $tpm12_packages
  } elsif $facts['tpm2_enabled'] {
    $tpm_version = '2'
    $_packages = $tpm2_packages
  } else {
    notify { "NOTICE: No enabled TPM device detected in host": }
  }

  if $enable {
    if !defined('$_packages') {
      notify { "NOTICE: No TPM; skipping installation": }
    } else {
      $tpm_enabled = true
      include '::hirs_provisioner::install'
      include '::hirs_provisioner::config'

      Class[ '::hirs_provisioner::install' ]
      -> Class[ '::hirs_provisioner::config' ]
    }
  }
}
