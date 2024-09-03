{ config, pkgs, lib, ... }:

let
  user = "";
  password = "";
  hostname = "";
  cloudflareToken = "";
  lang = "";

in {
  imports = [
    "${fetchTarball "https://github.com/NixOS/nixos-hardware/tarball/master"}/raspberry-pi/4"
  ];
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.05";


  # --- Networking ---
  networking = {
    hostName = hostname;
    networkmanager.enable = true;  # Enable networking
    firewall.allowedTCPPorts = [
      22  # ssh
      631  # cups open port
      4918  # HTTPS WebDAV server
    ];
    firewall.allowedUDPPorts = [
      22  # ssh
      631  # cups open port
      4918  # HTTPS WebDAV server
    ];
  };

  # ---- docker ----
  #virtualisation.docker = {
  #  enable = true;
  #  rootless = {
  #    enable = true;
  #    setSocketVariable = true;
  #  };
  #  daemon.settings = {
  #    data-root = "/home/${user}/docker";
  #  };
  #};

  # --- WebDAV --- (mainly for KeePass) (dirty but works!)
  systemd.services.dufs-webdav = {
    description = "dufs WebDAV Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      #ExecStart = "${pkgs.dufs}/bin/dufs -p 4918 -a ${user}:${password}@/home/${user}/webDAV:rw --allow-delete --allow-upload --allow-search --allow-archive";
      WorkingDirectory = "/home/${user}/webDAV";
      ExecStart = "${pkgs.dufs}/bin/dufs -p 4918 -a ${user}:${password}@/:rw --allow-delete --allow-upload --allow-search --allow-archive";
      Restart = "always";
      RestartSec = "10s";
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
	#networking.firewall = {  # open ports to that you can access the printer via IPP
	#	allowedTCPPorts = [ 631 ];
	#	allowedUDPPorts = [ 631 ];
	#};
	hardware.printers = {
    ensurePrinters = [{  # add printer declaratively, so that it always appears
      name = "Laserjet-2200";
      description = "HP Laserjet 2200D";
      location = "Wohnzimmer Wandschrank";
      deviceUri = "usb://HP/LaserJet%202200?serial=00CNHRB43441";
      model = "HP/hp-laserjet_2200_series.ppd.gz";  #ls /nix/store/*-hplip-*/share/cups/model/HP/ | grep laserjet_2200    "HP/hp-laserjet_2200-ps.ppd.gz"  "HP/hp-laserjet_2200_series.ppd.gz"  "HP/hp-laserjet_2200_series-ps.ppd.gz"
      ppdOptions = {
        PageSize = "A4";
        #Duplex = "DuplexNoTumble";
      };
	}];
  };

  # ---- OpenSSH ----
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.enable = true;  # for sftp editing this file

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
        rebuild   = "sudo nixos-rebuild switch --show-trace";
        clean     = "nix-store --gc";
        configure = "sudo nano /etc/nixos/configuration.nix && rebuild";
      };
    promptInit = ''
      '';
    };
  };

  # --- sys Packages ---
  environment.systemPackages = with pkgs; [
    zsh
    btop
    cloudflared
    dufs
    cups
  ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
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
      extraGroups = [ "wheel"];  # "docker"
      shell = pkgs.zsh;
    };
    users."root".password = password;
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
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };
}
