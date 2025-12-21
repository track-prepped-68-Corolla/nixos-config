{ config, pkgs, ... }:

{
  virtualisation.vmware.host.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ config.mainUser ];

  # Incus settings
  virtualisation.incus = {
    enable = true;
    # Add this line to satisfy the assertion
    package = pkgs.incus;
  };

  # Ensure nftables is definitely on for this module
  networking.nftables.enable = true;
}
