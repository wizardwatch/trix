{
  description = "Trix, short for tree nix, supplies various useful functions.";
  outputs = { self, nixpkgs, ...}: rec {
    nixosModules.default = import ./modules/minecraft.nix;
    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ({ pkgs, ...}: {
        boot.isContainer = true;
        system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
        networking.useDHCP = false;
        privateNetwork = true;
        hostAddress = "192.168.100.2";
        localAddress = "192.168.100.11";
      })
      nixosModules.default
      {trix.services.minecraft.enable = true;}
      ];
    };
  };
}
