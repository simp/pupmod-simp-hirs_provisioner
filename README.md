[![License](https://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/hirs_provisioner.svg)](https://forge.puppetlabs.com/simp/hirs_provisioner)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/hirs_provisioner.svg)](https://forge.puppetlabs.com/simp/hirs_provisioner)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-hirs_provisioner.svg)](https://travis-ci.org/simp/pupmod-simp-hirs_provisioner)

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Description](#description)
  * [This is a SIMP module](#this-is-a-simp-module)
* [Setup](#setup)
  * [Setup Requirements](#setup-requirements)
  * [Beginning with hirs_provisioner](#beginning-with-hirs_provisioner)
* [Usage](#usage)
* [Reference](#reference)
* [Limitations](#limitations)
* [Development](#development)
  * [Acceptance tests](#acceptance-tests)

<!-- vim-markdown-toc -->

---

    +---------------------------------------------------------------+
    | WARNING: This is currently an **EXPERIMENTAL** module things  |
    | may change drastically, and in breaking ways, without notice! |
    +---------------------------------------------------------------+

---

## Description

This module manages Host Integrity at Runtime and Start-up (HIRS) provisioning.
It installs and configures the necessary packages and components to register
the system with an Attestation Certificate Authority, which can ensure Trusted
Computing Group based Supply Chain Validation of systems.

See [REFERENCE.md](REFERENCE.md) for more details.

### This is a SIMP module

This module is a component of the [System Integrity Management Platform](https://simp-project.com), a
compliance-management framework built on Puppet.

If you find any issues, they may be submitted to our [bug tracker](https://simp-project.atlassian.net/).

This module is optimally designed for use within a larger SIMP ecosystem, but
it can be used independently:

 * When included within the SIMP ecosystem, security compliance settings will
   be managed from the Puppet server.
 * If used independently, all SIMP-managed security subsystems are disabled by
   default and must be explicitly opted into by administrators.  Please review
   the parameters in
   [`simp/simp_options`](https://github.com/simp/pupmod-simp-simp_options) for
   details.

## Setup

### Setup Requirements

In order to utilize the HIRS Provisioner module, the target system must have an
enabled TPM device and an ACA must be configured and accessible for the the
system to receive a certificate and register.  If the ACA is hosted on a remote
system, the fully qualified domain name of the ACA system should be specified
in Hiera.  The SIMP TPM or TPM2 modules can be used to setup and enable the TPM
devices.

### Beginning with hirs_provisioner

Simply `include hirs_provisioner`.

## Usage

If the ACA is hosted on a remote system, it is necessary to specify the fully
qualified domain name of that system in Hiera, by adding the following:

```yaml
---
hirs_provisioner::config::aca_fqdn: fqdn.of.the.aca
```

## Reference

Please refer to the inline documentation within each source file, or to the
module's generated YARD documentation for reference material.

## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise Linux
and compatible distributions, such as CentOS. Please see the
[`metadata.json` file](./metadata.json) for the most up-to-date list of
supported operating systems, Puppet versions, and module dependencies.

## Development

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

### Acceptance tests

This module includes [Beaker](https://github.com/puppetlabs/beaker) acceptance
tests using the SIMP [Beaker Helpers](https://github.com/simp/rubygem-simp-beaker-helpers).
By default the tests use [Vagrant](https://www.vagrantup.com/) with
[VirtualBox](https://www.virtualbox.org) as a back-end; Vagrant and VirtualBox
must both be installed to run these tests without modification. To execute the
tests run the following:

```shell
bundle install
bundle exec rake beaker:suites
```
