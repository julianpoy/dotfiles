-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable netrw for vim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Install package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        copilot_model = "gpt-4o-copilot",
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = "<M-a>",
            accept_line = "<M-l>",
            accept_word = "<M-w>",
            next = "<M-n>",
            prev = "<M-N>",
            dismiss = "<M-d>",
          },
        },
      })
    end,
  },

  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    config = function()
        local mc = require("multicursor-nvim")
        mc.setup()

        local set = vim.keymap.set

        -- Add or skip cursor above/below the main cursor.
        set({"n", "x"}, "<up>", function() mc.lineAddCursor(-1) end)
        set({"n", "x"}, "<down>", function() mc.lineAddCursor(1) end)
        -- set({"n", "x"}, "<leader><up>", function() mc.lineSkipCursor(-1) end)
        -- set({"n", "x"}, "<leader><down>", function() mc.lineSkipCursor(1) end)

        -- Add or skip adding a new cursor by matching word/selection
        set({"n", "x"}, "<c-n>", function() mc.matchAddCursor(1) end)
        -- set({"n", "x"}, "<leader>s", function() mc.matchSkipCursor(1) end)
        -- set({"n", "x"}, "<leader>N", function() mc.matchAddCursor(-1) end)
        -- set({"n", "x"}, "<leader>S", function() mc.matchSkipCursor(-1) end)

        -- Add and remove cursors with control + left click.
        set("n", "<c-leftmouse>", mc.handleMouse)
        -- set("n", "<c-leftdrag>", mc.handleMouseDrag)
        set("n", "<c-leftrelease>", mc.handleMouseRelease)

        -- Disable and enable cursors.
        -- set({"n", "x"}, "<c-q>", mc.toggleCursor)

        -- Mappings defined in a keymap layer only apply when there are
        -- multiple cursors. This lets you have overlapping mappings.
        mc.addKeymapLayer(function(layerSet)

            -- Select a different cursor as the main one.
            layerSet({"n", "x"}, "<left>", mc.prevCursor)
            layerSet({"n", "x"}, "<right>", mc.nextCursor)

            -- Delete the main cursor.
            layerSet({"n", "x"}, "<leader>x", mc.deleteCursor)

            -- Enable and clear cursors using escape.
            layerSet("n", "<esc>", function()
                if not mc.cursorsEnabled() then
                    mc.enableCursors()
                else
                    mc.clearCursors()
                end
            end)
        end)

        -- Customize how cursors look.
        -- local hl = vim.api.nvim_set_hl
        -- hl(0, "MultiCursorCursor", { reverse = true })
        -- hl(0, "MultiCursorVisual", { link = "Visual" })
        -- hl(0, "MultiCursorSign", { link = "SignColumn"})
        -- hl(0, "MultiCursorMatchPreview", { link = "Search" })
        -- hl(0, "MultiCursorDisabledCursor", { reverse = true })
        -- hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
        -- hl(0, "MultiCursorDisabledSign", { link = "SignColumn"})
    end
  },

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      {
        'williamboman/mason.nvim',
        version = "^1.0.0",
        config = function()
          require("mason").setup()

          -- Auto-update on startup (non-blocking)
          vim.defer_fn(function()
            require("mason.api.command").MasonUpdate()
          end, 100)
        end,
      },
      { 'williamboman/mason-lspconfig.nvim', version = "^1.0.0" },
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim', opts = {} },

      -- Autocompletion
      'saghen/blink.cmp',

      'yioneko/nvim-vtsls', -- A plugin for VTSLS, not really a great place to put it but oh well
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gy', require('telescope.builtin').lsp_type_definitions, '[G]oto T[y]pe [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>h', vim.lsp.buf.hover, '[H]over Documentation')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('<leader>cao', require('vtsls').commands.organize_imports, '[C]ode [A]ction [O]rganize Imports (TS & JS only)')
          map('<leader>carm', require('vtsls').commands.remove_unused, '[C]ode [A]ction [R]re[m]ove Unused (TS & JS only)')
          map('<leader>cai', require('vtsls').commands.remove_unused, '[C]ode [A]ction [I]mport All (TS & JS only)')
          map('<leader>caf', require('vtsls').commands.fix_all, '[C]ode [A]ction [F]ix All (TS & JS only)')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        end,
      })

      vim.api.nvim_create_autocmd({ "CursorHold" }, {
        group = vim.api.nvim_create_augroup('jp-lsp-cursorhold', { clear = true }),
        callback = function()
          for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_get_config(winid).zindex then
              return
            end
          end
          vim.diagnostic.open_float({
            focusable = false,
            close_events = {
              "CursorMoved",
              "CursorMovedI",
              "BufHidden",
              "InsertCharPre",
              "WinLeave",
            },
          })
        end
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        vtsls = {
          settings = {
            vtsls = {
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                  entriesLimit = 15,
                },
              },
            },
            typescript = {
              inlayHints = {
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = true },
              },
              preferGoToSourceDefinition = true,
              tsserver = {
                maxTsServerMemory = 16384,
              },
              preferences = {
                importModuleSpecifier = "project-relative",
                preferTypeOnlyAutoImports = true,
                renameMatchingJsxTags = true,
              },
            },
            javascript = {
              preferGoToSourceDefinition = true,
              preferences = {
                importModuleSpecifier = "project-relative",
                renameMatchingJsxTags = true,
              },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'vtsls',
        'js-debug-adapter'
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = { 'L3MON4D3/LuaSnip', version = 'v2.*' },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'none',

        ['<CR>'] = { 'accept', 'fallback' },

        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
      },
      snippets = { preset = 'luasnip' },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      fuzzy = {
        implementation = "prefer_rust_with_warning"
      },
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = true
          }
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
        }
      },
      signature = {
        enabled = true,
        window = {
          show_documentation = false,
        },
      },
    },
  },

  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    opts = {}
  },

  -- Adds git releated signs to the gutter, as well as utilities for managing changes
  -- {
  --   'lewis6991/gitsigns.nvim',
  --   opts = {
  --     -- See `:help gitsigns.txt`
  --     signs = {
  --       add = { text = '+' },
  --       change = { text = '~' },
  --       delete = { text = '_' },
  --       topdelete = { text = '‾' },
  --       changedelete = { text = '~' },
  --     },
  --   },
  -- },

  -- Syntax theme
  {
    'rebelot/kanagawa.nvim',
    config = function()
      vim.o.background = "dark"
      vim.cmd.colorscheme 'kanagawa'
      require('kanagawa').setup({
        compile = true,
        dimInactive = true,
        statementStyle = { bold = false },
        colors = {
          palette = {
            sumiInk0 = "#1d2021", -- Statuslines and floating windows background
            sumiInk1 = "#282828", --
            sumiInk2 = "#3c3836",
            sumiInk3 = "#141617", -- Normal bg
            sumiInk4 = "#504945",
          },
          theme = {
            all = {
              ui = {
                bg_gutter = "none"
              }
            }
          }
        },
        overrides = function(colors)
          return {
            ['@type.qualifier'] = { fg = colors.palette.peachRed, italic = true },
            ['@property'] = { fg = colors.palette.fujiWhite, italic = false },
            ['@method.call'] = { fg = colors.palette.fujiWhite, italic = false },
            ['@function.call'] = { fg = colors.palette.fujiWhite, italic = false },
            ['@field'] = { fg = colors.palette.fujiWhite, italic = false },
            ['@boolean'] = { fg = colors.palette.surimiOrange, bold = false },
            ['LspSignatureActiveParameter'] = { fg = colors.palette.waveAqua2, bold = false },
          }
        end,
      })
      vim.schedule(vim.cmd.KanagawaCompile)
    end,
    lazy = false,
    priority = 1000
  },

  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local kanagawa_palette = require("kanagawa.colors").setup().palette
      local kanagawa_theme = require("kanagawa.colors").setup().theme

      local theme = {
        normal = {
          a = { bg = kanagawa_palette.waveBlue2, fg = kanagawa_theme.ui.fg },
          b = { bg = kanagawa_theme.ui.bg_m1, fg = kanagawa_theme.ui.fg },
          c = { bg = kanagawa_theme.ui.bg_p3, fg = kanagawa_theme.ui.fg_dim },
        },
        insert = {
          a = { bg = kanagawa_palette.autumnGreen, fg = kanagawa_theme.ui.bg },
        },
        command = {
          a = { bg = kanagawa_theme.syn.operator, fg = kanagawa_theme.ui.bg },
        },
        visual = {
          a = { bg = kanagawa_theme.syn.keyword, fg = kanagawa_theme.ui.bg },
        },
        replace = {
          a = { bg = kanagawa_theme.syn.constant, fg = kanagawa_theme.ui.bg },
        },
        inactive = {
          a = { bg = kanagawa_theme.ui.bg_m3, fg = kanagawa_theme.ui.fg_dim },
          b = { bg = kanagawa_theme.ui.bg_m3, fg = kanagawa_theme.ui.fg_dim },
          c = { bg = kanagawa_theme.ui.bg_m3, fg = kanagawa_theme.ui.fg_dim },
        },
      }

      require('lualine').setup {
        options = {
          theme = theme,
        },
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1, -- 0: just the filename, 1: relative path, 2: absolute path
            },
          },
          lualine_x = {
            'filetype',
            {
              function()
                return require("lazy.status").updates()
              end,
              cond = require("lazy.status").has_updates,
              color = { fg = "#ff9e64" },
            },
          },
        },
      }
    end,
  },

  -- Add indentation guides even on blank lines
  -- {
  --   'lukas-reineke/indent-blankline.nvim',
  --   tag = "v3.7.2",
  --   config = function()
  --     require("ibl").setup {
  --       indent = {
  --         char = "┊"
  --       },
  --       whitespace = {
  --         remove_blankline_trail = true,
  --       },
  --       scope = {
  --         enabled = false,
  --       },
  --     }
  --   end
  -- },

  -- Multiple cursors with <C-n>
  -- {
  --   'mg979/vim-visual-multi',
  -- },

  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  -- Powerful search
  {
    'windwp/nvim-spectre',
    config = function()
      local api = require('spectre')
      api.setup({
        use_trouble_qf = true,
      })
      vim.keymap.set('n', '<leader>SG', api.open, { desc = 'Persistent [S]earch [G]lobally' })
    end,
    dependencies = { 'nvim-lua/plenary.nvim', 'folke/trouble.nvim' },
  },

  -- Save when exiting insert mode
  -- {
  --   'Pocco81/auto-save.nvim',
  --   config = function()
  --     require("auto-save").setup {
  --       enabled = true
  --     }
  --   end,
  -- },

  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
    },
    config = function()
      local HEIGHT_RATIO = 0.9
      local WIDTH_RATIO = 0.5

      require('nvim-tree').setup {
        on_attach = "default",
        actions = {
          open_file = {
            quit_on_open = true,
          },
        },
        view = {
          relativenumber = true,
          centralize_selection = true,
          float = {
            enable = true,
            quit_on_focus_loss = false,
            open_win_config = function()
              local screen_w = vim.opt.columns:get()
              local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
              local window_w = screen_w * WIDTH_RATIO
              local window_h = screen_h * HEIGHT_RATIO
              local window_w_int = math.floor(window_w)
              local window_h_int = math.floor(window_h)
              local center_x = (screen_w - window_w) / 2
              local center_y = ((vim.opt.lines:get() - window_h) / 2)
                  - vim.opt.cmdheight:get()
              return {
                border = "rounded",
                relative = "editor",
                row = center_y,
                col = center_x,
                width = window_w_int,
                height = window_h_int,
              }
            end,
          },
          width = function()
            return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
          end,
        },
        renderer = {
          add_trailing = true,
          icons = {
            webdev_colors = true,
            git_placement = "after",
            glyphs = {
              default = "",
              symlink = "",
              folder = {
                arrow_closed = "▸",
                arrow_open = "▾",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "*",
                staged = "~",
                unmerged = "",
                renamed = "->",
                untracked = "+",
                deleted = "-",
                ignored = "",
              },
            },
          },
        },
      }

      local nvimtreeApi = require('nvim-tree.api')
      local function toggle()
        nvimtreeApi.tree.toggle({
          find_file = true,
          focus = true,
          path = '<arg>',
          update_root = '<bang>'
        })
      end

      local nvimtreeView = require('nvim-tree.view')
      local function closeIfNvimtreeFocused()
        if nvimtreeView.is_visible then
          nvimtreeApi.tree.close()
        end
      end

      vim.keymap.set('n', '<leader>t', toggle, { desc = 'File [T]ree' })
      vim.keymap.set('n', '<esc>', closeIfNvimtreeFocused)
    end,
  },

  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim'
    }
  },

  -- Use vim inputs and selects instead of status line prompts
  {
    'stevearc/dressing.nvim',
    opts = {},
    lazy = false,
    event = "VeryLazy",
    config = function()
      require("dressing").setup({
        input = {
          insert_only = false,
          relative = "cursor",
          get_config = function(opts)
            if opts.kind == "codeaction" then
              local telescopeCursor = require("telescope.themes").get_cursor()
              return {
                telescope = telescopeCursor,
              }
            end
          end
        }
      })
    end
  },

  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    event = "VeryLazy",
  },

  {
    'kevinhwang91/nvim-ufo',
    version = "*",
    dependencies = {
      'kevinhwang91/promise-async'
    },
    config = function()
      vim.o.foldcolumn = '0'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      
      -- This displays a pretty "󰁂 ##" next to a given fold which is nicer than the default "..."
      local handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = (' 󰁂 %d '):format(endLnum - lnum)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0
          for _, chunk in ipairs(virtText) do
              local chunkText = chunk[1]
              local chunkWidth = vim.fn.strdisplaywidth(chunkText)
              if targetWidth > curWidth + chunkWidth then
                  table.insert(newVirtText, chunk)
              else
                  chunkText = truncate(chunkText, targetWidth - curWidth)
                  local hlGroup = chunk[2]
                  table.insert(newVirtText, {chunkText, hlGroup})
                  chunkWidth = vim.fn.strdisplaywidth(chunkText)
                  -- str width returned from truncate() may less than 2nd argument, need padding
                  if curWidth + chunkWidth < targetWidth then
                      suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                  end
                  break
              end
              curWidth = curWidth + chunkWidth
          end
          table.insert(newVirtText, {suffix, 'MoreMsg'})
          return newVirtText
      end

      require("ufo").setup({
        provider_selector = function(bufnr, filetype, buftype)
          return {'treesitter', 'indent'}
        end,
        fold_virt_text_handler = handler,
        preview = {
          win_config = {
            -- Link the background highlight group of the preview window to the background of the editor
            winhighlight = 'Normal:Folded',
          },
        }
      })
    end
  },

  -- Fuzzy Finder Algorithm which requires local dependencies to be built.
  -- Only load if `make` is available. Make sure you have the system
  -- requirements installed.
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    -- NOTE: If you are having trouble with this installation,
    --       refer to the README for telescope-fzf-native for more instructions.
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  -- Highlight code
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ":TSUpdate",
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim' },

      auto_install = true,

      highlight = {
        enable = true,
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = false,
        disable = { 'python', 'typescript', 'javascript', 'tsx' }
      },
      incremental_selection = {
        enable = false, -- Perhaps play with in the future, but not useful for now
      },
    },
  },

  -- Debugger
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- Creates a beautiful debugger UI
      'rcarriga/nvim-dap-ui',

      -- Required dependency for nvim-dap-ui
      'nvim-neotest/nvim-nio',

      -- Installs the debug adapters for you
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Add your own debuggers here
      'leoluz/nvim-dap-go',
    },
    keys = {
      {
        '<F5>',
        function()
          require('dap').continue()
        end,
        desc = 'Debug: Start/Continue',
      },
      {
        '<F1>',
        function()
          require('dap').step_into()
        end,
        desc = 'Debug: Step Into',
      },
      {
        '<F2>',
        function()
          require('dap').step_over()
        end,
        desc = 'Debug: Step Over',
      },
      {
        '<F3>',
        function()
          require('dap').step_out()
        end,
        desc = 'Debug: Step Out',
      },
      {
        '<leader>b',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Debug: Toggle Breakpoint',
      },
      {
        '<leader>B',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      {
        '<F7>',
        function()
          require('dapui').toggle()
        end,
        desc = 'Debug: See last session result.',
      },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      for _, adapter in pairs({ "node", "chrome" }) do
          local pwa_adapter = "pwa-" .. adapter

          -- Handle launch.json configurations
          -- which specify type as "node" or "chrome"
          -- Inspired by https://github.com/StevanFreeborn/nvim-config/blob/main/lua/plugins/debugging.lua#L111-L123

          -- Main adapter
          dap.adapters[pwa_adapter] = {
              type = "server",
              host = "localhost",
              port = "${port}",
              executable = {
                  command = "js-debug-adapter",
                  args = { "${port}" },
              },
              enrich_config = function(config, on_config)
                  -- Under the hood, always use the main adapter
                  config.type = pwa_adapter
                  on_config(config)
              end,
          }

          -- Dummy adapter, redirects to the main one
          dap.adapters[adapter] = dap.adapters[pwa_adapter]
      end

      require('mason-nvim-dap').setup {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,
        handlers = {},
        ensure_installed = {},
      }

      -- Dap UI setup
      -- For more information, see |:help nvim-dap-ui|
      dapui.setup {
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }

      -- Change breakpoint icons
      -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
      -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
      -- local breakpoint_icons = vim.g.have_nerd_font
      --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
      -- for type, icon in pairs(breakpoint_icons) do
      --   local tp = 'Dap' .. type
      --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
      -- end

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  }
}, {
  checker = {
    enabled = true,
    concurrency = 4, ---@type number? set to 1 to check for updates very slowly
    notify = false, -- get a notification when new updates are found
    frequency = 86400, -- check for updates every day
    check_pinned = true, -- check for pinned packages that can't be updated
  },
})

