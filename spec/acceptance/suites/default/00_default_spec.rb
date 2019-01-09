require 'spec_helper_acceptance'

test_name 'hirs_provisioner class'

describe 'hirs_provisioner class' do
  let(:manifest) {
    <<-EOS
      include 'hirs_provisioner'
    EOS
  }

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      apply_manifest(manifest, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_changes => true)
    end


#    describe package('hirs_provisioner') do
#      it { is_expected.to be_installed }
#    end

#    describe service('hirs_provisioner') do
#      it { is_expected.to be_enabled }
#      it { is_expected.to be_running }
#    end
  end
end
