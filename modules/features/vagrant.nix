{ self, inputs, ... }: {
  flake.nixosModules.vagrant = { pkgs, lib, config, ... }: {
    options.features.vagrant.enable = lib.mkEnableOption "vagrant";

    config = lib.mkIf config.features.vagrant.enable {
      environment.systemPackages = [ pkgs.vagrant ];

      environment.sessionVariables.VAGRANT_DEFAULT_PROVIDER = "libvirt";

      virtualisation.libvirtd.enable = true;
      boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

      users.users.${config.myUser}.extraGroups = [ "libvirtd" "kvm" ];

      services.nfs.server.enable = true;

      networking.firewall.trustedInterfaces = [ "virbr0" "virbr1" "virbr2" ];
      networking.networkmanager.unmanaged = [ "virbr0" "virbr1" "virbr2" ];
    };
  };
}
