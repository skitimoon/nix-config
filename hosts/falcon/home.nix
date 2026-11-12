{
  pkgs,
  inputs,
  username,
  ...
}: let
  llmAgentPackages = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  # Unwrapped: the default wrapper puts cursor-agent and opencode 1.x on PATH;
  # the service below finds agents through the user profile instead.
  t3codePackage = llmAgentPackages.t3code.unwrapped;
  # TODO: use pkgs.podman-compose once stable ships >= 1.6; 1.5.0 lacks the
  # `up --wait` that ppm-odoo's dev scripts use (2026-11-04).
  podmanCompose = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.podman-compose;
in {
  imports = [
    ../../config/git.nix
    ../../config/linux-home.nix
    ../../config/nvf.nix
    ../../config/opencode.nix
    ../../config/yazi.nix
    ../../config/zsh.nix
  ];

  # Home Manager Setting
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
  };

  home.packages = with pkgs; [
    bat
    llmAgentPackages.claude-code
    llmAgentPackages.codex
    llmAgentPackages.grok
    t3codePackage
    eza
    gnumake
    gws
    jq
    lazygit
    nodejs
    podmanCompose
    ripgrep
    tldr
    trash-cli
    uv
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf.enable = true;
    gh.enable = true;
    starship.enable = true;
  };

  systemd.user.services.t3code = {
    Unit = {
      Description = "T3 Code server";
      StartLimitIntervalSec = 300;
      StartLimitBurst = 5;
    };
    Service = {
      Type = "simple";
      WorkingDirectory = "%h";
      Environment = [
        "T3CODE_HOME=%h/.t3"
        # /run/wrappers/bin: rootless Podman needs the setuid newuidmap/newgidmap.
        "PATH=/run/wrappers/bin:/etc/profiles/per-user/${username}/bin:%h/.nix-profile/bin:/run/current-system/sw/bin"
      ];
      ExecStart = "${t3codePackage}/bin/t3 serve";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["default.target"];
  };

  services.syncthing.enable = true;
}
