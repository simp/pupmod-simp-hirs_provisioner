require 'spec_helper'

describe 'hirs_provisioner' do
  shared_examples_for "a structured module" do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to create_class('hirs_provisioner') }
    it { is_expected.to contain_class('hirs_provisioner') }
    it { is_expected.to contain_class('hirs_provisioner::install').that_comes_before('Class[hirs_provisioner::config]') }
    it { is_expected.to contain_class('hirs_provisioner::config') }
  end

  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) do
          os_facts
        end

        context "with default parameters" do
          let(:facts) do 
            os_facts.merge({
              tpm12_enabled: 'false',
              tpm2_enabled:  'false'
            })
          end
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to create_class('hirs_provisioner') }
          it { is_expected.to contain_class('hirs_provisioner') }
          it { is_expected.not_to contain_class('hirs_provisioner::install') }
          it { is_expected.not_to contain_class('hirs_provisioner::config') }
        end

        context "with default parameters and TPM 1.2 detected" do
          let(:facts) do 
            os_facts.merge({
              tpm12_enabled: 'true',
              tpm2_enabled:  'false',
              ima_enabled:   'false'
            })
          end
          it_behaves_like "a structured module"
        end

        context "with default parameters and TPM 2 detected" do
          let(:facts) do 
            os_facts.merge({
              tpm12_enabled: 'false',
              tpm2_enabled:  'true',
              ima_enabled:   'false'
            })
          end
          it_behaves_like "a structured module"
        end

      end
    end
  end
end
