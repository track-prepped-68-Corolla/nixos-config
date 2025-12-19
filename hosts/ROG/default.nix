{ config, pkgs, lib, catppuccin, home-manager, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  jovian.steam.enable = true;

  jovian.steam.autoStart = false;

  jovian.steam.user = "joe";

  jovian.steam.desktopSession = "plasma";

  virtualisation.docker.enable = true;

  hardware.nvidia-container-toolkit.enable = true;

  virtualisation.vmware.host.enable = true;

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["joe"];

  virtualisation.libvirtd.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation.incus.enable = true;

  networking.nftables.enable = true;

  # enable NFS client
  #services.nfs.client.enable = true;

  # mount the export at /media/arr
  #fileSystems."/media/arr" = {
  #device = "10.0.0.113:/export/path"; # replace with your NAS export path
  #fsType = "nfs";                      # or "nfs4"
  #options = [ "rw" "hard" "_netdev" "vers=4" ]; # adjust options as needed
  #};

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot.loader.grub = {
  enable = true;
  # Use 'nodev' for EFI systems to install GRUB to the EFI system partition (ESP)
  device = "nodev";
};

  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  catppuccin.grub = {
    # This enables the theme module you provided in grub.nix (the lib.mkIf check)
    enable = true;

    # This sets the theme color, which the grub.nix file uses to build the path.
    # The Catppuccin project defines the following flavors:
    flavor = "mocha";
  };

# Enable Catppuccin globally
  catppuccin.enable = true;

# Set the desired flavor (mocha)
  catppuccin.flavor = "mocha";

# Set the accent color (mauve)
  catppuccin.accent = "mauve";

# Enable the binary cache for faster builds
  catppuccin.cache.enable = true;


  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_6_17;

  networking.hostName = "rog"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  #folga wooga imoga womp

  # Enable networking
  networking.networkmanager.enable = true;

  # BOOT OPTIMIZATION: Disables waiting for network to come online (removes 4.3s delay)
  systemd.network.wait-online.enable = false;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable asus supergfxctl (moved to nixos-hardware flake)
#  services.supergfxd.enable = true;

systemd.timers.fwupd-refresh.enable = false;

  security.pam.services.kwallet = {
  name = "kwallet";
  enableKwallet = true;
};

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.joe = {
    isNormalUser = true;
    description = "Joe";
    extraGroups = [ "networkmanager" "wheel" "docker" "incus-admin" ];
  };
  # Enable automatic login for the user.
  #services.displayManager.autoLogin.enable = true;
  #services.displayManager.autoLogin.user = "joe";

  # Install firefox.
  programs.firefox.enable = true;

  # install kde connect
  programs.kdeconnect.enable = true;

  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  gamescopeSession.enable = false;
};

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget                        # downlod
    ffmpeg                      # Media codecs
    unzip                       # unzipper
	distrobox					# distrobox
  ];

  fonts.packages = builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);


  home-manager = {
  # also pass inputs to home-manager modules
  extraSpecialArgs = {inherit inputs;};
  users = {
    "joe" = ./../../Users/Joe.nix;
  };
};


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
