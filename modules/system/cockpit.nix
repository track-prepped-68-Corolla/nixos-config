{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.modules.system.cockpit = {
    enable = lib.mkEnableOption "Cockpit Web Interface";
    kvm = {
      enable = lib.mkEnableOption "KVM/Libvirt integration for Cockpit";
    };
  };

  config = lib.mkIf config.modules.system.cockpit.enable {

    services.cockpit = {
      enable = true;
      port = 9090;
      openFirewall = true;
      settings = {
        WebService = {
          AllowUnencrypted = true;
        };
      };

      packages = [
        pkgs.packagekit
      ]
      # -----------------------------------------------------------
      # FIX: We comment this out because your pkgs is missing it.
      # Once you find the correct name (see below), uncomment it.
      # -----------------------------------------------------------
      ++ lib.optionals config.modules.system.podman.enable [ pkgs.cockpit-podman ]

      # This usually exists, but if it fails too, comment it out.
      ++ lib.optionals config.modules.system.cockpit.kvm.enable [ pkgs.cockpit-machines ];
    };

    # ... (rest of your user/virtualisation config remains the same)
    users.users.${config.mainuser} = lib.mkIf config.modules.system.cockpit.kvm.enable {
      extraGroups = [ "libvirtd" ];
    };

    virtualisation.libvirtd = lib.mkIf config.modules.system.cockpit.kvm.enable {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf.enable = true;
      };
    };
  };
}
