require 'spec_helper'

describe 'hirs_provisioner::install' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) do
          os_facts
        end

        context "with default parameters and TPM 1.2 detected" do
          let(:facts) do
            os_facts.merge({
              tpm12_enabled: true,
              tpm2_enabled:  false,
              ima_enabled:   false
            })
          end 
          let(:pre_condition) { 'include hirs_provisioner' }
          it { is_expected.to contain_package('HIRS_Provisioner_TPM_1_2').with_ensure('installed') }
          it { is_expected.to create_file('/var/log/hirs/provisioner').with_ensure('directory') }
          it { is_expected.not_to create_file('/usr/sbin/hirs-provisioner') }
        end

        context "with default parameters and TPM 2 detected" do
          let(:facts) do
            os_facts.merge({
              tpm12_enabled: false,
              tpm2_enabled:  true,
              ima_enabled:   false
            })
          end 
          let(:pre_condition) { 'include hirs_provisioner' }
          it { is_expected.to contain_package('HIRS_Provisioner_TPM_2_0').with_ensure('installed') }
          it { is_expected.to create_file('/var/log/hirs/provisioner').with_ensure('directory') }
          it { is_expected.to create_file('/usr/sbin/hirs-provisioner').with_ensure('link') }
        end

      end
    end
  end
end
