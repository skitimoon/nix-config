{
  lib,
  pkgs,
  ...
}: {
  programs.nvf = {
    enable = true;
    settings = {
      vim = let
        inherit (lib.generators) mkLuaInline;
      in {
        autocmds = [
          {
            event = ["FileType"];
            pattern = ["help"];
            callback = mkLuaInline ''
              function(event)
                vim.bo[event.buf].buflisted = false
                vim.schedule(function()
                  vim.keymap.set("n", "q", function()
                    vim.cmd("close")
                    pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
                  end, {
                    buffer = event.buf,
                    silent = true,
                    desc = "Quit buffer",
                  })
                end)
              end
            '';
            desc = "Close some filetypes with <q>";
          }
          {
            event = ["VimResized"];
            callback = mkLuaInline ''
              function()
                local current_tab = vim.fn.tabpagenr()
                vim.cmd("tabdo wincmd =")
                vim.cmd("tabnext " .. current_tab)
              end
            '';
            desc = "Resize splits if window got resized";
          }
        ];
        luaConfigPre = "local miniclue = require('mini.clue')";
        searchCase = "smart";
        lazy.plugins = {
          "better-escape.nvim" = {
            package = pkgs.vimPlugins.better-escape-nvim;
            setupModule = "better_escape";
            setupOpts = {timeout = 200;};
          };
        };
        keymaps = [
          # Clear search on escape
          {
            key = "<esc>";
            mode = "n";
            action = "<cmd>noh<cr><esc>";
            desc = "Clear search and escape";
          }
          {
            key = "<leader>fs";
            mode = "n";
            action = "<cmd>update<cr>";
            desc = "Save file if updated";
          }
          {
            key = "<leader>qq";
            mode = "n";
            action = "<cmd>qa<cr>";
            desc = "Quit all";
          }
          # Files & Buffers
          {
            key = "[b";
            mode = "n";
            action = "<cmd>bprevious<cr>";
          }
          {
            key = "]b";
            mode = "n";
            action = "<cmd>bnext<cr>";
          }
          {
            key = "<leader>bb";
            mode = "n";
            action = "function() MiniPick.builtin.buffers() end";
            lua = true;
            desc = "Pick Buffer";
          }
          # Files & Buffers
          {
            key = "<leader>bd";
            mode = "n";
            action = "function() MiniBufremove.delete() end";
            lua = true;
            desc = "Delete Buffer";
          }
          {
            key = "<leader>ff";
            mode = "n";
            action = "function() MiniPick.builtin.files() end";
            lua = true;
            desc = "Pick Files";
          }
          # Search
          {
            key = "<leader>ss";
            mode = "n";
            action = "function() MiniPick.builtin.grep_live() end";
            lua = true;
            desc = "Grep Live";
          }
          {
            key = "<leader>sh";
            mode = "n";
            action = "function() MiniPick.builtin.help() end";
            lua = true;
            desc = "Pick Help";
          }
          # Move lines
          {
            key = "[g";
            mode = "n";
            action = "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==";
          }
          {
            key = "]g";
            mode = "n";
            action = "<cmd>execute 'move .+' . v:count1<cr>==";
          }
          # yanky.nvim
          {
            key = "]p";
            mode = "n";
            action = "<Plug>(YankyPutIndentAfterLinewise)";
          }
          {
            key = "[p";
            mode = "n";
            action = "<Plug>(YankyPutIndentBeforeLinewise)";
          }
          {
            key = "dig";
            mode = "n";
            action = "ggdG";
          }
          {
            key = "yig";
            mode = "n";
            action = "myggyG`y";
          }
          # Commenting
          {
            key = "gcy";
            mode = "n";
            action = "yy<cmd>normal gcc<cr>p";
            noremap = false;
            silent = false;
            desc = "Duplicate and comment";
          }
          {
            key = "gcs";
            mode = "n";
            action = "<cmd>normal gcc<cr>j<cmd>normal gcc<cr>";
            desc = "Toggle comment two lines";
          }
        ];

        options = {
          shiftwidth = 2;
          scrolloff = 4;
          sidescrolloff = 8;
        };

        lsp = {
          formatOnSave = true;
          lspSignature.enable = true;
          trouble.enable = true;
        };

        languages = {
          enableFormat = true;
          enableLSP = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;
          nix.enable = true;
          python = {
            enable = true;
            format.type = "ruff";
          };
        };

        visuals = {
          indent-blankline.enable = true;
          nvim-scrollbar.enable = true;
          nvim-cursorline.enable = true;
          fidget-nvim.enable = true;
        };

        theme = {
          enable = true;
          name = "dracula";
          # transparent = true;
        };

        autopairs.nvim-autopairs.enable = true;
        autocomplete.nvim-cmp.enable = true;
        treesitter = {
          enable = true;
          context.enable = true;
        };

        # binds = {
        #   cheatsheet.enable = true;
        # };

        git = {
          enable = true;
          gitsigns.enable = true;
        };

        utility = {
          yanky-nvim = {
            enable = true;
            setupOpts = {
              highlight.timer = 150;
            };
          };
        };

        mini = {
          ai.enable = true;
          basics = {
            enable = true;
            setupOpts = {
              mappings = {
                windows = true;
              };
            };
          };
          bufremove.enable = true;
          clue = {
            enable = true;
            setupOpts = {
              triggers = [
                # Leader triggers
                {
                  mode = "n";
                  keys = "<Leader>";
                }
                {
                  mode = "x";
                  keys = "<Leader>";
                }
                # Built-in completion
                {
                  mode = "i";
                  keys = "<C-x>";
                }
                # `g` key
                {
                  mode = "n";
                  keys = "g";
                }
                {
                  mode = "x";
                  keys = "g";
                }
                # Marks
                {
                  mode = "n";
                  keys = "'";
                }
                {
                  mode = "n";
                  keys = "`";
                }
                {
                  mode = "x";
                  keys = "'";
                }
                {
                  mode = "x";
                  keys = "`";
                }
                # Registers
                {
                  mode = "n";
                  keys = "\"";
                }
                {
                  mode = "x";
                  keys = "\"";
                }
                {
                  mode = "i";
                  keys = "<C-r>";
                }
                {
                  mode = "c";
                  keys = "<C-r>";
                }
                # Window commands
                {
                  mode = "n";
                  keys = "<C-w>";
                }
                # `z` key
                {
                  mode = "n";
                  keys = "z";
                }
                {
                  mode = "x";
                  keys = "z";
                }
              ];

              clues = mkLuaInline ''
                {
                  { mode = 'n', keys = '<Leader>b', desc = '+Buffers' },
                  { mode = 'n', keys = '<Leader>c', desc = '+Git-Conflict' },
                  { mode = 'n', keys = '<Leader>f', desc = '+File' },
                  { mode = 'n', keys = '<Leader>g', desc = '+Git' },
                  { mode = 'n', keys = '<Leader>h', desc = '+Gitsigns' },
                  { mode = 'n', keys = '<Leader>l', desc = '+LSP' },
                  { mode = 'n', keys = '<Leader>q', desc = '+Quit' },
                  { mode = 'n', keys = '<Leader>s', desc = '+Search' },
                  { mode = 'n', keys = '<Leader>t', desc = '+Toggle' },
                  { mode = 'n', keys = '<Leader>x', desc = '+Trouble' },
                  miniclue.gen_clues.builtin_completion(),
                  miniclue.gen_clues.g(),
                  miniclue.gen_clues.marks(),
                  miniclue.gen_clues.registers(),
                  miniclue.gen_clues.windows(),
                  miniclue.gen_clues.z(),
                }
              '';
              window.delay = 300;
            };
          };
          comment.enable = true;
          indentscope = {
            enable = true;
          };
          notify.enable = true;
          pick.enable = true;
          sessions = {
            enable = true;
            setupOpts = {
              autoread = true;
            };
          };
          snippets.enable = true;
          starter.enable = true;
          statusline.enable = true;
          surround = {
            enable = true;
            setupOpts = {
              mappings = {
                add = "ys";
                delete = "ds";
                find = "ysf";
                find_left = "ysF";
                highlight = "ysh";
                replace = "cs";
                update_n_lines = "ysn";
              };
            };
          };
          trailspace.enable = true;
        };

        terminal.toggleterm = {
          enable = true;
          lazygit.enable = true;
        };

        ui = {
          noice.enable = true;
          illuminate.enable = true;
          # modes-nvim.enable = true;
        };

        assistant.copilot = {
          enable = false;
          cmp.enable = true;
        };
      };
    };
  };
}
