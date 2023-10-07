# Compatibility function to allow flakes to be used by
# non-flake-enabled Nix versions. Given a source tree containing a
# 'flake.nix' and 'flake.lock' file, it fetches the flake inputs and
# calls the flake's 'outputs' function. It then returns an attrset
# containing 'defaultNix' (to be used in 'default.nix'), 'shellNix'
# (to be used in 'shell.nix').

{ src, system ? builtins.currentSystem or "unknown-system" }:

let
  lib = (import ./lib.nix null null).fc;

  lockFilePath = src + "/flake.lock";
  lockFile = builtins.fromJSON (builtins.readFile lockFilePath);
  rootSrc = lib.mkRootSrc src;

  allNodes = lib.mkAllNodes rootSrc lockFile;
  flake =
    if !(builtins.pathExists lockFilePath)
    then lib.callLocklessFlake rootSrc
    else if lockFile.version == 4
    then lib.callFlake4 rootSrc (lockFile.inputs)
    else if lockFile.version >= 5 && lockFile.version <= 7
    then allNodes.${lockFile.root}
    else throw "lock file '${lockFilePath}' has unsupported version ${toString lockFile.version}";
in
  {
    defaultNix = lib.mkDefaultNix system flake;
    shellNix = lib.mkShellNix system flake;
  }
