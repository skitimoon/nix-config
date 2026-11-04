{
  pkgs,
  inputs,
  username,
  ...
}: let
  llmAgentPackages = inputs.llm-agents.packages.${pkgs.system};
  t3codePackage = inputs.t3code-nightly.packages.${pkgs.system}.t3code;
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
    gws
    jq
    lazygit
    nodejs
    ripgrep
    tldr
    trash-cli
  ];

  programs = {
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
        "PATH=/etc/profiles/per-user/${username}/bin:%h/.nix-profile/bin:/run/current-system/sw/bin"
      ];
      ExecStart = "${t3codePackage}/bin/t3 serve";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = ["default.target"];
  };

  services.syncthing.enable = true;
}
