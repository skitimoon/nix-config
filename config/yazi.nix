{
  programs.yazi = {
    enable = true;
    settings = {
      mgr = {
        linemode = "size";
        show_hidden = true;
      };
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
          run = ''shell 'exec env YAZI_SHELL=1 "$SHELL" -i' --block'';
          desc = "Open $SHELL here";
        }
      ];
    };
  };

  programs.starship.settings = {
    format = "\${custom.yazi}$all";
    custom.yazi = {
      command = "printf '(Yazi)'";
      when = ''test -n "$YAZI_SHELL"'';
      format = "[$output]($style) ";
      style = "bold yellow";
    };
  };
}
