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
      settings = (builtins.fromJSON(builtins.readFile ./noctalia.json)).settings;
    };
  };
}

# 1. when in niri launch noctalia-shell with this command ( nix run nixpkgs#noctalia-shell)
# 2. right click on the bar to open it's settings panel
# 3. customize to your liking then run command below to export json of settings
#    nix run nixpkgs#noctalia-shell ipc call state all > ./modules/features/noctalia.json 
# 4. 
