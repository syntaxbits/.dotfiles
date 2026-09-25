{ ... }: {
  # Single source of truth for the primary user. Every module that needs to name
  # the user account, or a path under their home, reads these instead of
  # hardcoding a name, so a fresh install on a machine with a different username
  # does not silently keep referencing the old one.
  flake.nixosModules.base = { config, lib, ... }: {
    options = {
      myUser = lib.mkOption {
        type = lib.types.str;
        default = "riot";
        example = "alice";
        description = ''
          Name of the primary user account. Used for `users.users`,
          `home-manager.users`, and as the basename of `myUserHome`.
        '';
      };

      myUserHome = lib.mkOption {
        type = lib.types.str;
        default = "/home/${config.myUser}";
        example = "/home/alice";
        description = ''
          Home directory of `myUser`. Prefer `config.home.homeDirectory` inside
          home-manager modules, which is authoritative there; this is for paths
          evaluated in the NixOS (system) context.
        '';
      };
    };
  };
}
