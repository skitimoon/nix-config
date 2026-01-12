{...}: {
  # imports =
  #   [
  #     <nixos-hardware/common/gpu/24.05-compat.nix>
  #   ];
  hardware.facetimehd.enable = true;
  services.fstrim.enable = true;
  services.mbpfan.enable = true;
}
