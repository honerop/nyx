{
  description = "Nyx — a NixOS-based Hyprland desktop distro, with ISO installer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        # `nix build .#nixosConfigurations.iso.config.system.build.isoImage`
        # Boots straight into a live Hyprland desktop with a `nyx-install` command.
        iso = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/iso/configuration.nix
            home-manager.nixosModules.home-manager
          ];
        };

        # Template for an installed machine. `nyx-install` copies this repo
        # to /mnt/etc/nixos, generates hosts/template/hardware-configuration.nix,
        # and runs `nixos-install --flake .#nyx`.
        nyx = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/template/configuration.nix
            home-manager.nixosModules.home-manager
          ];
        };
      };
    };
}
