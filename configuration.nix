{ config, pkgs, hostname, inputs, ... }:

let
  user = "ayles";
  stateVersion = "22.11";
in
{
  imports = with inputs; [
    home-manager.nixosModules.default
    hyprland.nixosModules.default
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  security.sudo.wheelNeedsPassword = false;

  programs.hyprland = {
    enable = true;
    nvidiaPatches = true;
  };

  home-manager.users.${user} = {
    home = {
      pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };
      stateVersion = stateVersion;
    };
    gtk.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (self: super: {
      google-chrome = super.google-chrome.override {
        commandLineArgs = "--enable-features=WebUIDarkMode --force-dark-mode";
      };
    })
  ];

  fonts = {
    fonts = with pkgs; [
      noto-fonts
      (nerdfonts.override { fonts = [ "Meslo" ]; })
    ];
  };

  # Use the grub EFI boot loader.
  # boot.kernelParams = [ "nomodeset" ];
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      default = "saved";
    };
  };

  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";

  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;
  hardware.nvidia.modesetting.enable = true;
  hardware.bluetooth.enable = true;

  services.hardware.openrgb.enable = true;
  services.blueman.enable = true;
  services.openvpn.servers = {
    butter = {
        config = ''
            config /home/${user}/.openvpn/butter.conf
            connect-retry 15
        '';
        autoStart = false;
    };
  };

  # Enable the X11 windowing system.
  # Needed only for sddm, just for now
  services.xserver.enable = true;
  services.xserver.excludePackages = with pkgs; [ xterm ];
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;


  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.neovim.defaultEditor = true;

  virtualisation.docker.enable = true;

  # Some Windows dualboot compat
  time.hardwareClockInLocalTime = true;

  environment.defaultPackages = [ ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    (python311.withPackages (p: with p; [
        openai
    ]))
    chezmoi
    clang-tools
    cmake
    cmake-language-server
    curl
    dunst
    eww-wayland
    file
    fuzzel
    gdb
    git
    git-lfs
    google-chrome
    htop
    iftop
    jq
    kitty
    lldb
    neofetch
    neovim
    nixpkgs-fmt
    nodePackages.pyright
    perf-tools
    ripgrep
    rnix-lsp
    sumneko-lua-language-server
    tdesktop
    unzip
    wl-clipboard
  ];

  environment.sessionVariables = rec {
    LIBVA_DRIVER_NAME = "nvidia";
    EGL_PLATFORM = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
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

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?
}

