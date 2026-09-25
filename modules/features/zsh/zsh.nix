{ self, inputs, ... }: {
  flake.nixosModules.zsh = { pkgs, lib, config, ... }: {
    programs.zsh.enable = true;

    home-manager.users.${config.myUser}.imports = [{
      programs.fzf.enable = true;

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
          nu = "nh os switch ~/.dotfiles#myMachine";
          nfu = "nh flake update ~/.dotfiles";
          nhco = "nh clean all -k10 -K5d --optimise";
          nhc = "nh clean all -k10 -K2d";
          flatc = "flatpak uninstall --all --delete-data";
          hpr = "${config.myUserHome}/.dotfiles/scripts/hprop.sh";
          lc = "colorls -lah";
          media = "cd /run/media/${config.myUser}/MEDIA";
          work = "cd /run/media/${config.myUser}/MEDIA/repo.projects";
          home = "cd ~/";
          ai = "opencode";
        };

        envExtra = "export POWERLEVEL9K_CONFIG_FILE=${config.myUserHome}/.dotfiles/modules/features/zsh/p10k.zsh";

        initContent = lib.mkAfter ''
          # powerlevel10k
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          [[ -f "$POWERLEVEL9K_CONFIG_FILE" ]] && source "$POWERLEVEL9K_CONFIG_FILE"
        '';
      };
    }];
  };
}