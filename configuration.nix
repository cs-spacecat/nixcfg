# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${builtins.fetchTarball "https://github.com/rycee/home-manager/archive/master.tar.gz"}/nixos")
    ];

  # enable auto updates
  system.autoUpgrade.enable = true;

  # Prevent the new user dialog in zsh
  system.userActivationScripts.zshrc = "touch .zshrc";

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "Kommandozentrale";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall.allowedTCPPorts = [];
  networking.firewall.allowedUDPPorts = [];

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
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
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  #users.defaultUserShell = pkgs.zsh;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.spacecat = {
    isNormalUser = true;
    description = "spacecat";
    extraGroups = [ "networkmanager" "wheel" "dialout" "adbusers" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
    #  thunderbird
    ];
  };
  #services.xserver.desktopManager.gnome3 = {
  #  extraGsettingsOverridePackages = pkgs.gnome3.gnome-settings-daemon

  #  extraGSettingsOverrides = ''
  #    [org/gnome/settings-daemon/plugins/media-keys]
  #    custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']
  #    help=@as []
  #    logout=@as []
  #    magnifier=@as []
  #    magnifier-zoom-in=@as []
  #    magnifier-zoom-out=@as []
  #    screenreader=@as []
      
  #    [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
  #    binding='<Shift><Control>Escape'
  #    command='/usr/bin/gnome-system-monitor &'
  #    name='Taskmanager'
   
  #    [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1]
  #    binding='<Super>e'
  #    command='nautilus -w other-locations:///'
  #    name='Explorer'
      
  #    [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2]
  #    binding='<Control><Alt>t'
  #    command='gnome-terminal &'
  #    name='Terminal'
  #  '';
  #};
  home-manager.users.spacecat = {
    home.stateVersion = "23.11";
    programs.git = {
      enable = true;
      userEmail = "theonoll@gmx.de";
      userName = "cs-spacecat";
    };
    
    dconf.settings = {
      "org/gnome/desktop/wm/keybindings" = {
        "activate-window-menu" = [ "Menu" ];
        "begin-move" = [];
        "begin-resize" = [];
        "cycle-group" = [];
        "cycle-group-backward" = [];
        "cycle-panels" = [];
        "cycle-panels-backward" = [];
        "cycle-windows" = [];
        "cycle-windows-backward" = [];
        "maximize" = [];
        "minimize" = [ "<Super>h" ];
        "move-to-monitor-down" = [];
        "move-to-monitor-up" = [];
        "move-to-workspace-1" = [];
        "move-to-workspace-last" = [];
        "move-to-workspace-left" = [ "<Alt><Super>Left" ];
        "move-to-workspace-right" = [ "<Alt><Super>Right" ];
        "panel-run-dialog" = [];
        "switch-applications" = [];
        "switch-applications-backward" = [];
        "switch-group" = [];
        "switch-group-backward" = [];
        "switch-input-source" = [];
        "switch-input-source-backward" = [];
        "switch-panels" = [];
        "switch-panels-backward" = [];
        "switch-to-workspace-1" = [];
        "switch-to-workspace-last" = [];
        "switch-to-workspace-left" = [ "<Control><Super>Left" ];
        "switch-to-workspace-right" = [ "<Control><Super>Right" ];
        "switch-windows" = [ "<Alt>Tab" ];
        "switch-windows-backward" = [ "<Shift><Alt>Tab" ];
        "toggle-fullscreen" = [ "F11" ];
        "toggle-maximized" = [];
        "unmaximize" = [];
      };
      #"org/gnome/settings-daemon/plugins/media-keys" = {
      #  custom-keybindings = [
      #    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0"
      #    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1"
      #    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2"
      #  ];
      #};
      #"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      #  "binding" = "<Shift><Control>Escape";
      #  "command" = "/usr/bin/gnome-system-monitor &";
      #  "name" = "Taskmanager";
      #};
      #"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      #  "binding" = "<Super>e";
      #  "command" = "nautilus -w other-locations:///";
      #  "name" = "Explorer";
      #};
      #"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      #  "binding" = "<Control><Alt>t";
      #  "command" = "gnome-terminal &";
      #  "name" = "Terminal";
      #};
      "org/gnome/shell" = {
        disable-user-extensions = false;
        # so that the installed extensions are acutally enabled, grab the values from dconf-editor
        enabled-extensions = [
          "emoji-copy@felipeftn"
          "app-hider@lynith.dev"
          "appindicatorsupport@rgcjonas.gmail.com"
          "clipboard-history@alexsaveau.dev"
          "ding@rastersoft.com"
          "gsconnect@andyholmes.github.io"
          "just-perfection-desktop@just-perfection"
          "KeepAwake@jepfa.de"
          "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
          "quick-settings-audio-panel@rayzeq.github.io"
          "tailscale@joaophi.github.com"
          "tiling-assistant@leleat-on-github"
          ];
        disabled-extensions = [];
      };
      "org/gnome/shell/extensions/clipboard-history" = {
        "toggle-menu" = [ "<Super>v" ];
        "window-width-percentage" = 20;
        "confirm-clear" = false;
      };
      "org/gnome/shell/extensions/emoji-copy" = {
        "recently-used" = [ "❤" "🫂" "😂" "💀" "😔" "🥹" "😮" "😘" ];
      };
      "org/gnome/shell/extensions/KeepAwake@jepfa.de" = {
        "no-color-background" = true;
        "enable-notifications" = false;
      };
      "org/gnome/shell/extensions/just-perfection" = {
        "accessibility-menu" = false;
        "keyboard-layout" = false;
        "panel-button-padding-size" = 8;
        "panel-icon-size" = 16;
        "panel-indicator-padding-size" = 11;
        "panel-size" = 33;
        "startup-status" = 0;
      };
    };
  };
  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "spacecat";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  nixpkgs.config.allowUnfree = true;
  services.xserver.excludePackages = with pkgs; [ xterm ];
  documentation.nixos.enable = false;
  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
    gnome.gnome-music
    gnome.gnome-logs
    gnome.geary
    gnome.yelp
    gnome.gnome-font-viewer
    gnome.gnome-characters
    gnome.gnome-shell-extensions

    baobab
    epiphany
    simple-scan
    yelp
    evince
    ]);

  environment.systemPackages = with pkgs; [
    # main
    home-manager
    python3
    usbutils
    fzf
    wget
    google-chrome
    pinentry-gnome3
    gnupg
    unzip
    pstree
    #gitFull
    atuin
    
    # python libs
    updog

    # gnome
    gnome.dconf-editor
    gnome.gnome-tweaks

    # gnome extensions
    gnomeExtensions.app-hider
    gnomeExtensions.appindicator
    gnomeExtensions.clipboard-history
    gnomeExtensions.desktop-icons-ng-ding
    gnomeExtensions.emoji-copy
    gnomeExtensions.gsconnect
    gnomeExtensions.just-perfection
    gnomeExtensions.keep-awake
    gnomeExtensions.launch-new-instance
    gnomeExtensions.quick-settings-audio-panel
    gnomeExtensions.tailscale-qs
    gnomeExtensions.tiling-assistant
    gnomeExtensions.user-themes
    ];

  programs.adb.enable = true; 
  #programs.git = {
  #  enable = true;
  #  package = pkgs.gitFull;
  #  config = {
  #    init = {
  #      defaultBranch = "main";
  #      userName = "cs-spacecat";
  #      userEmail = "theonoll@gmx.de";
  #    };
  #  };
  #};
  services.pcscd.enable = true;  # required for pinentry
  programs.gnupg.agent = {
    enable = true;
    # pinentryFlavor = "gnome3";
    pinentryPackage = pkgs.pinentry-gnome3;
    settings = {
      max-cache-ttl = 0;
      default-cache-ttl = 0;
    };
  #   enableSSHSupport = true;
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
    #interactiveShellInit = ''
    #  eval "$(atuin init zsh)"
    #'';
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
  programs.bash = {
    shellInit = ''
      eval "$(atuin init bash)"
    '';
  };
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
