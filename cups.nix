{ config, lib, pkgs, modulesPath, ... }:

{
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

	services.avahi = {  # enable printer discovery idk (this just works, dont ask)
		enable = true;
		nssmdns = true;
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
	networking.firewall = {
		allowedTCPPorts = [ 631 ];
		allowedUDPPorts = [ 631 ];
	};
	hardware.printers = {
    ensurePrinters = [{  # add printer declaratively
      name = "Laserjet-2200";
      description = "HP Laserjet 2200D";
      location = "Wohnzimmer Wandschrank";
      deviceUri = "usb://HP/LaserJet%202200?serial=00CNHRB43441";
      model = "HP/hp-laserjet_2200_series.ppd.gz";  # "HP/hp-laserjet_2200-ps.ppd.gz"  "HP/hp-laserjet_2200_series.ppd.gz"  "HP/hp-laserjet_2200_series-ps.ppd.gz"
      ppdOptions = {
        PageSize = "A4";
        #Duplex = "DuplexNoTumble";
      };
	}];
  };
}
