{ config, lib, pkgs, ... }:

let
  cfg = config.modules.services.tailscale;
in
{
  options.modules.services.tailscale = {
    enable = lib.mkEnableOption "tailscale service with trayscale gui";
  };

  config = lib.mkIf cfg.enable {
    # 1. Enable the daemon (fixes the "Unit tailscaled.service not found" error)
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client"; # "server" if you want to be an exit node
    };

    # 2. Add Trayscale to system packages
    environment.systemPackages = [ pkgs.trayscale ];

    # 3. Firewall configuration (Recommended)
    # Allows direct connections and prevents some routing issues
    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      # distinct from 'checkReversePath = false', 'loose' is often safer for VPNs
      checkReversePath = "loose";
    };
  };
}
