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
          nodejs
          opencode
          pencil
          vscode

        # editors
          sublime4

        # files
          nemo
          tree

        # internet
          brave
          discord
          google-chrome
          motrix
          nicotine-plus
          telegram-desktop
          tixati
          uget

        # security
          authenticator
          bitwarden-desktop

        # system
          engrampa
          kitty
          ghostty
          xarchiver

        # video
          haruna
        ];

        # Manual IDE install launcher (see ~/Applications/idea)
        xdg.desktopEntries.jetbrains-idea = {
          name = "udea";
          comment = "Capable and Ergonomic Java IDE";
          exec = "/home/riot/Applications/idea/bin/idea %u";
          icon = "/home/riot/Applications/idea/bin/idea.png";
          terminal = false;
          type = "Application";
          categories = [ "Development" "IDE" ];
          settings = { StartupWMClass = "jetbrains-idea"; };
        };
      };
    };
  };
}