{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      init.defaultBranch = "main";
      fetch.prune = true;
      user = {
        email = "s.kitimoon@gmail.com";
        name = "skitimoon";
      };
    };
    ignores = [".kiro/" ".stfolder" ".stignore" "Session.vim" "scratchpad.*"];
  };
}
