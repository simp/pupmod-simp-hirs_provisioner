require 'spec_helper_acceptance'

test_name 'hirs_provisioner class'

describe 'hirs_provisioner class' do
  # install an aca for the provisioners to talk to
  def setup_aca(aca)
    on aca, 'yum install -y mariadb-server openssl tomcat java-1.8.0 rpmdevtools coreutils initscripts chkconfig sed grep firewalld policycoreutils'
    # Workaround for https://github.com/nsacyber/HIRS/issues/358
    on aca, "sed -i 's/TLSv1, TLSv1.1, //' /usr/lib/jvm/java-*/jre/lib/security/java.security"
    on aca, 'yum install -y https://github.com/nsacyber/HIRS/releases/download/V2.0.0/HIRS_AttestationCA-2.0.0-1607000235.0ce8d4.el7.noarch.rpm'
    sleep(10)
  end

  let(:manifest) do
    <<~EOS
      include 'hirs_provisioner'
    EOS
  end

  let(:hieradata) do
    <<~EOS
      ---
      hirs_provisioner::config::aca_fqdn: aca.beaker.test
    EOS
  end

  context 'set up aca' do
    it 'starts the aca server' do
      aca_host = only_host_with_role(hosts, 'aca')
      setup_aca(aca_host)
    end
  end

  context 'with a tpm' do
    hosts_with_role(hosts, 'hirs').each do |hirs_host|
      it 'works with no errors' do
        if hirs_host.host_hash[:roles].include?('tpm_2_0')
          package_name = 'HIRS_Provisioner_TPM_2_0'
        else
          hirs_host.host_hash[:roles].include?('tpm_1_2')
          package_name = 'HIRS_Provisioner_TPM_1_2'
        end
        set_hieradata_on(hirs_host, hieradata)
        apply_manifest_on(hirs_host, manifest, catch_failures: true)
        expect(check_for_package(hirs_host, package_name)).to be true
      end

      it 'is idempotent' do
        apply_manifest_on(hirs_host, manifest, catch_changes: true)
      end
    end
  end
end
