{ self, inputs, ... }: {
  flake.nixosModules.nix-ld = { pkgs, lib, config, ... }: {
    options.features.nix-ld.enable = lib.mkEnableOption "nix-ld";

    config = lib.mkIf config.features.nix-ld.enable {
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          # X11 / AWT
          xorg.libX11
          xorg.libXext
          xorg.libXrender
          xorg.libXtst
          xorg.libXi
          xorg.libXcursor
          xorg.libXinerama
          xorg.libXrandr
          xorg.libXcomposite
          xorg.libXdamage
          xorg.libXfixes
          xorg.libICE
          xorg.libSM
          xorg.libxcb
          xorg.libXScrnSaver
          xorg.libxkbfile
          # GL / fonts / gtk stack
          libGL
          libGLU
          libxkbcommon
          fontconfig
          freetype
          glib
          gtk3
          gdk-pixbuf
          at-spi2-atk
          at-spi2-core
          cairo
          pango
          # JBR runtime deps
          alsa-lib
          nss
          nspr
          cups
          dbus
          dbus-glib
          expat
          icu
          harfbuzz
          libpulseaudio
          gmp
          zlib
        ];
      };
    };
  };
}