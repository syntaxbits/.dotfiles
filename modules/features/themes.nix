{ self, inputs, ... }: {
  flake.nixosModules.themes =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      sweetTheme =
        pkgs.runCommand "sweet-dar"
          {
            nativeBuildInputs = [ pkgs.gnused ];
          }
          ''
            mkdir -p "$out/share/themes/Sweet-Dark" "$out/share/Kvantum"
            cp -r ${inputs.sweet}/gtk-2.0 ${inputs.sweet}/gtk-3.0 ${inputs.sweet}/gtk-4.0 ${inputs.sweet}/metacity-1 "$out/share/themes/Sweet-Dark/"
            cp ${inputs.sweet}/index.theme "$out/share/themes/Sweet-Dark/index.theme"
            sed -i 's/^IconTheme=.*/IconTheme=BeautyLine/' "$out/share/themes/Sweet-Dark/index.theme"
            cp -r ${inputs.sweet}/kde/Kvantum/Sweet "$out/share/Kvantum/"
          '';
    in
    {
      options.features.themes.enable = lib.mkEnableOption "Sweet GTK and Kvantum themes";

      config = lib.mkIf config.features.themes.enable {
        home-manager.users."riot" =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          let
            homeDirectory = config.home.homeDirectory;
            profileDirectory = config.home.profileDirectory;
            qt5PluginPath = "${profileDirectory}/${pkgs.qt5.qtbase.qtPluginPrefix}";
            qt6PluginPath = "${profileDirectory}/${pkgs.qt6.qtbase.qtPluginPrefix}";
            activation = pkgs.writeShellApplication {

              name = "activate-sweet-theme";
              runtimeInputs = [
                pkgs.coreutils
                pkgs.gnugrep
                pkgs.gnused
                pkgs.glib
              ];
              text = ''
                set -eu
                home_dir=${lib.escapeShellArg homeDirectory}

                set_ini() {
                  file="$1"
                  section="$2"
                  key="$3"
                  value="$4"
                  mkdir -p "$(dirname "$file")"
                  if [ ! -f "$file" ]; then
                    printf '[%s]\n%s=%s\n' "$section" "$key" "$value" > "$file"
                  elif grep -q "^$key=" "$file"; then
                    sed -i "s|^$key=.*|$key=$value|" "$file"
                  elif grep -q "^\[$section\]$" "$file"; then
                    sed -i "/^\[$section\]$/a\\$key=$value" "$file"
                  else
                    printf '\n[%s]\n%s=%s\n' "$section" "$key" "$value" >> "$file"
                  fi
                }

                set_ini "$home_dir/.config/gtk-2.0/gtkrc" Settings gtk-theme-name Sweet-Dark
                set_ini "$home_dir/.config/gtk-2.0/gtkrc" Settings gtk-icon-theme-name BeautyLine
                set_ini "$home_dir/.config/gtk-3.0/settings.ini" Settings gtk-theme-name Sweet-Dark
                set_ini "$home_dir/.config/gtk-3.0/settings.ini" Settings gtk-icon-theme-name BeautyLine
                set_ini "$home_dir/.config/gtk-3.0/settings.ini" Settings gtk-application-prefer-dark-theme true
                set_ini "$home_dir/.config/gtk-4.0/settings.ini" Settings gtk-theme-name Sweet-Dark
                set_ini "$home_dir/.config/gtk-4.0/settings.ini" Settings gtk-icon-theme-name BeautyLine
                set_ini "$home_dir/.config/gtk-4.0/settings.ini" Settings gtk-application-prefer-dark-theme true
                set_ini "$home_dir/.config/Kvantum/kvantum.kvconfig" General theme 'Sweet#'

                gsettings set org.gnome.desktop.interface gtk-theme Sweet-Dark || true
                gsettings set org.gnome.desktop.interface icon-theme BeautyLine || true
                gsettings set org.gnome.desktop.interface color-scheme prefer-dark || true
                gsettings set org.gnome.desktop.wm.preferences theme Sweet-Dark || true
              '';
            };
          in
          {
            home.packages = [
              sweetTheme
              pkgs.libsForQt5.qtstyleplugin-kvantum
              pkgs.qt6Packages.qtstyleplugin-kvantum
            ];

            home.sessionVariables = {
              GTK2_RC_FILES = "${homeDirectory}/.config/gtk-2.0/gtkrc";
              QT_STYLE_OVERRIDE = "Kvantum";
            };

            home.sessionSearchVariables = {
              QT_PLUGIN_PATH = [
                qt5PluginPath
                qt6PluginPath
              ];
            };

            home.activation.applySweetTheme = lib.hm.dag.entryAfter [ "installPackages" ] ''

              ${activation}
            '';
          };
      };
    };
}
