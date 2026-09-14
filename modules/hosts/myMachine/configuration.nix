{ self, inputs, lib, ... }: {

  flake.nixosModules.myMachineConfiguration = { config, pkgs, lib, ... }: {
    # import any other modules from here
    imports = [
      self.nixosModules.myMachineHardware
      self.nixosModules.niri
      self.nixosModules.git
      self.nixosModules.home-manager
      self.nixosModules.zsh
      self.nixosModules.appConfigs
      self.nixosModules.flatpak
      self.nixosModules.docker
      self.nixosModules.vagrant
      ];

    # Feature toggles
    features.flatpak.enable = true;
    features.docker.enable = false;
    features.vagrant.enable = false;

    # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # Panel is wired to the NVIDIA dGPU (nouveau, card0); the ACPI video stub and
  # the force-loaded nvidia_wmi_ec_backlight phantom do NOT drive the physical
  # backlight. Lenovo EC (ideapad) control is exposed via the vendor backlight.
  boot.kernelParams = [ "acpi_backlight=vendor" ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enabling polkit
  security.polkit.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."riot" = {
    isNormalUser = true;
    description = "riot";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Grant the video group write access to backlight so brightnessctl (used by
  # noctalia brightness keys/OSD) can work for unprivileged users.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
  '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Allow unsecure packages
  nixpkgs.config.permittedInsecurePackages = [ "openssl-1.1.1w" "pencil-3.1.0"];

  # Allow experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Problem handling
  nixpkgs.config.problems.handlers = {
             sublimetext4.broken = "warn"; 
           };

  # Fix plugin_host-3.8 crash: nixpkgs removed openssl_1_1, so keep the
  # OpenSSL 1.1 libs bundled by upstream in the tar.xz that nixpkgs deletes.
  nixpkgs.overlays = [
    (final: prev: let
      origBin = prev.sublime4.passthru.unwrapped;
      patchedBin = origBin.overrideAttrs (old: {
        installPhase = lib.replaceStrings
          [ "rm libcrypto.so.1.1 libssl.so.1.1" ]
          [ "# keep bundled OpenSSL 1.1 required by plugin_host-3.8" ]
          old.installPhase;
        # Unversioned symlinks so Package Control's oscrypto (uses
        # ctypes/dlopen, not RPATH) can find the bundled OpenSSL 1.1.
        postFixup = (old.postFixup or "") + ''
          ln -sfn libcrypto.so.1.1 "$out/libcrypto.so"
          ln -sfn libssl.so.1.1 "$out/libssl.so"
        '';
      });
      # Prepend the bundled lib dir to LD_LIBRARY_PATH in every launcher
      # (sublime_text/subl/sublime/sublime4 + desktop entry) so plugin_host
      # can dlopen libcrypto/libssl for Package Control.
    in {
      sublime4 = prev.sublime4.overrideAttrs (old: {
        installPhase =
          lib.replaceStrings
            [ "${origBin}" ]
            [ "${patchedBin}" ]
            (lib.replaceStrings
              [ "makeWrapper \"${origBin}/sublime_text\" \"$out/bin/sublime_text\"" ]
              [ "makeWrapper \"${origBin}/sublime_text\" \"$out/bin/sublime_text\" --prefix LD_LIBRARY_PATH : \"${origBin}\"" ]
              old.installPhase);
      });
    })
  ];
  

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget

     beauty-line-icon-theme
     nh
     lxappearance
     themechanger
     polkit_gnome 
     sweet-folders
     sweet-nova
  ];  

  # Install fonts system-wide so they are available to all users and GDM
  fonts.packages = with pkgs; [
    iosevka
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
  ];  

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
  };

}