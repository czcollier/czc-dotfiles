{
  description = "Chris's Sane & Protocol-Compatible Hyprland Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland/v0.56.2";
    nix-gl-host.url = "github:numtide/nix-gl-host";

    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.56.0";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      hyprland-pkg = inputs.hyprland.packages.${system}.hyprland;
    in {
      # Export the custom quickshell package so home.nix can consume it
      packages.${system}.quickshell-custom = inputs.quickshell.packages.${system}.quickshell.withModules [
        pkgs.qt6.qt5compat
        pkgs.qt6.qtpositioning
        pkgs.qt6.qtsvg
        pkgs.kdePackages.syntax-highlighting
        pkgs.qt6.qtmultimedia
        pkgs.qt6.qtshadertools
        pkgs.kdePackages.kirigami
        pkgs.qt6.qtwayland
        pkgs.wtype
      ];

      homeConfigurations."czcollier" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs self;
          quickshell-custom = self.packages.${system}.quickshell-custom;
        };
        modules = [ ./home.nix ];
      };
    };
}