-- [[ Setting options ]]
-- See `:help vim.o`

-- Do not show highlight for search results
vim.opt.hlsearch = false

-- Make line numbers default (hybrid)
vim.wo.relativenumber = true
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 300
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Enable proper colors
vim.o.termguicolors = true

-- Preserve some lines below the cursor
vim.opt.scrolloff = 5

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap. j and k will move within a wrapped line, unless you're jumping multiple lines
vim.keymap.set({ 'n', 'v' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ 'n', 'v' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Ctrl+q for lazy quit
vim.keymap.set({ 'n', 'i', 'v' }, '<C-q>', '<esc>:q<CR>')
-- Ctrl+s for lazy save
vim.keymap.set({ 'n' }, '<C-s>', '<esc>:w<CR>')

-- Keep visual block highlighted during indent
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('v', '<', '<gv')

-- Unbind 's' since I don't use it and often miss the space key
vim.keymap.set({ 'n', 'v' }, 's', '')

-- Move code vertically with Media+jk
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { silent = true })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { silent = true })
vim.keymap.set('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { silent = true })
vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { silent = true })
vim.keymap.set('v', '<A-j>', ':m \'>+1<CR>gv=gv', { silent = true })
vim.keymap.set('v', '<A-k>', ':m \'<-2<CR>gv=gv', { silent = true })

