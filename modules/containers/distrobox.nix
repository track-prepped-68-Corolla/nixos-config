{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.containers.distrobox;
in
{
  options.modules.containers.distrobox = {
    enable = lib.mkEnableOption "Distrobox container management";
    enableBoxBuddy = lib.mkEnableOption "BoxBuddy (GUI for Distrobox)";
  };

  config = lib.mkIf cfg.enable {
    # 1. Install Distrobox & optional GUI
    environment.systemPackages = [
      pkgs.distrobox
    ]
    ++ (lib.optionals cfg.enableBoxBuddy [ pkgs.boxbuddy ]);

    # 2. Assert that a backend is available
    assertions = [
      {
        assertion = config.virtualisation.podman.enable || config.virtualisation.docker.enable;
        message = "Distrobox requires either Podman or Docker to be enabled in your configuration.";
      }
    ];
  };
}
