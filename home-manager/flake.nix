{
  description = "Chris's Sane & Protocol-Compatible Hyprland Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland/v0.55.4";
    nix-gl-host.url = "github:numtide/nix-gl-host";

    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    }; 
    # This line tells quickshell: "Don't use your own nixpkgs, use mine."
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins/v0.55.0";
      inputs.hyprland.follows = "hyprland";
    };

    simula = {
      url = "github:SimulaVR/Simula";
      inputs.nixpkgs.follows = "nixpkgs";
    };
};

  outputs = { self, nixpkgs, home-manager, nix-gl-host, quickshell, noctalia, hyprland-plugins, simula, ... }@inputs: 
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
          pkgs.wtype
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
              # defined for noctalia
              PATH = "$HOME/.config/noctalia/bin:$PATH";
              XDG_DATA_DIRS = "$XDG_DATA_DIRS:$HOME/.local/state/nix/profiles/profile/share:/usr/local/share:/usr/share";
            };
            home.packages = [ 
              self.packages.${system}.default
              noctalia.packages.${system}.default
              inputs.hyprland.packages.${system}.hyprland
              nix-gl-host.defaultPackage.${system}
              pkgs.dart-sass
              pkgs.libnotify
              pkgs.awww
              pkgs.bibata-cursors
              pkgs.rose-pine-hyprcursor
              inputs.simula.packages.${pkgs.system}.simula
              pkgs.wayvr
              pkgs.cage
              pkgs.weston
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
