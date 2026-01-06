{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMono Nerd Font Mono";
    settings = {
      enable_audio_bell = false;
      macos_option_as_alt = true;
      notify_on_cmd_finish = "unfocused";
      scrollback_lines = 50000;
      visual_bell_duration = 0.5;
    };
  };
}
