{ config, pkgs, inputs, ... }:

let
  # 1. Define the customized Monado build cleanly as a local variable
  unlockedMonado = pkgs.monado.overrideAttrs (oldAttrs: {
    hardwareDrivers = [ "external" "simulated" "remote" "wmr" "survive" ];
    surviveSupport =  true;
    # modify the meson flags to explicitly force the external driver build
    mesonFlags = (oldAttrs.mesonFlags or []) ++ [
      "-Ddrivers=external,simulated,remote,wmr,survive" 
    ];
    # 1. Force the missing C build dependencies into the build environment sandbox
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
      "-D_FORCE_LOCAL_REBUILD_TIMESTAMP=2026" # Breaks the global cache signature instantly
    ];
  });
in {
  home.username = "czcollier";
  home.homeDirectory = "/home/czcollier";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  wayland.windowManager.hyprland = {
    enable = true;
    #xwayland.enable = true;
    configType = "lua";
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    extraConfig = ''
    require("czc-hyprland")
  '';
    #plugins = [
      #inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
      #inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprfocus
      #inputs.hyprspace.packages.${pkgs.stdenv.hostPlatform.system}.Hyprspace
    #];
    # Optional: You can put your hyprland.conf logic directly here later
    # settings = { ... }; 
  };
 
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
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
  
  # 2. Wire Up the OpenXR Configuration File Registry
  # This tricks OpenXR client apps into natively choosing Monado
  xdg.configFile."openxr/1/active_runtime.json".text = builtins.toJSON {
    file_format_version = "1.0.0";
    runtime = {
      library_path = "${unlockedMonado}/lib/libopenxr_monado.so";
      name = "Monado";
    };
  };

  # 3. Handle the Headless Simulation Sandbox Configuration
  # This ensures Monado safe-boots on your X1 Carbon without looking for external USB hardware
  xdg.configFile."monado/config_v0.json".text = ''
    {
      "version": 0,
      "active": "remote",
      "drivers": {
        "remote": true,
        "survive": true,
        "simulate": false,
        "null": false
      },
      "remote": {
        "version": 0,
        "port": 5555,
        "address": "127.0.0.1",
        "hmd": {
          "views": [
            {
              "display_index": 0,
              "fov": { "left": -0.8, "right": 0.8, "top": 0.8, "bottom": -0.8 }
            },
            {
              "display_index": 1,
              "fov": { "left": -0.8, "right": 0.8, "top": 0.8, "bottom": -0.8 }
            }
          ]
        }
      },
      "window": {
        "width": 1024,
        "height":768 
      }
    }
  '';

  systemd.user.services.monado = {
    Unit = {
      Description = "Monado OpenXR Runtime Daemon (Simulated Platform)";
      Documentation = [ "https://monado.freedesktop.org" ];
      # Ensure graphic target capabilities are fully initialized before loading
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${unlockedMonado}/bin/monado-service";
      Restart = "on-failure";
      RestartSec = "2s"; # Add a delay so it doesn't slam the circuit breaker instantly
     
      # --- Fix the epoll_ctl(stdin) crash ---
      StandardInput = "pipe";

      # Crucial Fix: Force the systemd process block to read your active Wayland environment
      Environment = [
        "WMR_HANDTRACKING=0"
        "XRT_COMPOSITOR_COMPUTE=1"
        "XRT_COMPOSITOR_FORCE_WAYLAND=1" 

        # --- Force Driver Focus ---
        "P_OVERRIDE_ACTIVE_CONFIG=external"
        "EXTERNAL_TRACKER_PIPE=/tmp/monado_external_input"
      ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ]; # Bind directly to active window manager lifecycle
    };
  };
  
  # Headless Virtual Canvas Service
  systemd.user.services.spatial-canvas = {
    Unit = {
      Description = "Headless Kiosk Compositor Canvas for XR Workspace";
      After = [ "graphical-session.target" ];
    };
    Service = {
      # Sets up the environment variables required by wlroots for headless operation
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

  #home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  #];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
  };


home.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.libsurvive}/lib:$LD_LIBRARY_PATH";
    EDITOR = "vim";
    SURVIVE_GLOBALSCENESOLVER = "0"; # Freezes background recalibration for desktop stability
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
