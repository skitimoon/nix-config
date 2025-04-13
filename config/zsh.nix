{pkgs, ...}: {
  programs.zsh = {
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
    initExtra = ''export PATH="/opt/homebrew/bin:$PATH"'';
    plugins = [
      {
        name = pkgs.zsh-vi-mode.pname;
        inherit (pkgs.zsh-vi-mode) src;
      }
    ];
    sessionVariables = {
      LESS = "Fij.5JW";
      WORDCHARS = "\${WORDCHARS/\\/}";
    };
    syntaxHighlighting.enable = true;
    shellAliases = {
      ncf = "cd ~/nix-config && nvim && cd -";
      l = "eza -lF";
      la = "eza -laF";
      ll = "eza -l";
      cp = "cp -i";
      rm = "rm -I ";
      mv = "mv -i";
      ".." = "cd ..";
    };
    shellGlobalAliases = {
      H = "| head";
      T = "| tail";
      G = "| grep";
      L = "| less";
    };
  };
}
