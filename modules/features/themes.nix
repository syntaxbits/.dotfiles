{ self, inputs, ... }: {
  flake.nixosModules.themes =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      sweetGtkTheme =
        pkgs.runCommand "sweet-gtk-theme"
          {
            nativeBuildInputs = [ pkgs.gnused ];
          }
          ''
            mkdir -p "$out/share/themes/Sweet-Dark" "$out/share/gtk-2.0"
            cp -r ${inputs.sweet}/gtk-2.0 ${inputs.sweet}/gtk-3.0 ${inputs.sweet}/gtk-4.0 ${inputs.sweet}/metacity-1 "$out/share/themes/Sweet-Dark/"
            cp ${inputs.sweet}/index.theme "$out/share/themes/Sweet-Dark/index.theme"
            sed -i 's/^IconTheme=.*/IconTheme=BeautyLine/' "$out/share/themes/Sweet-Dark/index.theme"
            printf '[Settings]\ngtk-theme-name=Sweet-Dark\ngtk-icon-theme-name=BeautyLine\n' > "$out/share/gtk-2.0/gtkrc"
          '';

      sweetTheme = pkgs.runCommand "sweet-dar" { } ''
        mkdir -p "$out/share"
        cp -r ${sweetGtkTheme}/share/themes "$out/share/"
        cp -r ${sweetGtkTheme}/share/gtk-2.0 "$out/share/"
        mkdir -p "$out/share/Kvantum"
        cp -r ${inputs.sweet}/kde/Kvantum/Sweet "$out/share/Kvantum/"
      '';

      flatpakApplications = lib.unique config.features.themes.flatpakApplications;
      flatpakApplicationsFile = pkgs.writeText "sweet-flatpak-applications" (
        lib.concatStringsSep "\n" (flatpakApplications ++ [ "" ])
      );
      flatpakThemePath = "${sweetGtkTheme}/share";
      flatpakDataPrefix = "${sweetGtkTheme}";
      flatpakStateDir = "/var/lib/sweet-flatpak-theme";
      flatpakOverride = pkgs.writeShellApplication {
        name = "activate-sweet-flatpak-overrides";
        runtimeInputs = [
          config.services.flatpak.package
          pkgs.coreutils
          pkgs.gnugrep
        ];
        text = ''
          set -eu
          state_dir=${lib.escapeShellArg flatpakStateDir}
          current_apps_file=${lib.escapeShellArg flatpakApplicationsFile}
          theme_path=${lib.escapeShellArg flatpakThemePath}
          data_prefix=${lib.escapeShellArg flatpakDataPrefix}
          old_apps_file="$state_dir/apps"
          old_theme_file="$state_dir/theme"

          remove_old_override() {
            if [ -n "$old_theme" ]; then
              flatpak override --system \
                --nofilesystem="$old_theme" \
                --unset-env=GTK_DATA_PREFIX \
                --unset-env=GTK_THEME \
                --unset-env=GTK2_RC_FILES \
                "$1"
            else
              flatpak override --system \
                --unset-env=GTK_DATA_PREFIX \
                --unset-env=GTK_THEME \
                --unset-env=GTK2_RC_FILES \
                "$1"
            fi
          }

          mkdir -p "$state_dir"
          old_theme=
          if [ -f "$old_theme_file" ]; then
            IFS= read -r old_theme < "$old_theme_file" || true
          fi

          if [ -f "$old_apps_file" ]; then
            while IFS= read -r old_app; do
              [ -n "$old_app" ] || continue
              if ! grep -Fxq -- "$old_app" "$current_apps_file"; then
                if ! remove_old_override "$old_app"; then
                  printf 'Unable to remove Sweet Flatpak override for %s\n' "$old_app" >&2
                fi
              fi
            done < "$old_apps_file"
          fi

          while IFS= read -r app; do
            [ -n "$app" ] || continue
            if [ -n "$old_theme" ] && [ "$old_theme" != "$theme_path" ]; then
              if ! flatpak override --system --nofilesystem="$old_theme" "$app"; then
                printf 'Unable to replace the previous Sweet Flatpak filesystem for %s\n' "$app" >&2
              fi
            fi
            flatpak override --system \
              --filesystem="$theme_path:ro" \
              --env=GTK_DATA_PREFIX="$data_prefix" \
              --env=GTK_THEME=Sweet-Dark \
              --env=GTK2_RC_FILES="$theme_path/gtk-2.0/gtkrc" \
              "$app"
          done < "$current_apps_file"

          apps_tmp="$state_dir/apps.tmp"
          cp "$current_apps_file" "$apps_tmp"
          mv "$apps_tmp" "$old_apps_file"
          printf '%s\n' "$theme_path" > "$old_theme_file"
        '';
      };
    in
    {
      options.features.themes = {
        enable = lib.mkEnableOption "Sweet GTK and Kvantum themes";
        flatpakApplications = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = ''
            Flatpak application IDs that should use the Sweet GTK theme.
          '';
        };
      };
      config = lib.mkIf config.features.themes.enable {
        assertions = [
          {
            assertion = config.features.themes.flatpakApplications == [ ] || config.services.flatpak.enable;
            message = "features.themes.flatpakApplications requires services.flatpak.enable";
          }
        ];
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

        system.activationScripts.sweetFlatpak = lib.mkIf config.services.flatpak.enable {
          text = "${flatpakOverride}";
          supportsDryActivation = false;
        };
      };
    };
}
