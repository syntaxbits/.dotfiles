{ self, inputs, ... }: {
  # Expose an optional system module if you want git installed system-wide automatically
  flake.nixosModules.git = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myGit
    ];
  };

  # Define the custom git package using nix-wrapper-modules
  perSystem = { pkgs, ... }: {
    packages.myGit = inputs.wrapper-modules.wrappers.git.wrap {
      inherit pkgs;
      settings = {
        user = {
          name = "Paul K.M.";
          email = "paulkiyingi.masajjage@gmail.com"; # Update to your email
        };
        init.defaultBranch = "main";
        alias = {
          st = "status";
          co = "checkout";
          sw = "switch";
          cm = "commit -m";
        };
      };
    };
  };
}