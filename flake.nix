{
  description = "Trix, short for tree nix, supplies various useful functions.";
  outputs = { self, nixpkgs, ...}: rec {
    nixosModules.default = import ./modules/minecraft.nix;
    
  };
}
