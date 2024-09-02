{ config, pkgs, ... }:

let
  user = "";
  hostname = "";
  lang = "";
  gitEmail = "";
  gitUser = "";
  nixVer = "24.05";
in {
  imports = [
      ./hardware-configuration.nix
      (import "${builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-${nixVer}.tar.gz"}/nixos")
    ];


  # ------ test place -----------

  # doesent work sadly
  #system.userActivationScripts.script.text = "mpvpaper '*' wp8214759.mp4 -p -o 'no-audio --loop-playlist'";

  # ---- end test place ---------

  system.stateVersion = nixVer;
  system.autoUpgrade.enable = true;  # enable auto updates
  system.userActivationScripts.zshrc = "touch .zshrc";   # Prevent the new user dialog in zsh
  fileSystems."/run/media/spacecat/4tb-hdd".device = "/dev/disk/by-uuid/1c16e4a2-6027-4f80-b880-b37395562a0a";   # Automount HDD
  security.rtkit.enable = true;
  nixpkgs.config.allowUnfree = true;
  documentation.nixos.enable = false;  # disable NixOS help entry
  nix.settings.experimental-features = [ "nix-command" "flakes" ];  # experimental features
  console.keyMap = "de";   # Configure console keymap



  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "/dev/nvme0n1";
    useOSProber = true;
  };

  users.users.spacecat = {
    isNormalUser = true;
    description = "spacecat";
    extraGroups = [ "networkmanager" "wheel" "dialout" "adbusers" "libvirtd" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };

  networking = {
    hostName = hostname;
    networkmanager.enable = true;  # Enable networking
    firewall.allowedTCPPorts = [];
    firewall.allowedUDPPorts = [];
  };

  # time zone & locale settings
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = lang;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = lang;
    LC_IDENTIFICATION = lang;
    LC_MEASUREMENT = lang;
    LC_MONETARY = lang;
    LC_NAME = lang;
    LC_NUMERIC = lang;
    LC_PAPER = lang;
    LC_TELEPHONE = lang;
    LC_TIME = lang;
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;  # vm USB passthrough
  systemd.services.atuin.enable = true;
  services = {
    xserver = {
      enable = true;  # Enable the X11 windowing system.
      xkb.layout = "de";  # German Keymap
      videoDrivers = ["amdgpu"];
    };
    #xserver.enable = true;  # Enable the X11 windowing system.

    pcscd.enable = true;  # required for pinentry

    # Enable the KDE Plasma Desktop Environment.
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    #xserver.xkb.layout = "de";  # German Keymap

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    pulseaudio.enable = false;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    steam-hardware.enable = true;  # better controller support
  };

  programs = {
    #steam.remotePlay.openFirewall = true;

    steam.enable = true;
    adb.enable = true;
    gnupg.agent.enable = true;
    zsh.enable = true;
    virt-manager.enable = true;
    streamdeck-ui.enable = true;
    #streamdeck-ui.autoStart = true;

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
        rebuild   = "sudo nixos-rebuild switch --show-trace";
        clean     = "nix-store --gc";
        configure = "sudo nano /etc/nixos/configuration.nix && rebuild";
        o         = "xdg-open . &";
        open      = "xdg-open . &";

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
    home.stateVersion = nixVer;
    programs.git = {
      enable = true;
      userEmail = gitEmail;
      userName = gitUser;
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
    streamdeck-ui
    discord
    steam
    heroic
    (opera.override { proprietaryCodecs = true; })  # video steaming support for opera
    vlc
    keepassxc
    vscode
    gparted

    # cli
    usbutils  # lsusb
    fzf
    wget
    file
    unzip
    pstree
    atuin
    vnstat  # network stat tracker
    ffmpeg-full
    tree
    btop
    cmatrix
    cowsay
    #mpvpaper

    # pgp
    pinentry-qt
    gnupg
    #kgpg

    # ui
    simp1e-cursors
    utterly-round-plasma-style

    # python libs
    python3
    updog

    # NixOS
    home-manager

    # dictionaries (mainly for kRunner)
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-science
    aspellDicts.en-computers

    # remove l8r
    #cmake  
    #gcc    
    #gnumake
    clinfo
  ];
}

