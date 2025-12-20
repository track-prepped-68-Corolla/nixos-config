# ❄️ Modular NixOS Configuration

A structured, flakes-based NixOS configuration featuring a modular approach to hardware, services, and user environments.

## 📂 Project Structure

```text
.
├── hosts        # Machine-specific configurations
├── modules      # Reusable logic (Desktop, Services, Hardware)
├── users        # User-specific home-manager/system configs
└── flake.nix    # Entry point for the configuration

```

---

## 🛠️ Module Breakdown

| Directory | Description |
| --- | --- |
| **`hosts/`** | Contains `rog` (Laptop) and `thinkpad` (Work). Includes hardware-specific auto-gens. |
| **`modules/desktops`** | Desktop Environments (e.g., Plasma). |
| **`modules/hardware`** | Hardware-specific tweaks (Nvidia drivers, etc.). |
| **`modules/profiles`** | High-level bundles like `gaming.nix`. |
| **`modules/services`** | Standalone daemons and utilities like `sddm.nix`. |
| **`modules/system`** | Core OS level logic like Virtualization (`virt.nix`). |
| **`modules/themes`** | Visual styling and colorschemes (Catppuccin). |

---

## 🚀 Installation & Usage

### 1. Initial Setup

Ensure you have **Nix** installed with `flakes` and `nix-command` enabled.

```bash
git clone [https://github.com/your-username/your-repo.git](https://github.com/your-username/your-repo.git)
cd your-repo

```

### 2. Apply Configuration

Apply the configuration to your current machine using its hostname defined in the flake:

```bash
# For the ROG laptop
sudo nixos-rebuild switch --flake .#rog

# For the Thinkpad
sudo nixos-rebuild switch --flake .#thinkpad

```

### 3. Maintenance

Keep your system and inputs up to date:

```bash
# Update flake.lock
nix flake update

# Cleanup old generations
sudo nix-collect-garbage -d

```

---

## 🎨 Design Philosophy

* **Modularity:** Every component in `modules/` is designed to be toggleable.
* **Consistency:** Uses **Catppuccin** for a unified system-wide theme.
* **Multi-user:** Separate configurations for `jen` and `joe` to keep environments isolated.

---

> [!TIP]
> When adding new hardware, always remember to copy your `hardware-configuration.nix` from `/etc/nixos/` into the respective `hosts/<name>` directory.
Would you like me to generate the **`flake.nix`** file that matches this specific directory structure?

```
