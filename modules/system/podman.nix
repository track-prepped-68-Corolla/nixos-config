{ pkgs, lib, config, ... }:

{
  options.modules.system.podman = {
    enable = lib.mkEnableOption "Podman container engine";

    # This is the specific option 'nvidia.nix' is trying to toggle
    nvidia = {
      enable = lib.mkEnableOption "NVIDIA Container Toolkit integration";
    };
  };

  config = lib.mkIf config.modules.system.podman.enable {

    # 1. Core Engine
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # 2. NVIDIA Integration (Conditional)
    # Only enables if modules.system.podman.nvidia.enable is set to true
    hardware.nvidia-container-toolkit.enable = config.modules.system.podman.nvidia.enable;

    # 3. CLI Tools
    environment.systemPackages = with pkgs; [
      podman-compose
    ];

    # 4. Global Socket Configuration
    environment.extraInit = ''
      if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
        export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
      fi
    '';

    # 5. User Permissions
    users.users.${config.mainuser} = {
      extraGroups = [ "podman" ]
        ++ lib.optionals config.modules.system.podman.nvidia.enable [ "video" "render" ];
      linger = true;
    };

    # 6. Kernel tweaks for Rootless Podman
    boot.kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 80;
    };
  };
}
