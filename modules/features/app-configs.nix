{ self, inputs, ... }: {
  flake.nixosModules.appConfigs = { pkgs, lib, config, ... }: {
    home-manager.users.${config.myUser} = { pkgs, lib, ... }: {
      xdg.configFile = let
        apps = lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./configs);
        appFiles = app: lib.filesystem.listFilesRecursive ./configs/${app};
        relPath = app: file: lib.removePrefix (toString ./configs/${app} + "/") (toString file);
      in lib.listToAttrs (lib.concatLists (map (app:
        map (file: {
          name = "${app}/${relPath app file}";
          value.source = file;
        }) (appFiles app)
      ) (lib.attrNames apps)));
    };
  };
}