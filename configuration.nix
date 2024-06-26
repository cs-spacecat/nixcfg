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
  # experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.spacecat = {
    isNormalUser = true;
    description = "spacecat";
    extraGroups = [ "networkmanager" "wheel" "dialout" "adbusers" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
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
      # "org/gnome/desktop/wm/keybindings" = {
      #   "activate-window-menu" = [ "Menu" ];
      #   "begin-move" = [];
      #   "begin-resize" = [];
      #   "cycle-group" = [];
      #   "cycle-group-backward" = [];
      #   "cycle-panels" = [];
      #   "cycle-panels-backward" = [];
      #   "cycle-windows" = [];
      #   "cycle-windows-backward" = [];
      #   "maximize" = [];
      #   "minimize" = [ "<Super>h" ];
      #   "move-to-monitor-down" = [];
      #   "move-to-monitor-up" = [];
      #   "move-to-workspace-1" = [];
      #   "move-to-workspace-last" = [];
      #   "move-to-workspace-left" = [ "<Alt><Super>Left" ];
      #   "move-to-workspace-right" = [ "<Alt><Super>Right" ];
      #   "panel-run-dialog" = [];
      #   "switch-applications" = [];
      #   "switch-applications-backward" = [];
      #   "switch-group" = [];
      #   "switch-group-backward" = [];
      #   "switch-input-source" = [];
      #   "switch-input-source-backward" = [];
      #   "switch-panels" = [];
      #   "switch-panels-backward" = [];
      #   "switch-to-workspace-1" = [];
      #   "switch-to-workspace-last" = [];
      #   "switch-to-workspace-left" = [ "<Control><Super>Left" ];
      #   "switch-to-workspace-right" = [ "<Control><Super>Right" ];
      #   "switch-windows" = [ "<Alt>Tab" ];
      #   "switch-windows-backward" = [ "<Shift><Alt>Tab" ];
      #   "toggle-fullscreen" = [ "F11" ];
      #   "toggle-maximized" = [];
      #   "unmaximize" = [];
      # };

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
      # "org/gnome/shell/extensions/clipboard-history" = {
      #   "toggle-menu" = [ "<Super>v" ];
      #   "window-width-percentage" = 20;
      #   "confirm-clear" = false;
      # };
      # "org/gnome/shell/extensions/emoji-copy" = {
      #   "recently-used" = [ "❤" "🫂" "😂" "💀" "😔" "🥹" "😮" "😘" ];
      # };
      # "org/gnome/shell/extensions/KeepAwake@jepfa.de" = {
      #   "no-color-background" = true;
      #   "enable-notifications" = false;
      # };
      # "org/gnome/shell/extensions/just-perfection" = {
      #   "accessibility-menu" = false;
      #   "keyboard-layout" = false;
      #   "panel-button-padding-size" = 8;
      #   "panel-icon-size" = 16;
      #   "panel-indicator-padding-size" = 11;
      #   "panel-size" = 33;
      #   "startup-status" = 0;
      # };
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
  services.pcscd.enable = true;  # required for pinentry
  programs.gnupg.agent = {
    enable = true;
    # pinentryFlavor = "gnome3";
    pinentryPackage = pkgs.pinentry-gnome3;
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
  services.xserver.desktopManager.gnome = {
    extraGSettingsOverridePackages = with pkgs; [ gnome3.gnome-settings-daemon ];
    extraGSettingsOverrides = ''
      [org/gnome/Weather]
      locations=[<(uint32 2, <('Berlin', 'EDDT', true, [(0.91746141594945008, 0.23241968454167572)], [(0.91658875132345297, 0.23387411976724018)])>)>]

      [org/gnome/desktop/app-folders/folders/ed4a187a-3b9c-4d65-ab6d-38aa3781e102]
      apps=['org.gnome.Weather.desktop', 'org.gnome.Maps.desktop', 'org.gnome.Calculator.desktop', 'md.obsidian.Obsidian.desktop', 'org.gnome.clocks.desktop', 'org.gnome.Contacts.desktop', 'io.github.Soundux.desktop', 'org.gnome.SystemMonitor.desktop', 'org.gnome.Software.desktop']
      name='Accessories'

      [org/gnome/desktop/calendar]
      show-weekdate=false

      [org/gnome/desktop/peripherals/keyboard]
      numlock-state=true

      [org/gnome/desktop/peripherals/mouse]
      accel-profile='flat'
      natural-scroll=false
      speed=-0.12396694214876036

      [org/gnome/desktop/peripherals/touchpad]
      two-finger-scrolling-enabled=true

      [org/gnome/desktop/wm/keybindings]
      activate-window-menu=['Menu']
      begin-move=@as []
      begin-resize=@as []
      cycle-group=@as []
      cycle-group-backward=@as []
      cycle-panels=@as []
      cycle-panels-backward=@as []
      cycle-windows=@as []
      cycle-windows-backward=@as []
      maximize=@as []
      minimize=['<Super>h']
      move-to-monitor-down=@as []
      move-to-monitor-up=@as []
      move-to-workspace-1=@as []
      move-to-workspace-last=@as []
      move-to-workspace-left=['<Alt><Super>Left']
      move-to-workspace-right=['<Alt><Super>Right']
      panel-run-dialog=['<Super>space']
      switch-applications=@as []
      switch-applications-backward=@as []
      switch-group=@as []
      switch-group-backward=@as []
      switch-input-source=@as []
      switch-input-source-backward=@as []
      switch-panels=@as []
      switch-panels-backward=@as []
      switch-to-workspace-1=@as []
      switch-to-workspace-last=@as []
      switch-to-workspace-left=['<Control><Super>Left']
      switch-to-workspace-right=['<Control><Super>Right']
      switch-windows=['<Alt>Tab']
      switch-windows-backward=['<Shift><Alt>Tab']
      toggle-fullscreen=['F11']
      toggle-maximized=@as []
      unmaximize=@as []

      [org/gnome/login-screen]
      enable-fingerprint-authentication=true
      enable-password-authentication=true
      enable-smartcard-authentication=false

      [org/gnome/mutter]
      check-alive-timeout=uint32 10000
      edge-tiling=false
      workspaces-only-on-primary=false

      [org/gnome/settings-daemon/plugins/media-keys]
      custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']
      help=@as []
      logout=@as []
      magnifier=@as []
      magnifier-zoom-in=@as []
      magnifier-zoom-out=@as []
      screenreader=@as []

      [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
      binding='<Shift><Control>Escape'
      command='/usr/bin/gnome-system-monitor &'
      name='Taskmanager'

      [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1]
      binding='<Super>e'
      command='nautilus -w other-locations:///'
      name='Explorer'

      [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2]
      binding='<Control><Alt>t'
      command='gnome-terminal &'
      name='Terminal'

      [org/gnome/shell/extensions/KeepAwake@jepfa.de]
      enable-notifications=false
      idle-activation-enabled=false
      idle-delay=0
      idle-dim=false
      no-color-background=true
      restore-state=false
      sleep-inactive-ac-type='nothing'
      sleep-inactive-battery-type='nothing'
      use-bold-icons=true

      [org/gnome/shell/extensions/appindicator]
      custom-icons=@a(sss) []
      icon-opacity=240
      icon-size=18
      tray-pos='right'

      [org/gnome/shell/extensions/clipboard-history]
      confirm-clear=false
      display-mode=0
      enable-keybindings=true
      toggle-menu=['<Super>v']
      topbar-preview-size=1
      window-width-percentage=20

      [org/gnome/shell/extensions/emoji-copy]
      recently-used=['😂', '❤️', '😍', '😭', '😊', '😒', '😘', '😩', '🤔', '☺️', '👌']

      [org/gnome/shell/extensions/just-perfection]
      accessibility-menu=true
      activities-button=true
      alt-tab-icon-size=0
      alt-tab-small-icon-size=0
      alt-tab-window-preview-size=0
      animation=1
      background-menu=true
      clock-menu=true
      clock-menu-position=0
      clock-menu-position-offset=0
      controls-manager-spacing-size=0
      dash=true
      dash-app-running=true
      dash-icon-size=0
      dash-separator=true
      double-super-to-appgrid=true
      keyboard-layout=true
      osd=true
      overlay-key=true
      panel=true
      panel-button-padding-size=0
      panel-icon-size=0
      panel-in-overview=true
      panel-indicator-padding-size=0
      panel-notification-icon=true
      panel-size=0
      power-icon=true
      quick-settings=true
      ripple-box=true
      search=true
      show-apps-button=true
      startup-status=1
      switcher-popup-delay=true
      theme=false
      top-panel-position=0
      window-demands-attention-focus=false
      window-menu-take-screenshot-button=true
      window-picker-icon=true
      window-preview-caption=true
      window-preview-close-button=true
      workspace=true
      workspace-background-corner-size=0
      workspace-peek=true
      workspace-popup=true
      workspace-switcher-should-show=false
      workspace-switcher-size=0
      workspace-wrap-around=false
      workspaces-in-app-grid=true
      world-clock=true

      [org/gnome/shell/extensions/tiling-assistant]
      activate-layout0=@as []
      activate-layout1=@as []
      activate-layout2=@as []
      activate-layout3=@as []
      active-window-hint=1
      active-window-hint-color='rgb(53,132,228)'
      auto-tile=@as []
      center-window=@as []
      debugging-free-rects=@as []
      debugging-show-tiled-rects=@as []
      default-move-mode=0
      dynamic-keybinding-behavior=0
      import-layout-examples=false
      last-version-installed=47
      overridden-settings={'org.gnome.mutter.edge-tiling': <@mb nothing>, 'org.gnome.desktop.wm.keybindings.maximize': <@mb nothing>, 'org.gnome.desktop.wm.keybindings.unmaximize': <['<Super>Down']>}
      restore-window=['<Super>Down']
      search-popup-layout=@as []
      tile-bottom-half=['<Shift><Super>KP_Down']
      tile-bottom-half-ignore-ta=@as []
      tile-bottomleft-quarter=['<Shift><Super>KP_End']
      tile-bottomleft-quarter-ignore-ta=@as []
      tile-bottomright-quarter=['<Shift><Super>KP_Next']
      tile-bottomright-quarter-ignore-ta=@as []
      tile-edit-mode=@as []
      tile-left-half=['<Shift><Super>KP_Left']
      tile-left-half-ignore-ta=@as []
      tile-maximize=['<Super>Up', '<Super>KP_5']
      tile-maximize-horizontally=@as []
      tile-maximize-vertically=@as []
      tile-right-half=['<Shift><Super>KP_Right']
      tile-right-half-ignore-ta=@as []
      tile-top-half=['<Shift><Super>KP_Up']
      tile-top-half-ignore-ta=@as []
      tile-topleft-quarter=['<Shift><Super>KP_Home']
      tile-topleft-quarter-ignore-ta=@as []
      tile-topright-quarter=['<Shift><Super>KP_Page_Up']
      tile-topright-quarter-ignore-ta=@as []
      toggle-always-on-top=@as []
      toggle-tiling-popup=@as []

      [org/gnome/shell/extensions/trayIconsReloaded]
      icon-brightness=40
      icon-contrast=30
      icon-saturation=50
      icon-size=19
      icons-limit=4
      tray-margin-left=2

      [org/gnome/shell/extensions/weatherornot]
      position='right'

      [org/gnome/shell/extensions/window-list]
      display-all-workspaces=false
      grouping-mode='never'
      show-on-all-monitors=false

      [org/gnome/shell/extensions/user-theme]
      name=''


      [org/gnome/shell/keybindings]
      focus-active-notification=@as []
      open-application-menu=@as []
      screenshot=@as []
      screenshot-window=@as []
      show-screen-recording-ui=@as []
      toggle-message-tray=@as []

      [org/gnome/shell/weather]
      automatic-location=true
      locations=[<(uint32 2, <('Berlin', 'EDDT', true, [(0.91746141594945008, 0.23241968454167572)], [(0.91658875132345297, 0.23387411976724018)])>)>]
    '';
  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
