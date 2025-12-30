{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.containers.mgmt-box;

  # Container Configuration
  containerName = "mgmt";
  containerImage = "registry.fedoraproject.org/fedora:latest";

  # Packages to install inside the container
  containerPackages = builtins.concatStringsSep " " [
    "cockpit"
    "cockpit-podman" # Visibility into Podman containers
    "cockpit-machines" # Visibility into VMs (Libvirt/KVM)
    "podman"
    "libvirt-client" # 'virsh' tools
    "openssh-clients"
  ];
in
{
  options.modules.containers.mgmt-box = {
    enable = lib.mkEnableOption "Fedora Management Box (Cockpit on Port 9090)";
  };

  config = lib.mkIf cfg.enable {
    # Safety check
    assertions = [
      {
        assertion = config.modules.containers.distrobox.enable;
        message = "The Management Box requires 'modules.containers.distrobox.enable = true'.";
      }
    ];

    # Systemd User Services
    # Note: In NixOS modules, we use 'serviceConfig', 'wantedBy', etc.
    # instead of 'Service', 'Install', 'Unit'.
    systemd.user.services = {

      # Service 1: Create the container (Idempotent)
      "distrobox-${containerName}-create" = {
        description = "Create Fedora Management Distrobox";
        after = [
          "podman.service"
          "docker.service"
        ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "create-mgmt-box" ''
            if ! ${pkgs.distrobox}/bin/distrobox list | grep -q "${containerName}"; then
              echo "Creating ${containerName}..."
              ${pkgs.distrobox}/bin/distrobox create \
                --name "${containerName}" \
                --image "${containerImage}" \
                --yes \
                --volume /run/podman/podman.sock:/run/podman/podman.sock \
                --volume /run/libvirt/libvirt-sock:/run/libvirt/libvirt-sock \
                --additional-packages "${containerPackages}"
            else
              echo "${containerName} already exists."
            fi
          '';
          Restart = "on-failure";
          RestartSec = "30s";
        };

        wantedBy = [ "default.target" ];
      };

      # Service 2: Run Cockpit
      "distrobox-${containerName}-cockpit" = {
        description = "Start Cockpit inside Management Distrobox";
        # Ensure creation service finishes first
        after = [ "distrobox-${containerName}-create.service" ];
        wants = [ "distrobox-${containerName}-create.service" ];

        serviceConfig = {
          ExecStart = "${pkgs.distrobox}/bin/distrobox enter -n ${containerName} -- /usr/libexec/cockpit-ws --no-tls --port 9090";
          Restart = "always";
        };

        wantedBy = [ "default.target" ];
      };
    };
  };
}
