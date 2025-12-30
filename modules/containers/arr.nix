{ config, pkgs, ... }:

{
  # 1. Enable Podman and OCI Containers
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.oci-containers.backend = "podman";

  # 2. Open Firewall Ports
  # These must match the ports exposed by Gluetun and Jellyfin
  networking.firewall = {
    allowedTCPPorts = [
      8096
      8920 # Jellyfin
      9696
      7878
      8989
      6767
      8686 # Arr Apps (via Gluetun)
      8080
      6881 # Qbittorrent (via Gluetun)
    ];
    allowedUDPPorts = [
      1900
      7359 # Jellyfin Discovery
      6881 # Qbittorrent
    ];
  };

  # 3. Container Definitions
  virtualisation.oci-containers.containers = {

    # --- GLUETUN (VPN) ---
    gluetun = {
      image = "qmcgaw/gluetun";
      environment = {
        VPN_SERVICE_PROVIDER = "protonvpn";
        VPN_TYPE = "wireguard";
        SERVER_COUNTRIES = "Iceland,Switzerland,Sweden";
        # WARNING: This key is world-readable in the Nix store.
        # See "Security Note" below for a better way to handle this.
        WIREGUARD_PRIVATE_KEY = "IEhu71iCYx++aR/EQ9a4ClYwuuBJEMmVw3yBZNmBxFg=";
        PORT_FORWARD_ONLY = "on";
        VPN_PORT_FORWARDING = "on";
      };
      ports = [
        "9696:9696" # Prowlarr
        "7878:7878" # Radarr
        "8989:8989" # Sonarr
        "6767:6767" # Bazarr
        "8686:8686" # Lidarr
        "8080:8080" # Qbittorrent WebUI
        "6881:6881" # Qbittorrent TCP
        "6881:6881/udp" # Qbittorrent UDP
      ];
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun"
      ];
    };

    # --- RADARR ---
    radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Etc/UTC";
      };
      volumes = [
        "/media/arr/radarr/config:/config"
        "/media/arr/radarr/movies:/movies"
        "/media/arr/qbittorrent/downloads:/downloads"
      ];
      # Connects to Gluetun's network namespace
      extraOptions = [ "--network=container:gluetun" ];
      dependsOn = [ "gluetun" ];
    };

    # --- SONARR ---
    sonarr = {
      image = "lscr.io/linuxserver/sonarr:latest";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Etc/UTC";
      };
      volumes = [
        "/media/arr/sonarr/config:/config"
        "/media/arr/sonarr/tvseries:/tv"
        "/media/arr/qbittorrent/downloads:/downloads"
      ];
      extraOptions = [ "--network=container:gluetun" ];
      dependsOn = [ "gluetun" ];
    };

    # --- PROWLARR ---
    prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:latest";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Etc/UTC";
      };
      volumes = [ "/media/arr/prowlarr/config:/config" ];
      extraOptions = [ "--network=container:gluetun" ];
      dependsOn = [ "gluetun" ];
    };

    # --- BAZARR ---
    bazarr = {
      image = "lscr.io/linuxserver/bazarr:latest";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Etc/UTC";
      };
      volumes = [
        "/media/arr/bazarr/config:/config"
        "/media/arr/radarr/movies:/movies"
        "/media/arr/sonarr/tvseries:/tv"
      ];
      extraOptions = [ "--network=container:gluetun" ];
      dependsOn = [ "gluetun" ];
    };

    # --- LIDARR ---
    lidarr = {
      image = "lscr.io/linuxserver/lidarr:latest";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Etc/UTC";
      };
      volumes = [
        "/media/arr/lidarr/config:/config"
        "/media/arr/lidarr/music:/music"
        "/media/arr/qbittorrent/downloads:/downloads"
      ];
      extraOptions = [ "--network=container:gluetun" ];
      dependsOn = [ "gluetun" ];
    };

    # --- QBITTORRENT ---
    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Etc/UTC";
        WEBUI_PORT = "8080";
        TORRENTING_PORT = "6881";
      };
      volumes = [
        "/media/arr/qbittorrent/config:/config"
        "/media/arr/qbittorrent/downloads:/downloads"
      ];
      extraOptions = [ "--network=container:gluetun" ];
      dependsOn = [ "gluetun" ];
    };

    # --- JELLYFIN (Standalone) ---
    jellyfin = {
      image = "lscr.io/linuxserver/jellyfin:latest";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Etc/UTC";
      };
      ports = [
        "8096:8096"
        "8920:8920"
        "7359:7359/udp"
        "1900:1900/udp"
      ];
      volumes = [
        "/media/arr/jellyfin/config:/config"
        "/media/arr/sonarr/tvseries:/data/tvshows"
        "/media/arr/radarr/movies:/data/movies"
      ];
    };

  };
}
