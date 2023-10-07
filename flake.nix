{
  description = "Allow flakes to be used with Nix < 2.4";

  outputs = { self }: {
    lib = {
      lib = (self.overlay null null).fc;
      overlay = import ./lib.nix;
    };
  };
}
