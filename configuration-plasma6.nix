{ config, pkgs, ... }:

let
  user = "";
  hostname = "";
  lang = "de_DE.UTF-8";
  gitEmail = "";
  gitUser = "";
  nixVer = "24.05";
in {
  imports = [
      ./hardware-configuration.nix
      (import "${builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-${nixVer}.tar.gz"}/nixos")
    ];


  # ------ test place -----------
  services.udev.packages = [ pkgs.streamdeck-ui ];

  # doesent work sadly
  #system.userActivationScripts.script.text = "mpvpaper '*' wp8214759.mp4 -p -o 'no-audio --loop-playlist'";

  #hardware.opengl = { # hardware.graphics on unstable
  #  enable = true;
  #  extraPackages = with pkgs; [
  #    intel-media-driver # LIBVA_DRIVER_NAME=iHD
  #    intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
  #    libvdpau-va-gl
  #  ];
  #};

  # ---- end test place ---------

  system.stateVersion = nixVer;
  system.autoUpgrade.enable = true;  # enable auto updates
  system.userActivationScripts.zshrc = "touch .zshrc";   # Prevent the new user dialog in zsh
  fileSystems."/run/media/spacecat/4tb-hdd".device = "/dev/disk/by-uuid/1c16e4a2-6027-4f80-b880-b37395562a0a";   # Automount HDD
  security.rtkit.enable = true;
  nixpkgs.config.allowUnfree = true;
  documentation.nixos.enable = false;  # disable NixOS help entry
  nix.settings.experimental-features = [ "nix-command" "flakes" ];  # experimental features
  nix.settings.auto-optimise-store = true;
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
    extraGroups = [ "networkmanager" "wheel" "dialout" "adbusers" "libvirtd" "video" ];
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
    # --- davfs (mount webdav as filesystem) ---
    davfs2.enable = true;
    #systemd.services.davfs = {
    #  Description = "Mount WebDAV Service";
    #  After = [ "network-online.target" ];
    #  Wants= [ "network-online.target" ];

    #  [Mount]
    #  What=http(s)://address:<port>/path
    #  Where=/mnt/webdav/service
    #  Options=uid=1000,file_mode=0664,dir_mode=2775,grpid
    #  Type=davfs
    #  TimeoutSec=15

    #  [Install]
    #  WantedBy=multi-user.target
    #};
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
        sl        = "${pkgs.sl}/bin/sl -Gw";
      };
      shellInit = ''
        ex () {  # ex - archive extractor
          if [ -f $1 ] ; then
            case $1 in
              *.tar.bz2)   tar xjf $1   ;;
              *.tar.gz)    tar xzf $1   ;;
              *.tar.xz)    tar xJf $1   ;;
              *.bz2)       bunzip2 $1   ;;
              *.rar)       unrar x $1     ;;
              *.gz)        gunzip $1    ;;
              *.tar)       tar xf $1    ;;
              *.tbz2)      tar xjf $1   ;;
              *.tgz)       tar xzf $1   ;;
              *.zip)       unzip $1     ;;
              *.Z)         uncompress $1;;
              *.7z)        7z x $1      ;;
              *)           echo "'$1' cannot be extracted via ex()" ;;
            esac
          else
            echo "'$1' is not a valid file"
          fi
        }
      '';
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
  
  fonts = {  # copied from https://github.com/ChrisTitusTech/nixos-titus/blob/main/system/configuration.nix
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      source-han-sans
      source-han-sans-japanese
      source-han-serif-japanese
      (nerdfonts.override {fonts = ["Meslo"];})
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["Meslo LG M Regular Nerd Font Complete Mono"];
        serif = ["Noto Serif" "Source Han Serif"];
        sansSerif = ["Noto Sans" "Source Han Sans"];
      };
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
    #print-manager
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
    keepassxc
    arduino
    inkscape-with-extensions

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
    sl
    p7zip  # 7z support
    #mpvpaper

    # kde

    # pgp
    pinentry-qt
    gnupg
    #kgpg

    # ui
    simp1e-cursors
    utterly-round-plasma-style

    # python libs
    python3
    python311Packages.pyserial
    python3Packages.rpi-gpio
    python3Packages.datetime
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
    smuview  # Multimeter
  ];
}

