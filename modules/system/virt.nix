{ config, pkgs, lib, ... }:

{
  options.modules.system.virt = {
    enable = lib.mkEnableOption "virtualization (libvirt, incus, vmware)";
  };

  config = lib.mkIf config.modules.system.virt.enable {

    virtualisation.vmware.host.enable = lib.mkDefault true;
    virtualisation.libvirtd.enable = lib.mkDefault true;
    virtualisation.spiceUSBRedirection.enable = lib.mkDefault true;
    programs.virt-manager.enable = lib.mkDefault true;

    users.groups.libvirtd.members = [ config.mainuser ];

    virtualisation.incus = {
      enable = lib.mkDefault true;
      package = pkgs.incus;
    };

    networking.nftables.enable = lib.mkDefault true;
  };
}
