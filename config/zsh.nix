{
  lib,
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
      initContent = lib.mkMerge [
        ''
          # Edit command line in $EDITOR with Ctrl+X Ctrl+E
          autoload -Uz edit-command-line
          zle -N edit-command-line
          bindkey '^X^E' edit-command-line

          # zsh-only word boundaries; not an environment variable.
          WORDCHARS=''${WORDCHARS//[\/\\#]}
        ''
        # Claude Code snapshots this shell for its Bash tool. Drop aliases that
        # hang on prompts (cp -i, rm -I), change output (ls=eza) or rewrite bare
        # words (global H/T/G), and pass unmatched globs through like bash
        # (grep --include=*.py). mkAfter: must run after shellAliases.
        (lib.mkAfter ''
          if [[ -n $CLAUDECODE ]]; then
            unalias cp mv rm ls 2>/dev/null
            # Quoted: unquoted global aliases expand while this block parses.
            unalias 'B' 'H' 'T' 'G' 'L' 2>/dev/null
            setopt no_nomatch
          fi
        '')
      ];
      sessionVariables = {
        LESS = "Fij.5JW";
      };
      syntaxHighlighting.enable = true;
      shellAliases = {
        ncf = "cd ~/nix-config && nvim && cd -";
        cl = "nix run --accept-flake-config github:numtide/llm-agents.nix#claude-code --";
        cx = "nix run --accept-flake-config github:numtide/llm-agents.nix#codex --";
        oc = "nix run --accept-flake-config github:numtide/llm-agents.nix#opencode2 --";
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
