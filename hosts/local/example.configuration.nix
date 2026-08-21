# ─────────────────────────────────────────────────────────────
# Nux host configuration
#
# Nothing here is required. Uncomment any line to override its
# ─────────────────────────────────────────────────────────────
{ config, pkgs, ... }:
{
  imports = [
    ../../modules
    ./hardware-configuration.nix
    ./disko.nix
  ];
}
