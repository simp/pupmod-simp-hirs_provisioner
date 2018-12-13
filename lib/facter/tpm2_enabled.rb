# create "tpm2_enabled" custom puppet fact
Facter.add("tpm2_enabled") do
  setcode do
    # check whether tpm is enabled
    if File.exist? '/usr/bin/tpm2_getcap' and File.executable? '/usr/bin/tpm2_getcap'
      tpm2_fixed_params = Facter::Util::Resolution.exec('/usr/bin/tpm2_getcap -c properties-fixed')
      if tpm2_fixed_params.include? '"2.0"'
        answer = "true"
      else
        answer = "false"
      end
    else
      answer = "false"
    end
  end
end

