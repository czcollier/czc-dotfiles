{
  description = "Chris's Sane & Protocol-Compatible Hyprland Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    quickshell.url = "github:quickshell-mirror/quickshell";
     noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 
    # This line tells quickshell: "Don't use your own nixpkgs, use mine."
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel/master";
    nix-gl-host.url = "github:numtide/nix-gl-host";
    ashell.url = "github:MalpenZibo/ashell";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprpanel, nix-gl-host, ashell, quickshell, noctalia, ... }@inputs: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = quickshell.packages.${system}.quickshell.withModules [
          pkgs.qt6.qt5compat
          pkgs.qt6.qtpositioning
          pkgs.qt6.qtsvg
          pkgs.kdePackages.syntax-highlighting # This fixes the current error
          pkgs.qt6.qtmultimedia                # Likely needed for the 'SongRec' service
          pkgs.qt6.qtshadertools               # Often needed for custom Material shaders
          pkgs.kdePackages.kirigami            # This fixes the current error
          pkgs.qt6.qtwayland
      ];
      homeConfigurations."czcollier" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./home.nix
          {
            home.username = "czcollier";
            home.homeDirectory = "/home/czcollier";
            home.sessionVariables = {
              # Ensures HyprPanel and other tools use the Nix-managed Sass
              SASS_PATH = "${pkgs.dart-sass}/bin";
            };
            home.packages = [ 
              self.packages.${system}.default
              noctalia.packages.${system}.default
              pkgs.hyprland
              nix-gl-host.defaultPackage.${system}
              hyprpanel.packages.${system}.default
              pkgs.dart-sass
              pkgs.libnotify
              pkgs.swww
              pkgs.bibata-cursors
              ashell.packages.${system}.default
            ];

            programs.home-manager.enable = true;
            gtk = {
              enable = true;
            };
          }
        ];
      };
    };
}
