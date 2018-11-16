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
# @param service_name
#   The name of the hirs_provisioner service
#
# @param package_name
#   The name of the hirs_provisioner package
#
# @param trusted_nets
#   A whitelist of subnets (in CIDR notation) permitted access
#
# @param enable_auditing
#   If true, manage auditing for hirs_provisioner
#
# @param enable_firewall
#   If true, manage firewall rules to acommodate hirs_provisioner
#
# @param enable_logging
#   If true, manage logging configuration for hirs_provisioner
#
# @param enable_pki
#   If true, manage PKI/PKE configuration for hirs_provisioner
#
# @param enable_tcpwrappers
#   If true, manage TCP wrappers configuration for hirs_provisioner
#
# @author SIMP Team
#
class hirs_provisioner (
  String                        $service_name       = 'hirs_provisioner',
  String                        $package_name       = 'hirs_provisioner',
  Simplib::Port                 $tcp_listen_port    = 9999,
  Simplib::Netlist              $trusted_nets       = simplib::lookup('simp_options::trusted_nets', {'default_value' => ['127.0.0.1/32'] }),
  Variant[Boolean,Enum['simp']] $enable_pki         = simplib::lookup('simp_options::pki', { 'default_value'         => false }),
  Boolean                       $enable_auditing    = simplib::lookup('simp_options::auditd', { 'default_value'      => false }),
  Variant[Boolean,Enum['simp']] $enable_firewall    = simplib::lookup('simp_options::firewall', { 'default_value'    => false }),
  Boolean                       $enable_logging     = simplib::lookup('simp_options::syslog', { 'default_value'      => false }),
  Boolean                       $enable_tcpwrappers = simplib::lookup('simp_options::tcpwrappers', { 'default_value' => false })
) {

  simplib::assert_metadata($module_name)

  include '::hirs_provisioner::install'
  include '::hirs_provisioner::config'
  include '::hirs_provisioner::service'

  Class[ '::hirs_provisioner::install' ]
  -> Class[ '::hirs_provisioner::config' ]
  ~> Class[ '::hirs_provisioner::service' ]

  if $enable_pki {
    include '::hirs_provisioner::config::pki'
    Class[ '::hirs_provisioner::config::pki' ]
    -> Class[ '::hirs_provisioner::service' ]
  }

  if $enable_auditing {
    include '::hirs_provisioner::config::auditing'
    Class[ '::hirs_provisioner::config::auditing' ]
    -> Class[ '::hirs_provisioner::service' ]
  }

  if $enable_firewall {
    include '::hirs_provisioner::config::firewall'
    Class[ '::hirs_provisioner::config::firewall' ]
    -> Class[ '::hirs_provisioner::service' ]
  }

  if $enable_logging {
    include '::hirs_provisioner::config::logging'
    Class[ '::hirs_provisioner::config::logging' ]
    -> Class[ '::hirs_provisioner::service' ]
  }

  if $enable_tcpwrappers {
    include '::hirs_provisioner::config::tcpwrappers'
    Class[ '::hirs_provisioner::config::tcpwrappers' ]
    -> Class[ '::hirs_provisioner::service' ]
  }
}
