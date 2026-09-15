{ config, pkgs, inputs, quickshell-custom, self, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in {
  home.username = "czcollier";
  home.homeDirectory = "/home/czcollier";
  home.stateVersion = "24.05"; 

  # --- Packages ---
  home.packages = with pkgs; [
    quickshell-custom
    inputs.noctalia.packages.${system}.default
    inputs.hyprland.packages.${system}.hyprland
    inputs.nix-gl-host.defaultPackage.${system}
    dart-sass
    libnotify
    awww
    bibata-cursors
    rose-pine-hyprcursor
    weston

    hyprcursor
    hyprlock
    hyprpaper
    hyprutils
    localsend
  ];

  # --- Environment Variables ---
  home.sessionVariables = {
    SASS_PATH = "${pkgs.dart-sass}/bin";
    PATH = "$HOME/.config/noctalia/bin:$PATH";
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:$HOME/.local/state/nix/profiles/profile/share:/usr/local/share:/usr/share";
    LD_LIBRARY_PATH = "${pkgs.libsurvive}/lib:$LD_LIBRARY_PATH";
    EDITOR = "vim";
    SURVIVE_GLOBALSCENESOLVER = "0"; 
  };

  # --- Core Programs ---
  programs.home-manager.enable = true;
  gtk.enable = true;

  programs.foot = {
    enable = true;
    server.enable = false; 
  };

  services.swaync = {
    enable = false;
  };

  wayland.windowManager.hyprland = {
    package = inputs.hyprland.packages.${system}.hyprland;
    enable = true;
    configType = "lua";
    extraConfig = ''
      package.path = package.path .. ";${config.xdg.configHome}/hypr/?.lua;${config.xdg.configHome}/hypr/?/init.lua"
      require("czc-hyprland")
    '';
    plugins = [
    ];
  };
}
