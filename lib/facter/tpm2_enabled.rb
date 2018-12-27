# create "tpm2_enabled" custom puppet fact
Facter.add("tpm2_enabled") do
  confine :kernel => 'Linux'
  confine { Facter::Core::Execution.which('tpm2_getcap') }
  setcode do
    # check whether tpm is enabled
    tpm2_fixed_params = Facter::Util::Resolution.exec('tpm2_getcap -c properties-fixed')
    tpm2_fixed_params.include? '"2.0"'
  end
end

