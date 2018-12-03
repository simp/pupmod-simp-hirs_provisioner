# create "tpm_enabled" custom puppet fact
Facter.add("tpm_enabled") do
  setcode do
    # check whether tpm is enabled
#    file = Facter::Util::Resolution.exec('/bin/cat /sys/class/tpm/tpm0/enabled')
#    tpm2_version = Facter.value(:tpm2.tpm2_getcap.properties-fixed.TPM_PT_FAMILY_INDICATOR.as\sstring)
#    tpm1_version = Facter.value(:tpm.tpm2_getcap.properties-fixed.TPM_PT_FAMILY_INDICATOR.as\sstring)
    tpm2_version = Facter::Core::Execution.execute("facter -p 'tpm2.tpm2_getcap.properties-fixed.TPM_PT_FAMILY_INDICATOR.as string'")
    if tpm2_version =~ /2.0/ || tpm1_version == 'tpm1'
      answer = "true"
    else
      answer = "false"
    end
  end
end

