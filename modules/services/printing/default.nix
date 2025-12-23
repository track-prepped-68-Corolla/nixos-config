{ pkgs, ... }:

{
  # Enable the CUPS daemon
  services.printing = {
    enable = true;

    # Enable the Virtual PDF Printer
    cups-pdf.enable = true;

    # Optional: Add common drivers for physical printers
    drivers = with pkgs; [
      gutenprint
      hplip
      brlaser
    ];
  };

  # Enable Avahi for network printer discovery (mDNS/Bonjour)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

}
