{
  pkgs,
  lib,
  config,
  ...
}:

let
  # Create a configuration file to force remote login capability
  cockpitConfig = pkgs.writeText "cockpit.conf" ''
    [WebService]
    AllowUnencrypted = true
    LoginTo = true
  '';
in
{
  options.modules.containers.cockpit = {
    enable = lib.mkEnableOption "Cockpit Web Interface (Containerized)";
  };

  config = lib.mkIf config.modules.containers.cockpit.enable {

    # 1. Open the Firewall
    networking.firewall.allowedTCPPorts = [ 9090 ];

    # 2. The Cockpit Container
    virtualisation.oci-containers.containers.cockpit = {
      image = "quay.io/cockpit/ws:latest";
      ports = [ "9090:9090" ];
      environment = {
        # Optional: Trust the host's SSH key automatically to avoid "Unknown Host" warnings
        # You might need to verify the host key fingerprint on first login otherwise.
      };
      volumes = [
        # Inject our config so we can specify the host at the login screen
        "${cockpitConfig}:/etc/cockpit/cockpit.conf:ro"

        # (Optional) If you want to persist server fingerprints
        "cockpit-data:/var/lib/cockpit"
      ];
      extraOptions = [
        # Ensure the container can resolve 'host.containers.internal'
        "--network=slirp4netns:allow_host_loopback=true"
      ];
    };
  };
}
