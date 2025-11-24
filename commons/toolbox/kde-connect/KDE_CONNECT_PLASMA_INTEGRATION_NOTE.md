# Add to your /etc/nixos/configuration.nix

# Enable KDE Connect
programs.kdeconnect.enable = true;

# Enable Plasma Browser Integration native host
programs.plasma-browser-integration.enable = true;

# Configure firewall for KDE Connect (ports 1714-1764)
networking.firewall = rec {
  allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  allowedUDPPortRanges = allowedTCPPortRanges;
};

# Optional: If you want to ensure the plasma-browser-integration package is installed
environment.systemPackages = with pkgs; [
  plasma-browser-integration
  kdeconnect
];