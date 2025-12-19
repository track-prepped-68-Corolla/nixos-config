{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.vmware.host.enable = true;
  virtualisation.incus.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  programs.virt-manager.enable = true;

  # Ensure Joe is in the group when this module is active
  users.groups.libvirtd.members = [ "${config.mainUser}" ];
}
