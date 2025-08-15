{
  programs.git = {
    enable = true;
    lfs.enable = true;
    userEmail = "s.kitimoon@gmail.com";
    userName = "skitimoon";
    ignores = [
      ".kiro/"
      ".stfolder"
      ".stignore"
      "Session.vim"
      "scratchpad.*"
    ];
  };
}
