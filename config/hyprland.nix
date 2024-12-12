{
  lib,
  ...
}:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = [
        "DP-1, 1920x1080@144,0x0, 1"
        "HDMI-A-1, 1920x1080, 1920x0, 1"
      ];

      "$terminal" = "kitty";

      exec-once = [
        "floorp"
        "logseq"
        "super-productivity"
        "swaync"
        "swww-daemon && swww img ~/nix-config/config/wallpapers/benjamin-voros-phIFdC6lA4E-unsplash.jpg"
        "thunderbird"
        "waybar"
      ];

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      general = {
        gaps_out = 7;
        border_size = 2;

        "col.active_border" = lib.mkDefault "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = lib.mkDefault "rgba(595959aa)";
      };

      decoration = {
        rounding = 10;
      };

      misc = {
        disable_hyprland_logo = true;
        key_press_enables_dpms = true;
      };

      master = {
        new_status = "master";
      };

      input = {
        kb_layout = "us,th";
        kb_options = "grp:ctrl_space_toggle";
        accel_profile = "flat";
        scroll_factor = 0.6;
      };

      cursor = {
        hide_on_key_press = true;
      };

      # device = {
      #   name = "logitech-g305-1";
      # };

      "$mod" = "SUPER";
      bind = [
        "$mod, return, exec, $terminal"
        "$mod, Q, killactive"
        "$mod , F, fullscreen"
        "$mod SHIFT, F, togglefloating"

        "$mod SHIFT, return, exec, $terminal -e yazi"
        "$mod, backslash, exec, $terminal -e ssh -t server tmux attach -t arbbot"
        "$mod, bracketright, exec, $terminal -e ssh -t yimserver tmux attach -t bot"
        "$mod, space, exec, rofi -show drun"
        "$mod SHIFT, space, exec, rofi -show run"
        "$mod, C, exec, rofi -show calc -modi calc -no-show-match -no-sort"
        "$mod, V, exec, rofi -modi clipboard:~/.config/cliphist/cliphist-rofi-img -show clipboard -show-icons"
        "$mod, grave, exec, swaync-client -t"

        "$mod, W, focusmonitor, DP-1"
        "$mod, E, focusmonitor, HDMI-A-1"
        "$mod SHIFT, W, movewindow, mon:DP-1"
        "$mod SHIFT, E, movewindow, mon:HDMI-A-1"

        # Apps Shortcut
        "$mod CTRL, V, exec, code"
        "$mod CTRL, B, exec, blueman-manager"
        "$mod CTRL, escape, exec, poweroff"

        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"

        "$mod, 1, focusworkspaceoncurrentmonitor, 1"
        "$mod, 2, focusworkspaceoncurrentmonitor, 2"
        "$mod, 3, focusworkspaceoncurrentmonitor, 3"
        "$mod, 4, focusworkspaceoncurrentmonitor, 4"
        "$mod, 5, focusworkspaceoncurrentmonitor, 5"
        "$mod, 6, focusworkspaceoncurrentmonitor, 6"
        "$mod, 7, focusworkspaceoncurrentmonitor, 7"
        "$mod, 8, focusworkspaceoncurrentmonitor, 8"
        "$mod, 9, focusworkspaceoncurrentmonitor, 9"
        "$mod, 0, focusworkspaceoncurrentmonitor, 10"
        "$mod CTRL, 1, focusworkspaceoncurrentmonitor, 6"
        "$mod CTRL, 2, focusworkspaceoncurrentmonitor, 7"
        "$mod CTRL, 3, focusworkspaceoncurrentmonitor, 8"
        "$mod CTRL, 4, focusworkspaceoncurrentmonitor, 9"
        "$mod CTRL, 5, focusworkspaceoncurrentmonitor, 10"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlayPause, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      windowrulev2 = [
        "workspace 2, class:floorp"
        "workspace 6, class:thunderbird"
        "workspace 7, class:Logseq"
        "workspace 10, class:superProductivity"
      ];

    };
  };
}
