{ self, inputs, ... }: {
  flake.nixosModules.flatpak = { pkgs, lib, config, ... }: {
    options.features.flatpak.enable = lib.mkEnableOption "flatpak";

    config = lib.mkIf config.features.flatpak.enable {
      services.flatpak.enable = true;

      systemd.services.flatpak-repo = {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.flatpak ];
        script = ''
          flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        '';
      };

      home-manager.users.${config.myUser} = {
        home.sessionVariables = {
          XDG_DATA_DIRS = "$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:${config.myUserHome}/.local/share/flatpak/exports/share";
        };
        programs.zsh.shellAliases.flatc = "flatpak uninstall --all --delete-data";
      };
    };
  };
}