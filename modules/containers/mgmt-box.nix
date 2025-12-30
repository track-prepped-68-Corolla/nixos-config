{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.containers.mgmt-box;
  containerName = "mgmt";
  containerImage = "registry.fedoraproject.org/fedora:latest";

  containerPackages = builtins.concatStringsSep " " [
    "cockpit"
    "cockpit-podman"
    "cockpit-machines"
    "podman"
    "libvirt-client"
    "openssh-clients"
    "passwd"
    "shadow-utils"
    "util-linux"
  ];

  # 1. Define the Init Script as a file
  # We use #!/bin/bash because this runs INSIDE the Fedora container.
  initScript = pkgs.writeText "mgmt-init.sh" ''
    #!/bin/bash
    set -e # Fail on error

    # 1. Unmount host auth files so we can write our own
    umount /etc/shadow 2>/dev/null || true
    umount /etc/passwd 2>/dev/null || true

    # 2. Disable PAM auditing checks that break rootless login in Fedora
    sed -i -r 's/^(.*pam_loginuid.so)/#\1/' /etc/pam.d/cockpit
    sed -i -r 's/^(.*pam_loginuid.so)/#\1/' /etc/pam.d/sshd

    # 3. Ensure admin user exists
    if ! id -u admin >/dev/null 2>&1; then
      useradd -m -G wheel admin
    fi
    echo "admin:admin" | chpasswd

    # 4. Reset current user password (dynamically detected)
    echo "$(id -un):password" | chpasswd
  '';

in
{
  options.modules.containers.mgmt-box = {
    enable = lib.mkEnableOption "Fedora Management Box (Cockpit on Port 9090)";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.modules.containers.distrobox.enable;
        message = "The Management Box requires 'modules.containers.distrobox.enable = true'.";
      }
    ];

    systemd.user.services = {
      "distrobox-${containerName}-create" = {
        description = "Create Fedora Management Distrobox";
        after = [
          "podman.service"
          "docker.service"
        ];
        path = [
          pkgs.distrobox
          pkgs.gnugrep
          pkgs.coreutils
          pkgs.podman
          pkgs.util-linux
        ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "create-mgmt-box" ''
            # Force cleanup of any broken attempts
            if distrobox list | grep -q "${containerName}"; then
               distrobox rm "${containerName}" --force || true
            fi

            echo "Creating ${containerName}..."
            distrobox create \
              --name "${containerName}" \
              --image "${containerImage}" \
              --yes \
              --volume "${initScript}:/tmp/init-hook.sh:ro" \
              --init-hooks "bash /tmp/init-hook.sh" \
              --volume /run/podman/podman.sock:/run/podman/podman.sock \
              --volume /run/libvirt/libvirt-sock:/run/libvirt/libvirt-sock \
              --additional-packages "${containerPackages}"
          '';
          Restart = "on-failure";
          RestartSec = "30s";
        };
        wantedBy = [ "default.target" ];
      };

      "distrobox-${containerName}-cockpit" = {
        description = "Start Cockpit inside Management Distrobox";
        after = [ "distrobox-${containerName}-create.service" ];
        wants = [ "distrobox-${containerName}-create.service" ];

        path = [
          pkgs.distrobox
          pkgs.podman
          pkgs.coreutils
          pkgs.gawk
          pkgs.findutils
          pkgs.gnused
          pkgs.gnugrep
          pkgs.util-linux
          pkgs.bc
          pkgs.procps
          pkgs.hostname
          pkgs.which
        ];

        serviceConfig = {
          ExecStart = "${pkgs.distrobox}/bin/distrobox enter -n ${containerName} -- /usr/libexec/cockpit-ws --no-tls --port 9090";
          Restart = "always";
          RestartSec = "10s";
        };
        wantedBy = [ "default.target" ];
      };
    };
  };
}
