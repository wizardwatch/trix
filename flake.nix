{
  description = "Trix, short for tree nix, supplies various useful functions.";
  outputs = { self, nixpkgs }: rec {
    nixosModules = {
      minecraft = import ./modules/minecraft.nix;
    };
  };
}
