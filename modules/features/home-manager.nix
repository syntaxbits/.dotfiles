{ self, inputs, ... }: {
  flake.nixosModules.home-manager = { pkgs, lib, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = false;
      users."riot" = { pkgs, ... }: {
        home.stateVersion = "26.05";
        home.packages = with pkgs; [
        # audio
          clementine

        # developer 
          boxbuddy         
          gitkraken
          jetbrains.idea
          pencil
          opencode

        # editors
          sublime4

        # files
          nemo
          tree

        # internet
          brave
          discord
          motrix
          telegram-desktop
          tixati
          uget

        # security
          bitwarden-desktop

        # system
          kitty
          ghostty

        # video
          haruna
        ];
      };
    };
  };
}