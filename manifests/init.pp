# @summary Installs HIRS_Provisioner RPM and configures and registers with HIRS ACA
#
# @param enable
#   This module will install and mangage HIRS unless `false`
#
# @param package_ensure
#   The default ensure parameter for packages.
#
# @param tpm_1_2_packages
#   A hash of packages needed for HIRS with TPM 1.2.
#
#   * NOTE: Setting this will *override* the default package list
#   * The ensure value can be set in the hash of each package, like the example
#     below:
#
#   Example: Override packages
#   ```
#   { 'HIRS_Provisioner' => { 'ensure' => '3.14.3' } }
#   ```
#
# @param tpm_2_0_packages
#   A hash of packages needed for HIRS with TPM 2.0.
#
# @author SIMP Team <https://simp-project.com/>
#
class hirs_provisioner (
  Boolean                         $enable           = true,
  String[1]                       $package_ensure   = simplib::lookup('simp_options::package_ensure', {'default_value' => 'installed'}),
  Hash[String[1], Optional[Hash]] $tpm_1_2_packages = { 'HIRS_Provisioner_TPM_1_2' => {} },
  Hash[String[1], Optional[Hash]] $tpm_2_0_packages = { 'HIRS_Provisioner_TPM_2_0' => {} }
) {

  simplib::assert_metadata($module_name)

  if $facts['hirs_tpm_1_2_enabled'] {
    $tpm_version = '1.2'
    $_packages = $tpm_1_2_packages
  } elsif $facts['hirs_tpm_2_0_enabled'] {
    $tpm_version = '2.0'
    $_packages = $tpm_2_0_packages
  }

  if $enable {
    if !defined('$_packages') {
      notice('No TPM detected on $fqdn; skipping HIRS Provisioner installation')
    } else {
      $_tpm_enabled = true
      include '::hirs_provisioner::install'
      include '::hirs_provisioner::config'

      Class[ '::hirs_provisioner::install' ]
      -> Class[ '::hirs_provisioner::config' ]
    }
  }
}
