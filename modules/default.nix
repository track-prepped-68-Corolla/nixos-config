{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:

{
  # 1. Imports MUST be at the top level, outside of 'config'
  imports = [
    ./services/sddm.nix
    ./services/printing
    ./desktops/plasma.nix
    ./hardware/nvidia.nix
    ./system/virt.nix
    ./system/podman.nix
    ./profiles/gaming.nix
    ./themes/catppuccin.nix
  ];
}
