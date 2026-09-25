{ self, inputs, ... }: {
  flake.nixosModules.docker = { pkgs, lib, config, ... }: {
    options.features.docker.enable = lib.mkEnableOption "docker";

    config = lib.mkIf config.features.docker.enable {
      virtualisation.docker = {
        enable = true;
        autoPrune.enable = true;
      };

      users.users.${config.myUser}.extraGroups = [ "docker" ];
    };
  };
}
