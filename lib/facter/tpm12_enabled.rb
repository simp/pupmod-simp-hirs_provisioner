# create "tpm12_enabled" custom puppet fact
Facter.add("tpm12_enabled") do
  setcode do
    # check whether tpm 1.2 is enabled
    if File.exist? '/usr/sbin/tpm_version' and File.executable? '/usr/sbin/tpm_version'
      tpm12_version = Facter::Util::Resolution.exec('/usr/sbin/tpm_version')
      if tpm12_version.include? 'TPM 1.2 Version Info'
        answer = "true"
      else
        answer = "false"
      end
    else
      answer = "false"
    end
  end
end

