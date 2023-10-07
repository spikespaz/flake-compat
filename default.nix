# Compatibility function to allow flakes to be used by
# non-flake-enabled Nix versions. Given a source tree containing a
# 'flake.nix' and 'flake.lock' file, it fetches the flake inputs and
# calls the flake's 'outputs' function. It then returns an attrset
# containing 'defaultNix' (to be used in 'default.nix'), 'shellNix'
# (to be used in 'shell.nix').

{ src, system ? builtins.currentSystem or "unknown-system" }:

let
  lib = (import ./lib.nix null null).fc;
  flake = lib.mkFlake { inherit src; doFetchGit = true; };
  flakeSrc = lib.mkFlake { inherit src; };
in
  {
    inherit flakeSrc;
    defaultNix = lib.mkDefaultNix system flake;
    shellNix = lib.mkShellNix system flake;
  }
