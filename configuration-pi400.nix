{ config, pkgs, lib, ... }:

let
  user            = "";
  password        = "";
  hostname        = "";
  disk            = "";
  cloudflareToken = "";
  ssh_keys        = [ "" ];
  vscodeToken     = "";
  lang            = "de_DE.UTF-8";
  nixVer          = "24.11";

in {
  imports = [
    "${fetchTarball "https://github.com/NixOS/nixos-hardware/tarball/master"}/raspberry-pi/4"
    #./hardware-configuration.nix
  ];

  #  --- Test ---
  # Create gpio group
  users.groups.gpio = {};
  #boot.loader.raspberryPi.firmwareConfig = ' dtoverlay=pwm ';
  # Change permissions gpio devices
  services.udev.extraRules = ''
    SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio",MODE="0660"
    SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
    SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add",RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
  '';

  #  --- Only Office ---
  #services.onlyoffice = {
  #  port = 8012;
  #  hostname = "127.0.0.1";
  #  enable = true;
  #  enableExampleServer = true;
  #  examplePort = 8013;
  #};

  #  --- Tailscale ---
  #networking.firewall.checkReversePath = "loose";
  boot.kernel.sysctl = { # important for forwarding routes!
    "net.ipv6.conf.all.forwarding" = "1";
    "net.ipv4.ip_forward" = "1";
  };
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "server";
    extraSetFlags = [ 
      "--accept-routes"
      "--advertise-connector"
      "--advertise-exit-node"
      "--operator=${user}"
      "--advertise-routes=192.168.178.0/24"     #   change me !!!!!!!
      "--ssh"
    ];
    extraUpFlags = [ "--ssh" ];
    extraDaemonFlags = [ ];
  };



  hardware.enableRedistributableFirmware = true;
  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;  # gpio
  hardware.deviceTree = {  # gpio
    enable = true;
    filter = "*-rpi-*.dtb";
  };
  system.stateVersion = nixVer;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
	

  # --- Networking ---
  networking = {
    hostName = hostname;
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;  # Enable networking
    firewall.allowedTCPPorts = [
      22  # ssh
      631  # cups open port
      3401  # vscode Server
      4918  # HTTPS WebDAV server
      4444  # quickUP WebDAV
      9090  # updog
      41641 # tailscale
    ];
    firewall.allowedUDPPorts = [
      22  # ssh
      631  # cups open port
      3401  # vscode Server
      4918  # HTTPS WebDAV server
      9090  # updog
      41641 # tailscale
    ];
    firewall.checkReversePath = "loose";
  };

  # --- Syncthing ---
  services.syncthing = {
    enable = true;
    user = "${user}";
    overrideFolders = false;
    overrideDevices = false;
    settings.options.urAccepted = 5;
    options.relaysEnabled = true;
    options.localAnnounceEnabled = true;
    openDefaultPorts = true;
    dataDir = "/home/${user}/syncthing";
    configDir = "/home/${user}/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
    extraFlags = [ ];
    settings.devices = {
      "handy" = { id = "7NCAMAL-HKUX2AB-J6QYDWP-H6EKRGT-O4R6QNZ-FS63QV6-QEMCWPB-NDD6QQR"; };
    };
    options.settings.gui = {
      user = "${user}";
      password = "${password}";
    };
    settings.folders = {
      "falken-drive" = {
        path = "/home/${user}/syncthing/falken-drive";
        devices = [ "handy" ];
        versioning = {
          type = "trashcan";
          params.cleanoutDays = "1000";
        };
      };
    };
  };


  # --- WebDAV --- (mainly for KeePass) (dirty but works!)
  systemd.services.dufs-webdav = {
    description = "dufs WebDAV Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      WorkingDirectory = "/home/${user}/webDAV";
      ExecPre = "mkdir -p /home/${user}/webDAV";  # create folder if not exists
      ExecStart = "${pkgs.dufs}/bin/dufs -p 443 -a ${user}:${password}@/:rw -A";
      Restart = "always";
      RestartSec = "10s";
    };
  };

  # --- quick Upload server ---
  systemd.services.dufs-webdav2 = {
    description = "dufs WebDAV Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      WorkingDirectory = "/home/${user}/quickUP";
      ExecPre = "mkdir -p /home/${user}/quickUP";  # create folder if not exists 
      ExecStart = "${pkgs.dufs}/bin/dufs -p 444 --allow-upload";
      Restart = "always";
      RestartSec = "10s";
    };
  };


  # --- Vaultwarden ---
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    #backupDir = "/var/backup/vaultwarden";
    config = {
      ROCKET_ADRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "ssh-key-vault-item,ssh-agent";
    };
  };


  # --- CUPS printing service ---
  services.printing.enable = true;
    services.printing.drivers = [
    #pkgs.gutenprint # — Drivers for many different printers from many different vendors.
    #pkgs.gutenprintBin # — Additional, binary-only drivers for some printers.
    pkgs.hplip # — Drivers for HP printers.
    #pkgs.hplipWithPlugin # — Drivers for HP printers, with the proprietary plugin. Use NIXPKGS_ALLOW_UNFREE=1 nix-shell -p hplipWithPlugin --run 'sudo -E hp-setup' to add the printer, regular CUPS UI doesn't seem to work.
    #pkgs.postscript-lexmark # — Postscript drivers for Lexmark
    #pkgs.samsung-unified-linux-driver # — Proprietary Samsung Drivers
    #pkgs.splix # — Drivers for printers supporting SPL (Samsung Printer Language).
    #pkgs.brlaser # — Drivers for some Brother printers
    #pkgs.brgenml1lpr #  — Generic drivers for more Brother printers [1]
    #pkgs.brgenml1cupswrapper  # — Generic drivers for more Brother printers [1]
    #pkgs.cnijfilter2 # — Drivers for some Canon Pixma devices (Proprietary driver)
  ];

  services.avahi = {  # enable printer discovery (idk this just works, dont ask)
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
  services.printing = {
    listenAddresses = [ "*:631" ];
    allowFrom = [ "all" ];
    browsing = true;
    defaultShared = true;
  };
  hardware.printers = {
    ensurePrinters = [{  # add printer declaratively, so that it always appears
      name = "Laserjet-2200";
      description = "HP Laserjet 2200D";
      location = "Wohnzimmer Wandschrank";
      deviceUri = "usb://HP/LaserJet%202200?serial=00CNHRB43441";
      model = "HP/hp-laserjet_2200_series.ppd.gz";  #ls /nix/store/*-hplip-*/share/cups/model/HP/ | grep laserjet_2200    "HP/hp-laserjet_2200-ps.ppd.gz"  "HP/hp-laserjet_2200_series.ppd.gz"  "HP/hp-laserjet_2200_series-ps.ppd.gz"
      #model = "${pkgs.hplip}/share/cups/model/HP/hp-laserjet_2200_series-ps.ppd.gz";
      ppdOptions = {
        PageSize = "A4";
        #Duplex = "DuplexNoTumble";
      };
    }];
  };

  # ---- OpenSSH ----
  services.openssh = {
    settings.PermitRootLogin = "yes";
    enable = true;  # for sftp editing this file
    settings = {
      PasswordAuthentication = false;
    };
  };


  # ---- led strip display ----
  systemd.services.ledstripController = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.python3} /home/spacecat/ledstripController/main.py";
      Restart = "always";
      RestartSec = "10s";
      User = "root";
    };
  };

  # ---- Cloudflared ----
  systemd.services.cloudflared_tunnel = {  # for publicly hosting local websites
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token=${cloudflareToken}";
      Restart = "always";
      User = "${user}";
      #Group = "cloudflared";
    };
  };

  # ---- Zshell ----
  system.userActivationScripts.zshrc = "touch .zshrc";   # Prevent the new user dialog in zsh
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableBashCompletion = true;
      shellAliases = {
        rebuild   = "sudo time nixos-rebuild switch --show-trace";
        clean     = "time nix-store --gc && sudo time nix-collect-garbage -d";
        configure = "sudo nano /etc/nixos/configuration.nix && time rebuild";
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
        plugins = [ "git" ];
      };
      promptInit = '' '';
    };
  };

  # --- sys Packages ---
  environment.systemPackages = with pkgs; [
    zsh
    btop
    dufs
    libraspberrypi

    cloudflared
    vscode
    onlyoffice-documentserver
    cups
    tailscale
    vaultwarden
    (python3.withPackages (p: with p; [
      rpi-gpio
      pip
      pyserial
    ]))
    #
    wget
    git
    gcc
    zulu23  # java
    libraspberrypi
    screen
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    kernelModules = [ "pwm_bcm2835" "w1-gpio" ];
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" "bcm2835_dma" "vc4" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      #grub.device = "/dev/disk/by-label/NIXOS_SD";
    };
  };

  users = {
    #mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      password = password;
      extraGroups = [ "wheel" "gpio" ];  # "docker"
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = ssh_keys;
    };
    users."root" = {
      password = password;
      extraGroups = [ "wheel" ];
    };
  };

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

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${disk}";
    fsType = "ext4";
  };
}
