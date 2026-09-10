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
        layout.default-column-width.proportion = 0.5;

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
        };
      };
    };
  };
}