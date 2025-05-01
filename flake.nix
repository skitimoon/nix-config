{
  description = "YimOS";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    # For macOS
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-stable,
    nix-darwin,
    home-manager,
    home-manager-stable,
    nvf,
    stylix,
    ...
  } @ inputs: let
    username = "yim";
  in {
    nixosConfigurations = {
      phoenix = nixpkgs-stable.lib.nixosSystem {
        specialArgs = {
          inherit inputs username;
        };
        modules = [
          ./hosts/phoenix/configuration.nix
          stylix.nixosModules.stylix
          home-manager-stable.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = {
                inherit inputs username;
                # pkgs-unstable = nixpkgs.legacyPackages.x86_64-linux;
                pkgs-unstable = import nixpkgs {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username}.imports = [
                nvf.homeManagerModules.default
                ./hosts/phoenix/home.nix
              ];
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
              users.${username} . imports = [
                nvf.homeManagerModules.default
                ./hosts/falcon/home.nix
              ];
            };
          }
        ];
      };
    };

    darwinConfigurations = {
      griffin = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit username;
        };
        modules = [
          ./hosts/griffin/configuration.nix
          home-manager.darwinModules.home-manager
          {
            users.users.${username}.home = nixpkgs.lib.mkDefault /Users/${username};
            home-manager = {
              extraSpecialArgs = {
                inherit inputs username;
                pkgs-stable = nixpkgs-stable.legacyPackages.aarch64-darwin;
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username}.imports = [
                nvf.homeManagerModules.default
                ./hosts/griffin/home.nix
              ];
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
  };
}
