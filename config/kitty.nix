{
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMono Nerd Font Mono";
    settings = {
      clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
      enable_audio_bell = false;
      scrollback_lines = 50000;
      visual_bell_duration = 0.5;
      macos_option_as_alt = true;
    };
  };
}
