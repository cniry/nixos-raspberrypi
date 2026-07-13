{
  nix.settings.substituters = [
    "https://cniry-nixos-raspberrypi-5.cachix.org"
  ];
  # Caches in trusted-substituters can be used by unprivileged users i.e. in
  # flakes but are not enabled by default.
  nix.settings.trusted-substituters = [
    "https://cniry-nixos-raspberrypi-5.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cniry-nixos-raspberrypi-5.cachix.org-1:RhtIjevNLLzCritlR0g09w36gZ4cA3doXAL4x0ZolcY="
  ];
}
