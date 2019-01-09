require 'beaker-rspec'
require 'tmpdir'
require 'yaml'
require 'simp/beaker_helpers'
include Simp::BeakerHelpers

unless ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    # Install Puppet
    if host.is_pe?
      install_pe
    else
      install_puppet
    end
    # Install git, it's a dependency for inspec profiles
    # Found this when experiencing https://github.com/chef/inspec/issues/1270
    install_package(host, 'git')
  end
end

# Download (and unpack if tarball of) TPM1.2/TPM2 RPMs in the rpm_staging_dir
# supports URLs ending in *.rpm, #.tar.gz, *.tar, and *.tgz
# Need logic to determine which one to download
def download_rpm_tarball_on(hosts, rpm_staging_dir)
  tpm_2_0_rpms_tarball_url_string = ENV['BEAKER_tpm_2_0_rpms_tarball_url'] || \
    'https://github.com/op-ct/simp-tpm2-rpms/releases/download/0.1.0-rpms/simp-tpm2-simulator-1119.0.0-0.el7.centos.x86_64.rpm'
    ### 'https://github.com/op-ct/simp-tpm2-rpms/releases/download/0.1.0/simp-tpm-rpms-0.1.0.tar.gz'
  tpm_1_2_rpms_tarball_url_string = ENV['BEAKER_tpm_1_2_rpms_tarball_url'] || \
    'https://github.com/m-morrone/simp-tpm12-rpms/releases/download/v0.1-alpha/simp-tpm12-simulator-4769.0.0-0.el7.x86_64.rpm'
  urls = tpm_2_0_rpms_tarball_url_string.split(/,/) tpm_1_2_rpms_tarball_url_string.split(/,/)
  urls.each do |url|
    file = File.basename url
    cmd  = "curl -L '#{url}' > '#{rpm_staging_dir}/#{file}'"

    if file =~ /\.(tar\.gz|tgz)$/
      cmd += " && cd '#{rpm_staging_dir}' && tar zxvf '#{file}'"
    elsif file =~ /\.tar$/
      cmd += " && cd '#{rpm_staging_dir}' && tar xvf '#{file}'"
    end
    on hosts, cmd
  end
end


RSpec.configure do |c|
  # ensure that environment OS is ready on each host
  fix_errata_on hosts

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    begin
      # Install modules and dependencies from spec/fixtures/modules
      copy_fixture_modules_to( hosts )
      begin
        server = only_host_with_role(hosts, 'server')
      rescue ArgumentError =>e
        server = only_host_with_role(hosts, 'default')
      end

      # Generate and install PKI certificates on each SUT
      Dir.mktmpdir do |cert_dir|
        run_fake_pki_ca_on(server, hosts, cert_dir )
        hosts.each{ |sut| copy_pki_to( sut, cert_dir, '/etc/pki/simp-testing' )}
      end

      # add PKI keys
      copy_keydist_to(server)
    rescue StandardError, ScriptError => e
      if ENV['PRY']
        require 'pry'; binding.pry
      else
        raise e
      end
    end
  end
end
