{config, pkgs, lib,...}:

{
  # Fonts
  fonts.packages = with pkgs; [    
    cascadia-code
    comic-mono
    dina-font
    fira-code
    fira-code-symbols
    freetype
    inter
    iosevka
    meslo-lgs-nf
    #### Nerd Fonts Nonsense
    nerd-fonts._0xproto
		nerd-fonts._3270
		nerd-fonts.agave
		nerd-fonts.anonymice
		nerd-fonts.arimo
		nerd-fonts.aurulent-sans-mono
		nerd-fonts.bigblue-terminal
		nerd-fonts.bitstream-vera-sans-mono
		nerd-fonts.blex-mono
		nerd-fonts.caskaydia-cove
		nerd-fonts.caskaydia-mono
		nerd-fonts.code-new-roman
		nerd-fonts.comic-shanns-mono
		nerd-fonts.commit-mono
		nerd-fonts.cousine
		nerd-fonts.d2coding
		nerd-fonts.daddy-time-mono
		nerd-fonts.departure-mono
		nerd-fonts.dejavu-sans-mono
		nerd-fonts.droid-sans-mono
		nerd-fonts.envy-code-r
		nerd-fonts.fantasque-sans-mono
		nerd-fonts.fira-code
		nerd-fonts.fira-mono
		nerd-fonts.geist-mono
		nerd-fonts.go-mono
		nerd-fonts.gohufont
		nerd-fonts.hack
		nerd-fonts.hasklug
		nerd-fonts.heavy-data
		nerd-fonts.hurmit
		nerd-fonts.im-writing
		nerd-fonts.inconsolata
		nerd-fonts.inconsolata-go
		nerd-fonts.inconsolata-lgc
		nerd-fonts.intone-mono
		nerd-fonts.iosevka
		nerd-fonts.iosevka-term
		nerd-fonts.iosevka-term-slab
		nerd-fonts.jetbrains-mono
		nerd-fonts.lekton
		nerd-fonts.liberation
		nerd-fonts.lilex
		nerd-fonts.martian-mono
		nerd-fonts.meslo-lg
		nerd-fonts.monaspace
		nerd-fonts.monofur
		nerd-fonts.monoid
		nerd-fonts.mononoki
		#nerd-fonts.mplus
		nerd-fonts.noto
		nerd-fonts.open-dyslexic
		nerd-fonts.overpass
		nerd-fonts.profont
		nerd-fonts.proggy-clean-tt
		nerd-fonts.recursive-mono
		nerd-fonts.roboto-mono
		nerd-fonts.shure-tech-mono
		nerd-fonts.sauce-code-pro
		nerd-fonts.space-mono
		nerd-fonts.symbols-only
		nerd-fonts.terminess-ttf
		nerd-fonts.tinos
		nerd-fonts.ubuntu
		nerd-fonts.ubuntu-mono
		nerd-fonts.ubuntu-sans
		nerd-fonts.victor-mono
		nerd-fonts.zed-mono
    nerd-font-patcher
    ### Nerd Font Nonsense Ends
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    proggyfonts
    fantasque-sans-mono
    #(nerd-fonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  # Themes and Icons
  environment.systemPackages = with pkgs; [
    adw-gtk3
    adwaita-qt
    adwaita-qt6
    beauty-line-icon-theme
    bibata-cursors
    candy-icons
    #sweet
    sweet-folders
    sweet-nova
    #ubuntu-themes
  ];
}
