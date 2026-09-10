{ self, inputs, ... }: {
  flake.nixosModules.zsh = { pkgs, lib, ... }: {
    programs.zsh.enable = true;

    home-manager.users."riot".imports = [{
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        historySubstringSearch.enable = true;

        shellAliases = {
          l = "ls --color=auto";
          ll = "ls -lah";
          la = "ls -A";
          ".." = "cd ..";
          "..." = "cd ../..";
          gs = "git status";
          ga = "git add";
          gc = "git commit -m";
          gp = "git push";
          gl = "git log --oneline";
          gd = "git diff";
          grep = "grep --color=auto";
          mkd = "mkdir -p";
          nu = "nh os switch -u ~/.dotfiles#myMachine";
          nhco = "nh clean all -k5 -K5d --optimise";
          nhc = "nh clean all -k5 -K5d";
          flatc = "flatpak uninstall --all --delete-data";
          hpr = "/home/riot/.dotfiles/scripts/hprop.sh";
          lc = "colorls -lah";
          media = "cd /run/media/riot/MEDIA";
          work = "cd /run/media/riot/MEDIA/repo.projects";
          home = "cd ~/";
          ai = "opencode";
        };

        envExtra = "export POWERLEVEL9K_CONFIG_FILE=/home/riot/.dotfiles/modules/features/zsh/p10k.zsh";

        initContent = lib.mkAfter ''
          # powerlevel10k
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          [[ -f "$POWERLEVEL9K_CONFIG_FILE" ]] && source "$POWERLEVEL9K_CONFIG_FILE"
        '';
      };
    }];
  };
}