-- Smooth scrolling (scroll one line at a time)
vim.keymap.set({ 'n', 'v', 'i' }, '<ScrollWheelUp>', '<C-Y>', { silent = true })
vim.keymap.set({ 'n', 'v', 'i' }, '<ScrollWheelDown>', '<C-E>', { silent = true })

-- Maintenance keymaps
vim.keymap.set("n", "<leader>Mp", ":Lazy check<CR>", { desc = "[M]aintenance Update [P]lugins" })
vim.keymap.set("n", "<leader>Ml", ":MasonUpdate<CR>", { desc = "[M]aintenance Update [L]SP (Mason)" })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local open_with_trouble = require("trouble.sources.telescope").open
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ["<c-t>"] = open_with_trouble,
      },
      n = {
        ["<c-t>"] = open_with_trouble
      },
    },
  },
  pickers = {
    find_files = {
      hidden = true
    },
    lsp_references = {
      show_line = false
    },
    lsp_definitions = {
      show_line = false
    },
    lsp_type_definitions = {
      show_line = false
    },
    lsp_implementations = {
      show_line = false
    },
  }
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sc', require('telescope.builtin').commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader>sk', require('telescope.builtin').keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume (previous search)' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous [d]iagnostic message" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next [d]iagnostic message" })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Show floating diagnostic [e]rror message" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Disable annoying inline virtual_text lint/lsp errors
vim.diagnostic.config({
  virtual_text = false,
  underline = true,
  signs = true,
  update_in_insert = false,
})

vim.o.equalalways = false

vim.keymap.set('t', '<C-w>h', "<C-\\><C-n><C-w>h", { silent = true })
vim.keymap.set('t', '<C-w>j', "<C-\\><C-n><C-w>j", { silent = true })
vim.keymap.set('t', '<C-w>k', "<C-\\><C-n><C-w>k", { silent = true })
vim.keymap.set('t', '<C-w>l', "<C-\\><C-n><C-w>l", { silent = true })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
