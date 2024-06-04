-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable netrw for vim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

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

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      {
        'j-hui/fidget.nvim',
        opts = {}
      },
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
    },
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
    },
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    opts = {}
  },

  -- Adds git releated signs to the gutter, as well as utilities for managing changes
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

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

  -- Pretty statusline that shows mode and file info
  {
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'gruvbox_dark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    tag = "v3.6.2",
    config = function()
      require("ibl").setup {
        indent = {
          char = "┊"
        },
        whitespace = {
          remove_blankline_trail = true,
        },
        scope = {
          enabled = false,
        },
      }
    end
  },

  -- { -- Easy editing movements for quotes, parenthesis, etc
  --   'tpope/vim-surround'
  -- },

  -- Multiple cursors with <C-n>
  {
    'mg979/vim-visual-multi',
    tag = "v0.5.8",
  },

  -- Powerful search
  {
    'windwp/nvim-spectre',
    config = function()
      local api = require('spectre')
      vim.keymap.set('n', '<leader>SG', api.open, { desc = 'Persistent [S]earch [G]lobally' })
    end,
    dependencies = { 'nvim-lua/plenary.nvim' }
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
    opts = {
    },
    config = function()
      local HEIGHT_RATIO = 0.8
      local WIDTH_RATIO = 0.5

      require('nvim-tree').setup {
        on_attach = "default",
        view = {
          relativenumber = true,
          centralize_selection = true,
          float = {
            enable = true,
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
            webdev_colors = false,
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
        }
      }

      local function toggle()
        require('nvim-tree.api').tree.toggle({
          find_file = true,
          focus = true,
          path = '<arg>',
          update_root = '<bang>'
        })
      end

      vim.keymap.set('n', '<leader>t', toggle, { desc = 'File [T]ree' })
    end,
  },

  -- Native feeling comment operations - use "gc" to comment visual regions/lines
  {
    'numToStr/Comment.nvim',
    opts = {}
  },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim'
    }
  },

  -- Use vim inputs and selects instead of status line prompts
  {
    'stevearc/dressing.nvim',
    opts = {},
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

  -- Highligh code
  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
  },

  -- Built-in debugger
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      -- Creates a beautiful debugger UI
      'rcarriga/nvim-dap-ui',

      -- Required by nvim-dap-ui
      'nvim-neotest/nvim-nio',

      -- Installs the debug adapters for you
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Add your own debuggers here
      'leoluz/nvim-dap-go',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      require('mason-nvim-dap').setup {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_setup = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
          'node2',
        },
      }

      -- Basic debugging keymaps, feel free to change to your liking!
      vim.keymap.set('n', '<F5>', dap.continue)
      vim.keymap.set('n', '<F1>', dap.step_into)
      vim.keymap.set('n', '<F2>', dap.step_over)
      vim.keymap.set('n', '<F3>', dap.step_out)
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = "Toggle [b]reakpoint" })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = "Set [b]reakpoint with condition" })

      -- Dap UI setup
      -- For more information, see |:help nvim-dap-ui|
      dapui.setup {
        -- Set icons to characters that are more likely to work in every terminal.
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
            disconnect = "⏏",
          },
        },
      }
      -- toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      vim.keymap.set("n", "<F7>", dapui.toggle)

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Install golang specific config
      require('dap-go').setup()
    end,
  }
}, {
  checker = {
    -- automatically check for plugin updates
    enabled = false,
    notify = false,   -- get a notification when new updates are found
    frequency = 3600, -- check for updates every hour
  },
})

-- [[ Setting options ]]
-- See `:help vim.o`

-- Do not show highlight for search results
vim.opt.hlsearch = false

-- Make line numbers default (hybrid)
vim.wo.relativenumber = true

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
vim.o.updatetime = 250
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
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
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
local telescopeCursor = require("telescope.themes").get_cursor()
require('dressing').setup {
  input = {
    insert_only = false,
    relative = "cursor",
  },
  select = {
    get_config = function(opts)
      if opts.kind == "codeaction" then
        return {
          telescope = telescopeCursor,
        }
      end
    end,
  },
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

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
  auto_install = false,

  highlight = { enable = true },
  indent = {
    enable = false, -- Disabled for now, had trouble with it just being wrong all the time in TypeScript
    -- disable = { 'python' }
  },
  incremental_selection = {
    enable = false, -- Perhaps play with in the future, but not useful for now
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
}

-- [[ Fold based on TreeSitter ]]
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 99

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous [d]iagnostic message" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next [d]iagnostic message" })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = "Show floating diagnostic [e]rror message" })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- LSP settings.
local on_attach = function(_, bufnr)
  local map = function(modes, keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set(modes, keys, func, { buffer = bufnr, desc = desc })
  end

  map('n', '<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('n', '<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  map('n', 'gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  map('n', 'gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  map('n', 'gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  map('n', 'gy', require('telescope.builtin').lsp_type_definitions, '[G]oto T[y]pe Definition')
  map('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')           -- TODO: potentially remap this
  map('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols') -- TODO: potentially remap this

  -- See `:help K` for why this keymap
  map('n', '<leader>h', vim.lsp.buf.hover, 'Hover Documentation')
  map({ 'n', 'i' }, '<C-h>', vim.lsp.buf.signature_help, 'Signature Documentation') -- TODO: potentially remap this

  -- TODO: potentially remove this
  -- Lesser used LSP functionality
  map('n', 'gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  map('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  map('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  map('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })


  -- Function to check if a floating dialog exists and if not
  -- then check for diagnostics under the cursor
  function OpenDiagnosticIfNoFloat()
    for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_config(winid).zindex then
        return
      end
    end
    -- THIS IS FOR BUILTIN LSP
    vim.diagnostic.open_float({
      scope = "cursor",
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

  -- Show diagnostics under the cursor when holding position
  vim.api.nvim_create_augroup("lsp_diagnostics_hold", { clear = true })
  vim.api.nvim_create_autocmd({ "CursorHold" }, {
    pattern = "*",
    command = "lua OpenDiagnosticIfNoFloat()",
    group = "lsp_diagnostics_hold",
  })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  tsserver = {},
}

local handlers = {
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { max_width = 100 }),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { max_width = 100 }),
}

-- Disable annoying inline virtual_text lint/lsp errors
vim.diagnostic.config({
  virtual_text = false,
  underline = true
})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      handlers = handlers
    }
  end,
}

-- nvim-cmp setup
local cmp = require 'cmp'

cmp.setup {
  performance = {
    max_view_entries = 10,
  },
  preselect = cmp.PreselectMode.None,
  -- window = {
  --   completion = cmp.config.window.bordered(),
  --   documentation = cmp.config.window.bordered(),
  -- },
  formatting = {
    format = function(entry, vim_item)
      vim_item.abbr = string.sub(vim_item.abbr, 1, 20)
      return vim_item
    end
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    -- { name = 'buffer' },
    { name = 'path' }
  })
}

vim.o.equalalways = false

vim.keymap.set('t', '<C-w>h', "<C-\\><C-n><C-w>h", { silent = true })
vim.keymap.set('t', '<C-w>j', "<C-\\><C-n><C-w>j", { silent = true })
vim.keymap.set('t', '<C-w>k', "<C-\\><C-n><C-w>k", { silent = true })
vim.keymap.set('t', '<C-w>l', "<C-\\><C-n><C-w>l", { silent = true })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
