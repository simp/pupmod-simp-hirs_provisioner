require 'spec_helper_acceptance'

test_name 'hirs_provisioner class with no tpm'

describe 'hirs_provisioner class with no tpm' do

  let(:manifest) {
    <<-EOS
      include 'hirs_provisioner'
    EOS
  }

  hosts_with_role(hosts, 'hirs').each do |hirs_host|
    context 'default parameters' do
      # Using puppet_apply as a helper
      it 'should work with no errors' do
        apply_manifest_on(hirs_host, manifest, :catch_failures => true)
      end

      it 'should be idempotent' do
        apply_manifest_on(hirs_host, manifest, :catch_changes => true)
      end
    end
  end
end
