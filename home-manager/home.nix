{ config, pkgs, inputs, self, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;

  unlockedMonado = pkgs.monado.overrideAttrs (oldAttrs: {
    hardwareDrivers = [ "external" "simulated" "remote" "wmr" "survive" ];
    surviveSupport = true; 
    mesonFlags = (oldAttrs.mesonFlags or []) ++ [
      "-Ddrivers=external,simulated,remote,wmr,survive" 
    ];
    buildInputs = (oldAttrs.buildInputs or []) ++ [ 
      pkgs.json_c 
      pkgs.libsurvive
    ];
    cmakeFlags = (oldAttrs.cmakeFlags or []) ++ [
      "-DXRT_HAVE_EXTERNAL=ON"
      "-DXRT_HAVE_ARDUINO=ON"
      "-DXRT_HAVE_LIBSURVIVE=ON"
      "-DXRT_HAVE_V4L2=ON"
      "-DXRT_HAVE_UVC=ON"
      "-DXRT_FEATURE_DEBUG_GUI=ON"
      "-DXRT_FEATURE_SYSTEMD=ON"
      "-D_FORCE_LOCAL_REBUILD_TIMESTAMP=2026" 
    ];
  });

in {
  home.username = "czcollier";
  home.homeDirectory = "/home/czcollier";
  home.stateVersion = "24.05"; 

  # --- Packages ---
  home.packages = with pkgs; [
    self.packages.${system}.quickshell-custom
    inputs.noctalia.packages.${system}.default
    inputs.hyprland.packages.${system}.hyprland
    inputs.nix-gl-host.defaultPackage.${system}
    inputs.simula.packages.${system}.simula

    dart-sass
    libnotify
    awww
    bibata-cursors
    rose-pine-hyprcursor
    wayvr
    cage
    weston

    hyprcursor
    hyprlock
    hyprpaper
    hyprutils
    openxr-loader
    gamescope
    vulkan-tools
    unlockedMonado
    libsurvive
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

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    package = inputs.hyprland.packages.${system}.hyprland;
    extraConfig = ''
      -- Explicitly add the hyprland config directory to the Lua package path
      package.path = package.path .. ";${config.xdg.configHome}/hypr/?.lua;${config.xdg.configHome}/hypr/?/init.lua"
      
      require("czc-hyprland")
    '';
  };

  # --- XR / VR Configurations ---
  xdg.configFile."openxr/1/active_runtime.json".text = builtins.toJSON {
    file_format_version = "1.0.0";
    runtime = {
      library_path = "${unlockedMonado}/lib/libopenxr_monado.so";
      name = "Monado";
    };
  };

  xdg.configFile."monado/config_v0.json".text = builtins.toJSON {
    version = 0;
    active = "remote";
    drivers = {
      remote = true;
      survive = true;
      simulate = false;
      null = false;
    };
    remote = {
      version = 0;
      port = 5555;
      address = "127.0.0.1";
      hmd = {
        views = [
          { display_index = 0; fov = { left = -0.8; right = 0.8; top = 0.8; bottom = -0.8; }; }
          { display_index = 1; fov = { left = -0.8; right = 0.8; top = 0.8; bottom = -0.8; }; }
        ];
      };
    };
    window = { width = 1024; height = 768; };
  };

  # --- Systemd Services ---
  systemd.user.services.monado = {
    Unit = {
      Description = "Monado OpenXR Runtime Daemon (Simulated Platform)";
      Documentation = [ "https://monado.freedesktop.org" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${unlockedMonado}/bin/monado-service";
      Restart = "on-failure";
      RestartSec = "2s"; 
      StandardInput = "pipe";
      Environment = [
        "WMR_HANDTRACKING=0"
        "XRT_COMPOSITOR_COMPUTE=1"
        "XRT_COMPOSITOR_FORCE_WAYLAND=1" 
        "P_OVERRIDE_ACTIVE_CONFIG=external"
        "EXTERNAL_TRACKER_PIPE=/tmp/monado_external_input"
      ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ]; 
    };
  };
  
  systemd.user.services.spatial-canvas = {
    Unit = {
      Description = "Headless Kiosk Compositor Canvas for XR Workspace";
      After = [ "graphical-session.target" ];
    };
    Service = {
      # CRITICAL: Systemd services must have an ExecStart. Add your compositor command here:
      # ExecStart = "${pkgs.cage}/bin/cage -- /path/to/your/app";
      Environment = [
        "WLR_BACKENDS=headless"
        "WLR_RENDERER=vulkan"
        "WLR_HEADLESS_OUTPUTS=1"
      ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
