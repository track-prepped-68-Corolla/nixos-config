{ pkgs, lib, config, ... }:

{
  options.modules.system.cockpit = {
    enable = lib.mkEnableOption "Cockpit Web Interface";
    
    # Sub-option for VM management, similar to your nvidia toggle
    kvm = {
      enable = lib.mkEnableOption "KVM/Libvirt integration for Cockpit";
    };
  };

  config = lib.mkIf config.modules.system.cockpit.enable {

    # 1. Core Service
    services.cockpit = {
      enable = true;
      port = 9090;
      openFirewall = true;
      
      settings = {
        WebService = {
          AllowUnencrypted = true;
        };
      };

      # 2. Plugins (Conditional Loading)
      packages = with pkgs; [
        packagekit # For software updates (optional, but standard)
      ] 
      # Automatically include Podman plugin if your podman module is enabled
      ++ lib.optionals config.modules.system.podman.enable [ cockpit-podman ]
      # Include KVM plugin if the kvm option is enabled
      ++ lib.optionals config.modules.system.cockpit.kvm.enable [ cockpit-machines ];
    };

    # 3. User Permissions (KVM)
    # Your podman.nix already handles the 'podman' group. 
    # We only need to handle libvirtd here if KVM is enabled.
    users.users.${config.mainuser} = lib.mkIf config.modules.system.cockpit.kvm.enable {
      extraGroups = [ "libvirtd" ];
    };

    # 4. Ensure Libvirt is actually running if the plugin is requested
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
