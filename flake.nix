{
  description = "Nyx — a NixOS-based Hyprland desktop distro, with ISO installer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
	disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  nixvim = {
    url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
  };

  
  };

  outputs = { self, nixpkgs, home-manager, hyprland, disko, nixvim,... }@inputs:
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
			disko.nixosModules.disko
          ];
        };
      };
    };
}
