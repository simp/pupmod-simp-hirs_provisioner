require 'spec_helper_acceptance'

test_name 'hirs_provisioner class with no tpm'

describe 'hirs_provisioner class with no tpm' do

  let(:manifest) {
    <<-EOS
      include 'hirs_provisioner'
    EOS
  }

  hosts.each do |host|
    it 'should enable SIMP dependencies repo' do
      # exclude SIMP repo, as we only want the SIMP deps repo
      # (...but maybe we need it now?)
      install_simp_repos(host)
    end

    it 'sets up dnsmasq' do
      install_package(host, 'dnsmasq')

      dnsmasq_conf = <<~DNSMASQ_CONF
        listen-address=::1,127.0.0.1
        expand-hosts
        domain=beaker.test
        server=8.8.8.8
        server=4.4.4.4
        DNSMASQ_CONF

      create_remote_file(host, '/etc/dnsmasq.conf', dnsmasq_conf)

      on(host, 'puppet resource service dnsmasq ensure=running enable=true')

      resolv_conf = <<~RESOLV_CONF
        nameserver 127.0.0.1
        search beaker.test
        RESOLV_CONF

      create_remote_file(host, '/etc/resolv.conf', resolv_conf)

      on(host, 'chattr +i /etc/resolv.conf')
    end
  end

  hosts_with_role(hosts, 'hirs').each do |hirs_host|
    # This tests that nothing bad happens when the module is applied with no TPM
    context 'default parameters' do
      # Using puppet_apply as a helper
      it 'should work with no errors' do
        if hirs_host.host_hash[:roles].include?('tpm_2_0')
          package_name = 'HIRS_Provisioner_TPM_2_0'
        else hirs_host.host_hash[:roles].include?('tpm_1_2')
          package_name = 'HIRS_Provisioner_TPM_1_2'
        end
        apply_manifest_on(hirs_host, manifest, :catch_failures => true)
        expect( check_for_package(hirs_host, package_name) ).to be false
      end

      it 'should be idempotent' do
        apply_manifest_on(hirs_host, manifest, :catch_changes => true)
      end
    end
  end
end
