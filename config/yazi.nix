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
      mgr.append_keymap = [
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
        {
          on = "!";
          for = "unix";
          run = ''shell "$SHELL" --block'';
          desc = "Open $SHELL here";
        }
      ];
    };
  };
}
