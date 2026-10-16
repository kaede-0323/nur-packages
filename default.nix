# NUR passes pkgs in, so never import <nixpkgs> here; the default only serves local nix-build.
{pkgs ? import <nixpkgs> {}}: {
  lib = import ./lib {inherit pkgs;};
  nixosModules = import ./nixos-modules;
  homeModules = import ./home-modules;
  overlays = import ./overlays;

  boomer = pkgs.callPackage ./pkgs/boomer {};
  ibis-office = pkgs.callPackage ./pkgs/ibis-office {};
  jkgo-font = pkgs.callPackage ./pkgs/jkgo-font {};
  raddebugger = pkgs.callPackage ./pkgs/raddebugger {};
  sddm-vitreous = pkgs.callPackage ./pkgs/sddm-vitreous {};
  yaim = pkgs.callPackage ./pkgs/yaim {};
  zhist = pkgs.callPackage ./pkgs/zhist {};
}
