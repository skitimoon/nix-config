{
  description = "YimOS";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    # For macOS
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nvf.url = "github:notashelf/nvf";
  };

  outputs = {
    nixpkgs,
    nixpkgs-stable,
    nix-darwin,
    home-manager,
    home-manager-stable,
    nvf,
    ...
  } @ inputs: let
    username = "yim";
  in {
    nixosConfigurations = {
      phoenix = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs username;
        };
        modules = [
          ./hosts/phoenix/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = {
                inherit inputs username;
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username}.imports = [nvf.homeManagerModules.default ./hosts/phoenix/home.nix];
            };
          }
        ];
      };

      eagle = nixpkgs-stable.lib.nixosSystem {
        specialArgs = {
          inherit inputs username;
        };
        modules = [
          ./hosts/eagle/configuration.nix
          home-manager-stable.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = {
                inherit inputs username;
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./hosts/eagle/home.nix;
            };
          }
        ];
      };

      falcon = nixpkgs-stable.lib.nixosSystem {
        specialArgs = {
          inherit inputs username;
        };
        modules = [
          ./hosts/falcon/configuration.nix
          home-manager-stable.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = {
                inherit inputs username;
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username}.imports = [nvf.homeManagerModules.default ./hosts/falcon/home.nix];
            };
          }
        ];
      };
    };

    darwinConfigurations = {
      griffin = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs username;
        };
        modules = [
          ./hosts/griffin/configuration.nix
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [
              (final: prev: {
                swift = nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system}.swift;
              })
            ];
            users.users.${username}.home = nixpkgs.lib.mkDefault /Users/${username};
            home-manager = {
              extraSpecialArgs = {
                inherit inputs username;
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username}.imports = [nvf.homeManagerModules.default ./hosts/griffin/home.nix];
            };
          }
        ];
      };
    };

    homeConfigurations = {
      # Standalone HM
      # Office Server
      "yim@dell" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [nvf.homeManagerModules.default ./hosts/dell/home.nix];
        extraSpecialArgs = {
          inherit inputs username;
        };
      };
    };

    # Formatter for `nix fmt`
    formatter = {
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
      aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.alejandra;
      aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
    };
  };
}
