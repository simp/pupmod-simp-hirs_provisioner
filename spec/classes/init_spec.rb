require 'spec_helper'

describe 'hirs_provisioner' do
  shared_examples_for "a structured module" do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to create_class('hirs_provisioner') }
    it { is_expected.to contain_class('hirs_provisioner') }
    it { is_expected.to contain_class('hirs_provisioner::install').that_comes_before('Class[hirs_provisioner::config]') }
    it { is_expected.to contain_class('hirs_provisioner::config') }
    it { is_expected.to contain_class('hirs_provisioner::service').that_subscribes_to('Class[hirs_provisioner::config]') }

    it { is_expected.to contain_service('hirs_provisioner') }
    it { is_expected.to contain_package('hirs_provisioner').with_ensure('present') }
  end

  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) do
          os_facts
        end

        context "hirs_provisioner class without any parameters" do
          let(:params) {{ }}
          it_behaves_like "a structured module"
          it { is_expected.to contain_class('hirs_provisioner').with_trusted_nets(['127.0.0.1/32']) }
        end

        context "hirs_provisioner class with firewall enabled" do
          let(:params) {{
            :enable_firewall => true
          }}

          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('hirs_provisioner::config::firewall') }

          it { is_expected.to contain_class('hirs_provisioner::config::firewall').that_comes_before('Class[hirs_provisioner::service]') }
          it { is_expected.to create_iptables__listen__tcp_stateful('allow_hirs_provisioner_tcp_connections').with_dports(9999)
          }
        end

        context "hirs_provisioner class with auditing enabled" do
          let(:params) {{
            :enable_auditing => true
          }}

          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('hirs_provisioner::config::auditing') }
          it { is_expected.to contain_class('hirs_provisioner::config::auditing').that_comes_before('Class[hirs_provisioner::service]') }
          it { is_expected.to create_notify('FIXME: auditing') }
        end

        context "hirs_provisioner class with logging enabled" do
          let(:params) {{
            :enable_logging => true
          }}

          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('hirs_provisioner::config::logging') }
          it { is_expected.to contain_class('hirs_provisioner::config::logging').that_comes_before('Class[hirs_provisioner::service]') }
          it { is_expected.to create_notify('FIXME: logging') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'hirs_provisioner class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :os => {
          :family => 'Solaris',
          :name   => 'Nexenta'
        }
      }}

      it { expect { is_expected.to contain_package('hirs_provisioner').to raise_error(/OS 'Nexenta' is not supported/) } }
    end
  end
end
