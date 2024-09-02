{ config, pkgs, lib, ... }:

let
  user = "";
  password = "";
  hostname = "";
  lang = "";

in {
  imports = [
    "${fetchTarball "https://github.com/NixOS/nixos-hardware/tarball/master"}/raspberry-pi/4"
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

  networking = {
    hostName = hostname;
    networkmanager.enable = true;  # Enable networking
    firewall.allowedTCPPorts = [ ];
    firewall.allowedUDPPorts = [ ];
  };

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
  environment.systemPackages = with pkgs; [
    zsh
  ];
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.enable = true;  # for sftp editing this file

  users = {
    #mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      password = password;
      extraGroups = [ "wheel" "docker" ];
      shell = pkgs.zsh;
    };
    users."root".password = password;
  };

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

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.05";
}
