# create "ima_enabled" custom puppet fact
Facter.add("ima_enabled") do
  setcode do
    # check whether ima is enabled in current grub
    if File.foreach("/proc/cmdline").any?{ |l| l['ima=on'] }
      'true'
    else
      'false'
    end
  end
end
