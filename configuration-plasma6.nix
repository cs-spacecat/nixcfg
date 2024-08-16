{ config, pkgs, ... }:

{
  system.stateVersion = "24.05";
  imports = [
      ./hardware-configuration.nix
      (import "${builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz"}/nixos")
    ];


  # ------ test place -----------

  # doesent work sadly
  #system.userActivationScripts.script.text = "mpvpaper '*' wp8214759.mp4 -p -o 'no-audio --loop-playlist'";


  # ---- end test place ---------


  # Prevent the new user dialog in zsh
  system.userActivationScripts.zshrc = "touch .zshrc";
  fileSystems."/run/media/spacecat/4tb-hdd".device = "/dev/disk/by-uuid/1c16e4a2-6027-4f80-b880-b37395562a0a";   # Automount HDD
  security.rtkit.enable = true;
  systemd.services.atuin.enable = true;
  system.autoUpgrade.enable = true;  # enable auto updates
  nixpkgs.config.allowUnfree = true;
  documentation.nixos.enable = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];  # experimental features


  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    useOSProber = true;
  };

  users.users.spacecat = {
    isNormalUser = true;
    description = "spacecat";
    extraGroups = [ "networkmanager" "wheel" "dialout" "adbusers" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };

  networking = {
    hostName = "Kommandozentrale";
    networkmanager.enable = true;  # Enable networking
    firewall.allowedTCPPorts = [];
    firewall.allowedUDPPorts = [];
  };

  # time zone & locale settings
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services = {
    xserver.enable = true;  # Enable the X11 windowing system.

    pcscd.enable = true;  # required for pinentry

    # Enable the KDE Plasma Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    xserver.xkb.layout = "de";  # German Keymap

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # Configure console keymap
  console.keyMap = "de";

  hardware = {
    pulseaudio.enable = false;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    steam-hardware.enable = true;  # better controller support
  };

  programs = {
    steam.remotePlay.openFirewall = true;

    steam.enable = true;
    adb.enable = true;
    gnupg.agent.enable = true;
    zsh.enable = true;

    gnupg.agent = {
      pinentryPackage = pkgs.pinentry-qt;
      settings = {
        max-cache-ttl = 0;
        default-cache-ttl = 0;
      };
    };

    zsh = {
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableBashCompletion = true;
      shellAliases = {
        rebuild = "sudo nixos-rebuild switch";
        clean = "nix-store --gc";
        configure = "kate /etc/nixos/configuration.nix";
      };
      ohMyZsh = {
        enable = true;
        theme = "gnzh";
        plugins = [
          "git"
          #"history"
        ];
      };
    promptInit = ''
        eval "$(atuin init zsh)"
      '';
    };
  };

  home-manager.users.spacecat = {
    home.stateVersion = "24.05";
    programs.git = {
      enable = true;
      userEmail = "theonoll@gmx.de";
      userName = "cs-spacecat";
    };
  };

  services.xserver.excludePackages = with pkgs; [
    xterm
  ];
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    khelpcenter
    kwrited
    okular
    print-manager
  ];
  environment.systemPackages = with pkgs; [
    google-chrome
    discord
    steam
    heroic
    (opera.override { proprietaryCodecs = true; })  # video steaming support for opera

    # cli
    usbutils
    fzf
    wget
    unzip
    pstree
    atuin
    vnstat  # network stat tracker
    ffmpeg-full
    #mpvpaper

    # pgp
    pinentry-qt
    gnupg

    # ui
    simp1e-cursors
    utterly-round-plasma-style

    # python libs
    python3
    updog

    # NixOS
    home-manager

    # dictionaries
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-science
    aspellDicts.en-computers
    ];
}

