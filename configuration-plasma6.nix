{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      (import "${builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz"}/nixos")
    ];

  # enable auto updates
  system.autoUpgrade.enable = true;

  # Prevent the new user dialog in zsh
  system.userActivationScripts.zshrc = "touch .zshrc";

  # doesent work sadly
  #system.userActivationScripts.script.text = "mpvpaper '*' wp8214759.mp4 -p -o 'no-audio --loop-playlist'";

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme0n1";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "Kommandozentrale";

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [];

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.spacecat = {
    isNormalUser = true;
    description = "spacecat";
    extraGroups = [ "networkmanager" "wheel" "dialout" "adbusers" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };
  home-manager.users.spacecat = {
    home.stateVersion = "24.05";
    programs.git = {
      enable = true;
      userEmail = "theonoll@gmx.de";
      userName = "cs-spacecat";
    };
  };
  # Enable automatic login for the user.
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "spacecat";

  nixpkgs.config.allowUnfree = true;
  services.xserver.excludePackages = with pkgs; [ xterm ];
  documentation.nixos.enable = false;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    khelpcenter
    kwrited
    okular
    print-manager
  ];

  environment.systemPackages = with pkgs; [
    # main
    home-manager
    python3
    usbutils
    fzf
    wget
    google-chrome
    pinentry-qt
    gnupg
    unzip
    pstree
    atuin
    vnstat
    mpvpaper
    (opera.override { proprietaryCodecs = true; }) # video steaming support
    ffmpeg-full
    discord
    steam

    #dictionaries
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-science
    aspellDicts.en-computers

    # ux
    simp1e-cursors
    utterly-round-plasma-style

    # python libs
    updog
    ];

  # Automount HDD
  fileSystems."/run/media/spacecat" = {
    device = "/dev/disk/by-uuid/1c16e4a2-6027-4f80-b880-b37395562a0a";
  };

  hardware.steam-hardware.enable = true;
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;

  programs.adb.enable = true;
  services.pcscd.enable = true;  # required for pinentry
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    settings = {
      max-cache-ttl = 0;
      default-cache-ttl = 0;
    };
  };
  systemd.services.atuin = {
    enable = true;
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    enableBashCompletion = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch";
      clean = "nix-store --gc";
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
  system.stateVersion = "24.05";
}
