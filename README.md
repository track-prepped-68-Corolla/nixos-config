❄️ My Modular NixOS Config
A personal NixOS configuration managed via Flakes. This setup is designed to be modular, allowing for easy sharing of services, desktop environments, and hardware tweaks across multiple machines.

🏗️ Structure Overview
hosts/: Machine-specific configurations (e.g., rog for gaming, thinkpad for work).

modules/: Reusable components categorized by function:

desktops/: UI and Window Managers (Plasma).

hardware/: Drivers and hardware-specific optimizations (Nvidia).

profiles/: Collections of packages for specific use cases (Gaming).

services/: System-level services (SDDM).

system/: Core system functionality (Virtualization).

themes/: Visual styling (Catppuccin).

users/: Individual user profiles and home-manager configurations.

🚀 Getting Started
1. Clone the repository
Bash

git clone https://github.com/your-username/your-repo.git
cd your-repo
2. Apply configuration
To apply the configuration to a specific host, use nixos-rebuild:

For the ROG Laptop:

Bash

sudo nixos-rebuild switch --flake .#rog
For the Thinkpad:

Bash

sudo nixos-rebuild switch --flake .#thinkpad
🛠️ Maintenance
Update Flake inputs
To update all dependencies (nixpkgs, etc.):

Bash

nix flake update
Garbage Collection
To clean up old generations and free up disk space:

Bash

sudo nix-collect-garbage -d
🎨 Key Features
Theme: System-wide styling using Catppuccin.

Desktop: KDE Plasma managed via modular imports.

Gaming: Dedicated profile for optimized gaming performance.

Virtualization: Pre-configured virt-manager/libvirt setup.

👥 Users
Jen: Main workstation user.

Joe: Secondary/Guest user.
