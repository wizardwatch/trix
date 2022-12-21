{
  description = "Trix, short for tree nix, supplies various useful functions.";
  #inputs.sops-nix.url = github:Mic92/sops-nix;
  outputs = { self, nixpkgs, ...}: rec {
    nixosModules.default = import ./modules/minecraft.nix;
    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ({ pkgs, ...}: {
        #boot.isContainer = true;
        system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
        networking.useDHCP = true;
        #privateNetwork = true;
        #hostAddress = "192.168.100.2";
        #localAddress = "192.168.100.11";
      })
      nixosModules.default
      {trix.services.minecraft.enable = true;}
      {
      users.users.test = {
        isNormalUser = true;
        extraGroups = ["wheel"];
        password = "1234";
      };
    }
        #sops-nix.nixosModules.sops

      ];
    };
  };
}
