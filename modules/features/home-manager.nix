{ self, inputs, ... }: {
  flake.nixosModules.home-manager = { pkgs, lib, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = false;
      users."riot" = { pkgs, ... }: {
        home.stateVersion = "26.05";
        home.packages = with pkgs; [
          sublime4
          brave
          kitty
          ghostty
          motrix
          uget  
          nemo
          bitwarden-desktop
          tree
          gitkraken
          opencode
          telegram-desktop
          lxappearance
          themechanger
          clementine
          haruna
        ];
      };
    };
  };
}