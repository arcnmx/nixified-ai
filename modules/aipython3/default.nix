{ lib, ... }:

{
  perSystem = { pkgs, system, ... }: {
    dependencySets = let
      overlays = import ./overlays.nix pkgs;

      mkPythonPackages = overlayList: let
        pkgs' = import pkgs.path {
          inherit system;
          config.allowUnfree = true;
        };
        python3' = pkgs'.python3.override {
          packageOverrides = lib.composeManyExtensions overlayList;
        };
      in python3'.pkgs;

    in {
      aipython3-amd = mkPythonPackages [
        overlays.fixPackages
        overlays.extraDeps
        overlays.torchRocm
      ];

      aipython3-nvidia = mkPythonPackages [
        overlays.fixPackages
        overlays.extraDeps
        overlays.torchCuda
      ];
    };
  };
}
