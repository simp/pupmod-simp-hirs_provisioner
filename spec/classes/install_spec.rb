require 'spec_helper'

describe 'hirs_provisioner::install' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) do
          os_facts
        end

        context 'with default parameters and TPM 1.2 detected' do
          let(:facts) do
            os_facts.merge(
              hirs_tpm_1_2_enabled: true,
              hirs_tpm_2_0_enabled: false,
            )
          end
          let(:pre_condition) { 'include hirs_provisioner' }

          it { is_expected.to contain_package('HIRS_Provisioner_TPM_1_2').with_ensure(%r{\Apresent|installed\Z}) }
          it { is_expected.to create_file('/var/log/hirs/provisioner').with_ensure('directory') }
        end

        context 'with default parameters and TPM 2 detected' do
          let(:facts) do
            os_facts.merge(
              hirs_tpm_1_2_enabled: false,
              hirs_tpm_2_0_enabled: true,
            )
          end
          let(:pre_condition) { 'include hirs_provisioner' }

          it { is_expected.to contain_package('HIRS_Provisioner_TPM_2_0').with_ensure(%r{\Apresent|installed\Z}) }
          it { is_expected.to create_file('/var/log/hirs/provisioner').with_ensure('directory') }
        end
      end
    end
  end
end
