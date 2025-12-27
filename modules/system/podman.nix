{ pkgs, lib, config, ... }:

{
  options.modules.podman = {
    enable = lib.mkEnableOption "Enable Podman with NVIDIA support";
  };

  config = lib.mkIf config.modules.podman.enable {
    
    # 1. Core Engine
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # 2. NVIDIA CDI Integration
    # This generates the CDI spec for Podman to talk to the GPU
    #hardware.nvidia-container-toolkit.enable = true;

    # 3. CLI Tools & Aliases
    environment.systemPackages = with pkgs; [
      podman-compose
      docker-compose 
    ];

    # 4. Global Socket Configuration
    # This tells docker-compose to use the user's podman socket automatically
    environment.extraInit = ''
      if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
        export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
      fi
    '';

    # 5. User Permissions using config.mainuser
    users.users.${config.mainuser} = {
      extraGroups = [ "podman" "video" "render" ];
      linger = true; # Keeps containers running after SSH/session logout
    };
    
    # 6. Kernel tweaks for Rootless Podman
    # Helps with port forwarding and subuid mapping
    boot.kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 80;
    };
  };
}
