{ pkgs ? import nix/nixpkgs { system = builtins.currentSystem; }
, state ? "state.nixops"
, deploy ? "vbox"
}:

with pkgs;

mkShell {
  buildInputs = [
    cacert
    nix
    nixops
  ];

  shellHook = ''
    export NIX_PATH="nixpkgs=${pkgs.nixpkgs}:."
    export NIXOPS_STATE=${state}
    export NIXOPS_DEPLOYMENT=${deploy}
  '';
}
