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
      '';
      sessionVariables = {
        LESS = "Fij.5JW";
        WORDCHARS = "\${WORDCHARS//[\\/#]}";
      };
      syntaxHighlighting.enable = true;
      shellAliases = {
        ncf = "cd ~/nix-config && nvim && cd -";
        l = "eza -lF";
        la = "eza -laF";
        ll = "eza -l";
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
