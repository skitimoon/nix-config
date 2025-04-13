{
  programs.yazi = {
    enable = true;
    settings = {
      preview = {
        max_width = 3840;
        max_height = 2160;
        wrap = "yes";
      };
    };
    keymap = {
      manager.append_keymap = [
        {
          on = ["g" "/"];
          run = "cd /";
          desc = "Cd to /";
        }
        {
          on = ["g" "t"];
          run = "cd /tmp";
          desc = "Cd to /tmp";
        }
      ];
    };
  };
}
