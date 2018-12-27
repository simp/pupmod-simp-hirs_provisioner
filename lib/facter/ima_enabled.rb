# create "ima_enabled" custom puppet fact
Facter.add("ima_enabled") do
  confine :kernel => 'Linux'
  setcode do
    # check whether ima is enabled in current grub
    File.foreach("/proc/cmdline").any?{ |l| l['ima=on'] }
  end
end
