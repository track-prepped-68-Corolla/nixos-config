{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.system.nh;

  # --- Script 1: sys-test (Dry Run) ---
  sysTestScript = pkgs.writeShellScriptBin "sys-test" ''
    set -e
    FLAKE_DIR="${cfg.flakeDir}"
    echo "--- ✨ Formatting ---"
    ${pkgs.findutils}/bin/find "$FLAKE_DIR" -name "*.nix" -exec ${pkgs.nixfmt-rfc-style}/bin/nixfmt {} +
    echo "--- 🛠️  Staging ---"
    ${pkgs.git}/bin/git -C "$FLAKE_DIR" add .
    echo "--- 🧪 Running Test ---"
    ${pkgs.nh}/bin/nh os test "$FLAKE_DIR" --ask
    echo "✅ Test complete. Reboot to revert."
  '';

  # --- Script 2: sys-update (Commit & Switch) ---
  sysUpdateScript = pkgs.writeShellScriptBin "sys-update" ''
    set -e
    FLAKE_DIR="${cfg.flakeDir}"
    echo "--- ✨ Formatting ---"
    ${pkgs.findutils}/bin/find "$FLAKE_DIR" -name "*.nix" -exec ${pkgs.nixfmt-rfc-style}/bin/nixfmt {} +
    echo "--- 🛠️  Staging ---"
    ${pkgs.git}/bin/git -C "$FLAKE_DIR" add .
    echo "--- 🔍 Previewing ---"
    ${pkgs.nh}/bin/nh os test "$FLAKE_DIR" --dry
    echo ""
    read -p "Apply and commit? [y/N]: " choice
    if [[ "$choice" =~ ^[yY]$ ]]; then
      echo "--- 🚀 Switching ---"
      ${pkgs.nh}/bin/nh os switch "$FLAKE_DIR"
      echo "--- 💾 Committing ---"
      read -p "Commit message: " msg
      ${pkgs.git}/bin/git -C "$FLAKE_DIR" commit -m "$msg"
      echo "✅ Update Complete!"
    else
      echo "🛑 Cancelled."
    fi
  '';

  # --- Script 3: sys-down (Pull & Switch) ---
  sysDownScript = pkgs.writeShellScriptBin "sys-down" ''
    set -e
    FLAKE_DIR="${cfg.flakeDir}"
    echo "--- ⬇️  Pulling updates ---"
    ${pkgs.git}/bin/git -C "$FLAKE_DIR" pull --rebase --autostash
    echo "--- 🚀 Building and Switching ---"
    ${pkgs.nh}/bin/nh os switch "$FLAKE_DIR" --ask
    echo "✅ System updated!"
  '';

in
{
  options.modules.system.nh = {
    enable = mkEnableOption "nh helper, standardized scripts, and formatting";

    flakeDir = mkOption {
      type = types.str;
      default = "/home/joe/git/nixos-config";
      description = "The absolute path to your NixOS flake directory.";
    };
  };

  # Everything below is ONLY applied if enable = true
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.nh
      pkgs.nvd
      pkgs.nix-output-monitor
      pkgs.nixfmt-rfc-style
      sysTestScript
      sysUpdateScript
      sysDownScript
    ];

    environment.sessionVariables = {
      NH_FLAKE = cfg.flakeDir;
    };

    environment.shellAliases = {
      try = "sys-test";
      up = "sys-update";
      down = "sys-down";
      cl = "nh clean all";
    };
  };
}
