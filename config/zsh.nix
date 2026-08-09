{
  # lib,
  # pkgs,
  # config,
  ...
}: {
  programs = {
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      defaultKeymap = "emacs";
      history = {
        append = true;
        extended = true;
        save = 50000;
        size = 50000;
      };
      historySubstringSearch.enable = true;
      initContent = ''
        # Edit command line in $EDITOR with Ctrl+X Ctrl+E
        autoload -Uz edit-command-line
        zle -N edit-command-line
        bindkey '^X^E' edit-command-line

        # zsh-only word boundaries; not an environment variable.
        WORDCHARS=''${WORDCHARS//[\/\\#]}
      '';
      sessionVariables = {
        LESS = "Fij.5JW";
      };
      syntaxHighlighting.enable = true;
      shellAliases = {
        ncf = "cd ~/nix-config && nvim && cd -";
        cc = "nix run --accept-flake-config github:numtide/llm-agents.nix#claude-code -- --dangerously-skip-permissions";
        cx = "nix run --accept-flake-config github:numtide/llm-agents.nix#codex -- --yolo";
        l = "eza -F=auto -l";
        la = "eza -aF=auto -l";
        cp = "cp -i";
        rm = "rm -I";
        mv = "mv -i";
        ".." = "cd ..";
      };
      shellGlobalAliases = {
        B = "| bat";
        H = "| head";
        T = "| tail";
        G = "| grep";
        L = "| less";
      };
    };
    fzf.enable = true;
  };
}
