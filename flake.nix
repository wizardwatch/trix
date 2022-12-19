{
  description = "Trix, short for tree nix, supplies various useful functions.";
  outputs = { self, nixpkgs }: rec {
    modules = import ./modules;
  };
}
