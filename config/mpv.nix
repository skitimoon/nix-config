{pkgs, ...}: {
  programs.mpv = {
    enable = true;
    bindings = {
      WHEEL_UP = "frame-back-step";
      WHEEL_DOWN = "frame-step";
      c = "script-message chat-hidden";
      q = "quit-watch-later";
      Q = "quit";
    };
    config = {
      cache-secs = 3600;
      demuxer-max-bytes = "512MiB";
      demuxer-max-back-bytes = "256MiB";
      sub-auto = "all";
      slang = "en";
      ytdl-raw-options = ''sub-langs="^en.*",write-subs=,write-auto-subs='';
    };
    scripts = with pkgs.mpvScripts; [thumbfast uosc youtube-chat];
    scriptOpts = {mpv-youtube-chat = {message-duration = 60000;};};
  };
}
