{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.containers.dozzle;
in
{
  options.modules.containers.dozzle = {
    enable = lib.mkEnableOption "Dozzle Log & Shell Viewer";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8888;
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Create a fake Engine ID for Podman so Dozzle doesn't crash
    systemd.tmpfiles.rules = [
      "d /var/lib/dozzle-fix 0755 root root -"
      "f /var/lib/dozzle-fix/engine-id 0644 root root - 54c3705a-04b6-4960-9993-5aa3891739b8"
    ];

    virtualisation.oci-containers.containers.dozzle = {
      image = "amir20/dozzle:latest";
      ports = [ "${toString cfg.port}:8080" ];
      volumes = [
        # Mount the Podman socket as the Docker socket
        "/run/podman/podman.sock:/var/run/docker.sock"
        # Mount the fake Engine ID we created above
        "/var/lib/dozzle-fix/engine-id:/var/lib/docker/engine-id:ro"
      ];
      environment = {
        DOZZLE_ENABLE_SHELL = "true";
        # "status=running" hides stopped containers to reduce clutter
        DOZZLE_FILTER = "status=running";
      };
      autoStart = true;
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
