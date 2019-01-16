require 'spec_helper_acceptance'

test_name 'hirs_provisioner class with tpm'

describe 'hirs_provisioner class with tpm' do

  def download_rpm_tarball_on(hosts, rpm_staging_dir)
  #  let (:tpm_rpms_tarball_url_string) {only_host_with_role( hosts, 'tpm_2_0' ) }
  #    tpm_rpms_tarball_url_string = ENV['BEAKER_tpm_2_0_rpms_tarball_url'] || \
  #    'https://github.com/op-ct/simp-tpm2-rpms/releases/download/0.1.0-rpms/simp-tpm2-simulator-1119.0.0-0.el7.centos.x86_64.rpm'
      ### 'https://github.com/op-ct/simp-tpm2-rpms/releases/download/0.1.0/simp-tpm-rpms-0.1.0.tar.gz'
  #  let (:tpm_rpms_tarball_url_string) {only_host_with_role( hosts, 'tpm_1_2' ) }
      tpm_rpms_tarball_url_string = ENV['BEAKER_tpm_1_2_rpms_tarball_url'] || \
      'https://github.com/m-morrone/simp-tpm12-rpms/releases/download/v0.1-beta/simp-tpm12-simulator-4769.0.0-0.el7.x86_64.rpm'
  #    'https://github.com/m-morrone/simp-tpm12-rpms/releases/download/v0.1-beta/simp-tpm12-simulator-4769.0.0-0.el$fact[operatingsystemmajrelease].x86_64.rpm'
    urls = tpm_rpms_tarball_url_string.split(/,/)
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

  # Install all `*.rpm` files in `rpm_staging_dir/`
  def install_rpms_staged_on(hosts,rpm_staging_dir)
    on hosts, "yum localinstall -y #{rpm_staging_dir}/*.rpm"
  end

  # If local .rpm files have been staged in an 'rpms/' directory at the top
  # level of the repository, upload them to the SUTs' RPM staging directories
  def upload_locally_staged_rpms_to(hosts, rpm_staging_dir)
    rpms = Dir['*.rpm'] + Dir[File.join('rpms','*.rpm')]
    rpms.each do |f|
      scp_to(hosts,f,rpm_staging_dir)
    end
  end

  # Implement any workarounds that are needed to get
  def implement_workarounds(hosts,tpm_2_0)
    # workaround for dbus config file mismatch error:
    #
    # "dbus[562]: [system] Unable to reload configuration: Configuration file
    #  needs one or more <listen> elements giving addresses"
    on hosts, 'systemctl restart dbus'
  end

  def install_pre_suite_rpms(hosts)
    download_rpms   = !ENV.fetch('BEAKER_download_pre_suite_rpms','yes') == 'no'
    rpm_staging_dir = "/root/rpms.#{$$}"

    on hosts, "mkdir -p #{rpm_staging_dir}"
    download_rpm_tarball_on(hosts, rpm_staging_dir) unless download_rpms
    upload_locally_staged_rpms_to(hosts, rpm_staging_dir)
    install_rpms_staged_on(hosts, rpm_staging_dir)
  end

  # starts tpm2sim service on (hosts)
  def start_tpm2sim_on(hosts,tpm_2_0)
    on hosts, 'runuser tpm2sim --shell /bin/sh -c ' \
      '"cd /tmp; nohup /usr/local/bin/tpm2-simulator &> /tmp/tpm2-simulator.log &"', \
      pty: true, run_in_parallel: true
  end

  def config_abrmd_for_tpm2sim_on(hosts,tpm_2_0)
    on hosts, 'mkdir -p /etc/systemd/system/tpm2-abrmd.service.d'

    # Configure the TAB/RM to talk to the TPM2 simulator
    extra_file=<<-SYSTEMD.gsub(/^\s*/,'')
    [Service]
    ExecStart=
    ExecStart=/sbin/tpm2-abrmd -t socket
    SYSTEMD

    create_remote_file hosts, '/etc/systemd/system/tpm2-abrmd.service.d/override.conf', extra_file
    on hosts, 'systemctl daemon-reload'

    on hosts, 'systemctl list-unit-files | grep tpm2-abrmd ' \
      + '&& systemctl restart tpm2-abrmd ' \
      + %q[|| echo "tpm2-abrmd.service not restarted because it doesn't exist"]
  end

  # start the tpm2sim and override tpm2-abrmd's systemd config use it
  # assumes the tpm2sim has been installed on the hosts
  def configure_tpm2_0_tools(hosts,tpm_2_0)
    start_tpm2sim_on(hosts,tpm_2_0)
    config_abrmd_for_tpm2sim_on(hosts,tpm_2_0)
  end

  #
  # This is a helper to get the status of the TPM so it can be compared against the
  # the expected results.

  def get_tpm2_status(host,tpm_2_0)
      stdout = on(host, 'facter -p -y tpm2 --strict').stdout
      fact = YAML.safe_load(stdout)['tpm2']
      tpm2_status = fact['tpm2_getcap']['properties-variable']['TPM_PT_PERSISTENT']
      [tpm2_status['ownerAuthSet'],tpm2_status['endorsementAuthSet'],tpm2_status['lockoutAuthSet']]
  end

  # starts tpm 1.2 simulator services on (hosts)
  #def start_tpm_1_2_sim(hosts,tpm_1_2)
  def start_tpm_1_2_sim(hosts)
    on hosts, 'yum install -y trousers gcc tpm-tools'
    on hosts, 'systemctl start tpm12-simulator'
    on hosts, 'systemctl start tpm12-tpmbios'
    on hosts, 'systemctl restart tpm12-simulator'
    on hosts, 'systemctl restart tpm12-tpmbios'
    on hosts, 'systemctl start tpm12-tpminit'
    on hosts, 'systemctl start tpm12-tcsd'
    on hosts, 'netstat -plnt | grep tcsd ' \
      + %q[|| echo "tcsd not running"]
  end

  #create a local repo with the necessary HIRS rpms
  #this can be replaced later when the packages are signed and added to the extras repo
  def create_local_repo(hosts)
    hosts.each { |host| host.install_package('createrepo') }
    on hosts, 'mkdir /usr/local/repo'
    on hosts, 'cd /usr/local/repo; curl -L -O https://github.com/nsacyber/HIRS/releases/download/v1.0.2/HIRS_Provisioner_TPM_2_0-1.0.2-1541093721.d1bdf9.el7.x86_64.rpm'
    on hosts, 'cd /usr/local/repo; curl -L -O https://github.com/nsacyber/HIRS/releases/download/v1.0.2/HIRS_Provisioner_TPM_1_2-1.0.2-1541093721.d1bdf9.el6.noarch.rpm'
    on hosts, 'cd /usr/local/repo; curl -L -O https://github.com/nsacyber/HIRS/releases/download/v1.0.2/HIRS_Provisioner_TPM_1_2-1.0.2-1541093721.d1bdf9.el7.noarch.rpm'
    on hosts, 'cd /usr/local/repo; curl -L -O https://github.com/nsacyber/HIRS/releases/download/v1.0.2/tpm_module-1.0.2-1541093721.d1bdf9.x86_64.rpm'
    on hosts, 'cd /usr/local/repo; curl -L -O https://github.com/nsacyber/paccor/releases/download/v1.0.6r3/paccor-1.0.6-3.noarch.rpm'
    on hosts, 'createrepo /usr/local/repo'
    on hosts, 'printf "[local.repo]\nname=local\nbaseurl=file:///usr/local/repo\nenabled=1\ngpgcheck=0" > /etc/yum.repos.d/local.repo'
  end


  let(:manifest) {
    <<-EOS
      include 'hirs_provisioner'
    EOS
  }


  context 'with a tpm' do

    # Using puppet_apply as a helper
    it 'should work with no errors' do
#      implement_workarounds(hosts,tpm_2_0) #commented out for now
      install_pre_suite_rpms(hosts)
      create_local_repo(hosts)
#      configure_tpm2_0_tools(hosts,tpm_2_0) #commented out for now
#      start_tpm_1_2_sim(hosts,tpm_1_2) #commented out for now
      start_tpm_1_2_sim(hosts)

      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end


    describe package('hirs_provisioner') do
      it { is_expected.to be_installed }
    end

#    describe service('hirs_provisioner') do
#      it { is_expected.to be_enabled }
#      it { is_expected.to be_running }
#    end
  end
end
