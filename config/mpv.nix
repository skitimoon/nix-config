{
  programs.mpv = {
    enable = true;
    bindings = {
      WHEEL_UP = "frame-back-step";
      WHEEL_DOWN = "frame-step";
      q = "quit-watch-later";
    };
    config = {
      cache-secs = 3600;
      sub-auto = "all";
      slang = "en";
      ytdl-raw-options = ''sub-langs="^en.*",write-subs=,write-auto-subs='';
    };
  };
}
