let
  falconUser = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcRQ1f7Sf+kpfUPXcZ2cdo2ewl6FOm/deL+yQI7e1fl falcon";
  falconHost = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICR1AApUwxzylE0a6AfxxXtlnQUG3jMZWMSL+QonLDyG root@nixos";
in {
  "openclaw-gateway-token-env.age".publicKeys = [falconUser falconHost];
  "gog-keyring-env.age".publicKeys = [falconUser falconHost];
  "nextcloud-admin-pass.age".publicKeys = [falconUser falconHost];
  "telegram-bot-token.age".publicKeys = [falconUser falconHost];
}
