{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs; # THIS PART IS VERY IMPORTAINT, I FORGOT IT IN THE VIDEO!!!
      settings = {
        spawn-at-startup = [ (lib.getExe self'.packages.myNoctalia) (lib.getExe pkgs.polkit_gnome) ];

        # niri is started by the session manager, not by a login shell, so the
        # home-manager sessionVariables that land in ~/.nix-profile/etc/profile.d
        # never reach it. Without these, any app launched from the desktop falls
        # back to Qt's default light style instead of Kvantum; terminals still get
        # them from profile.d. Kvantum picks the actual theme out of
        # ~/.config/Kvantum/kvantum.kvconfig, which features.themes writes, and
        # niri's XDG_DATA_DIRS already includes ~/.nix-profile/share where the
        # Sweet theme is installed.
        environment = {
          QT_STYLE_OVERRIDE = "Kvantum";
          QT_PLUGIN_PATH = lib.concatStringsSep ":" [
            "${pkgs.libsForQt5.qtstyleplugin-kvantum}/${pkgs.qt5.qtbase.qtPluginPrefix}"
            "${pkgs.qt6Packages.qtstyleplugin-kvantum}/${pkgs.qt6.qtbase.qtPluginPrefix}"
          ];
        };

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        input = {
          keyboard.xkb.layout = "us";
          
          # Added touchpad configuration here:
          touchpad = {
            tap = {};
            natural-scroll = {};
          };

          # Enable focus window on mouse hover:
          focus-follows-mouse = {};
        };

        layout.gaps = 5;
        layout.default-column-width.proportion = 0.8;

        # 1. Set default size for floating windows to 2/3 (66%) of the display
        window-rules = [
          { draw-border-with-background = false; }
          {
            matches = [ { is-floating = true; } ];
            default-column-width = { proportion = 0.66667; };
            default-window-height = { proportion = 0.8; };
          }
        ];

        binds = {
          "Mod+O".toggle-overview = {};
          "Mod+W".toggle-column-tabbed-display = {};
          "Mod+Left".focus-column-left = {};
          "Mod+Right".focus-column-right = {};
          #"Mod+Up".focus-window-up = {};
          #"Mod+Down".focus-window-down = {};
          "Mod+BracketLeft".consume-or-expel-window-left = {};
          "Mod+BracketRight".consume-or-expel-window-right = {};

           # Move columns left/right
          "Mod+Ctrl+Left".move-column-left = {};
          "Mod+Ctrl+Right".move-column-right = {};
          
           # 2. Move windows vertically inside a column (top / bottom)
          "Mod+Ctrl+Up".move-window-up = {};
          "Mod+Ctrl+Down".move-window-down = {};

           # Toggle window floating
           "Mod+V".toggle-window-floating = {}; 


           # Maximize / Fullscreen toggle (Great for reading large files)
           "Mod+F".maximize-column = {};
           "Mod+Shift+F".fullscreen-window = {};

          # --- Workspace Management ---
          "Mod+Down".focus-workspace-down = {};
          "Mod+Up".focus-workspace-up = {};
          "Mod+Ctrl+Page_Down".move-column-to-workspace-down = {};
          "Mod+Ctrl+Page_Up".move-column-to-workspace-up = {}; 

          "Mod+G".spawn-sh = lib.getExe pkgs.ghostty;
          "Mod+Q".close-window = {};
           "Mod+D".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";

          # Volume keys
          "XF86AudioRaiseVolume".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call volume increase";
          "XF86AudioLowerVolume".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call volume decrease";
          "XF86AudioMute".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call volume mute";

          # Brightness keys
          "XF86MonBrightnessUp".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call brightness increase";
          "XF86MonBrightnessDown".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call brightness decrease";

          # Media keys
          "XF86AudioPlay".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call media playPause";
          "XF86AudioNext".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call media next";
          "XF86AudioPrev".spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call media previous";
        };
      };
    };
  };
}