{
  description = "YimOS";

  nixConfig = {
    extra-substituters = [
      "https://cache.numtide.com"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    # ayugram-desktop fails to link on darwin with newer nixpkgs, drop once it builds again
    nixpkgs-ayugram.url = "github:nixos/nixpkgs/0bb2eedc20e4739f29e8045034f2828ad7054f8f";
    # For macOS
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nvf.url = "github:notashelf/nvf";
    agenix.url = "github:ryantm/agenix";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = {
    nixpkgs,
    nixpkgs-darwin,
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
              users.${username}.imports = [
                nvf.homeModules.default
                ./hosts/phoenix/home.nix
              ];
            };
          }
        ];
      };

      # eagle = nixpkgs-stable.lib.nixosSystem {
      #   specialArgs = {
      #     inherit inputs username;
      #   };
      #   modules = [
      #     ./hosts/eagle/configuration.nix
      #     home-manager-stable.nixosModules.home-manager
      #     {
      #       home-manager = {
      #         extraSpecialArgs = {
      #           inherit inputs username;
      #         };
      #         useGlobalPkgs = true;
      #         useUserPackages = true;
      #         users.${username} = import ./hosts/eagle/home.nix;
      #       };
      #     }
      #   ];
      # };

      falcon = nixpkgs-stable.lib.nixosSystem {
        specialArgs = {
          inherit inputs username;
        };
        modules = [
          inputs.agenix.nixosModules.default
          ./hosts/falcon/configuration.nix
          home-manager-stable.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = {
                inherit inputs username;
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username}.imports = [
                nvf.homeModules.default
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
          inherit inputs username;
        };
        modules = [
          ./hosts/griffin/configuration.nix
          home-manager.darwinModules.home-manager
          {
            users.users.${username}.home = nixpkgs-darwin.lib.mkDefault /Users/${username};
            home-manager = {
              extraSpecialArgs = {
                inherit inputs username;
              };
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username}.imports = [nvf.homeModules.default ./hosts/griffin/home.nix];
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
        modules = [nvf.homeModules.default ./hosts/dell/home.nix];
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
