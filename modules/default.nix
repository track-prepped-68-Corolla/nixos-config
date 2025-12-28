{
  imports = [

    # Default Apps
    ./apps

    # Desktops
    ./desktops/plasma.nix
    ./desktops/cosmic.nix

    # Hardware
    ./hardware/nvidia.nix
    ./hardware/amd.nix

    # Profiles
    ./profiles/gaming.nix
    ./profiles/couchgaming.nix

    # Services
    ./services/sddm.nix
    ./services/printing.nix

    # System
    ./system/virt.nix
    ./system/podman.nix
    ./system/user.nix

    # Themes
    ./themes/catppuccin.nix
  ];
}
