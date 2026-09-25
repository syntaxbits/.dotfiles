{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs; # THIS PART IS VERY IMPORTAINT, I FORGOT IT IN THE VIDEO!!!
      package = pkgs.noctalia-shell.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./noctalia/launcher-overlay-fullscreen.patch
          ./noctalia/launcher-no-icons.patch
          ./noctalia/launcher-no-background.patch
        ];
      });
      # NOTE: the absolute paths inside noctalia.json (avatar, wallpaper directory,
      # per-output wallpaper) are produced by exporting settings from a running
      # shell, so they describe the machine and account that produced the file
      # rather than configuration owned by this flake. There is no build-time
      # value that can rewrite them usefully: the source home is whatever the
      # exporting account was called, which the flake does not know. Re-export
      # after installing under a different username (see commands below).
      settings = (builtins.fromJSON(builtins.readFile ./noctalia.json)).settings;
    };
  };
}

# 1. when in niri launch noctalia-shell with this command ( nix run nixpkgs#noctalia-shell)
# 2. right click on the bar to open it's settings panel
# 3. customize to your liking then run command below to export json of settings
#    nix run nixpkgs#noctalia-shell ipc call state all > ./modules/features/noctalia.json 
# 4. 
