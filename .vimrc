" ----- Quick customizations -----
let g:eslint = 1 " enables eslint popups
let g:i_like_trees = 0 " auto-open trees, always
let g:pretty_icons = 0 " requires https://github.com/ryanoasis/nerd-fonts
let g:write_on_focusloss = 0 " write when you alt-tab
let g:write_on_change = 0 " write whenever you change the file (can only be enabled when write_on_focusloss is disabled)
let g:enable_arrowkeys = 0 " self explanatory
let g:use_inline_definition_previews = 0 " goto-definition previews like VSCode by default
let g:theme = 'morhetz/gruvbox' " your syntax theme
let g:theme_name = 'gruvbox' " your syntax theme title (will differ from theme)
let g:copilot = 0 " github copilot (paid, but has no effect if not activated)
let g:tabnine = 0 " tabnine AI autocompletion (free, doesn't play super well with copilot and is lower quality)
let g:coc_extensions = [
      \ 'neoclide/coc-tsserver',
      \ 'neoclide/coc-css',
      \ 'iamcco/coc-angular',
      \ 'fannheyward/coc-rust-analyzer',
\ ] " any coc extensions that should be installed

" ----- End quick customizations -----

if g:tabnine
  let g:coc_extensions = g:coc_extensions + ['neoclide/coc-tabnine']
endif

if g:eslint
  let g:coc_extensions = g:coc_extensions + ['neoclide/coc-eslint']
endif

" Enable most vim settings
set nocompatible

" Confirm when quitting without having written
set confirm

" Disable arrow keys (force to use hjkl)
if !g:enable_arrowkeys
  noremap <Up> <Nop>
  noremap <Down> <Nop>
  noremap <Left> <Nop>
  noremap <Right> <Nop>

  noremap! <Up> <Nop>
  noremap! <Down> <Nop>
  noremap! <Left> <Nop>
  noremap! <Right> <Nop>
endif

" Force bash as shell (fish/vundle not compatible)
set shell=/bin/bash

" Vundle Setup
filetype off

call plug#begin()

" Status bar
Plug 'itchyny/lightline.vim'

" Color Scheme
Plug g:theme

" Coc for autocompletion - other coc plugins managed by coc below
Plug 'neoclide/coc.nvim', {'branch': 'release'}
for extension in g:coc_extensions
    Plug ''.extension, {'do': 'yarn install --frozen-lockfile'}
endfor

" File Tree
if g:pretty_icons
  Plug 'nvim-tree/nvim-web-devicons'
endif
Plug 'nvim-tree/nvim-tree.lua'

" Editor Config
Plug 'editorconfig/editorconfig-vim'

" Syntax Checking and Highlighting
Plug 'sheerun/vim-polyglot'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Fuzzy finding
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" Inline Git
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'

" Easy editing movements for quotes, parenthesis, etc
Plug 'tpope/vim-surround'

" Global find and replace
Plug 'windwp/nvim-spectre'

" Comment blocks
Plug 'tpope/vim-commentary'

" Multiline Editing
Plug 'mg979/vim-visual-multi'

" Debugger
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'

if g:copilot
  Plug 'github/copilot.vim'
endif

call plug#end()

filetype plugin indent on

" ----- Auto install plugins on launch -----
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif

" ----- General Vim Settings -----
set foldmethod=syntax         
set foldlevelstart=99
set backspace=indent,eol,start
set ruler
set number
set relativenumber
set showcmd
set incsearch
set hlsearch
set ignorecase " Case-insensitive search
set smartcase  " Smart case-insensitive search (requires ignorecase)
" Always show gutter (dont move left to right)
set signcolumn=yes
" Update git and syntax more quickly
set updatetime=250
syntax on

" ----- Theme -----

set t_Co=256
set t_ut=
let g:gruvbox_contrast_dark = 'hard'
silent! execute 'colorscheme ' . g:theme_name
set background=dark

" ----- Lightline -----
" -- INSERT -- no longer needed
set noshowmode
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
      \   'right': [ [ 'lineinfo' ],
		  \              [ 'percent' ],
		  \              [ 'filetype' ] ]
      \ },
      \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
      \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }

" ----- copilot ------
if g:copilot
  " Enable both <C-J> and <C-CR> for accepting suggestions
  " (some terminals don't pass <C-CR> through)
  imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
  imap <silent><script><expr> <C-CR> copilot#Accept("\<CR>")

  " Copilot uses tab for autocompletion which conflicts with CoC
  let g:copilot_no_tab_map = v:true
endif

" ----- nvim-tree -----

nmap <silent> <leader>t :NvimTreeFindFileToggle<CR>

lua << EOF
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

nvimTreeConfig = {
  sort_by = "name",
  git = {
    ignore = false,
  },
  filters = {
    dotfiles = false,
  },
  view = {
    adaptive_size = false,
    mappings = {
      list = {
        { key = "%", action = "vsplit" },
        { key = "\"", action = "split" },
        { key = "<C-e>", action = "" },
      },
    },
  },
  renderer = {
    add_trailing = true,
    full_name = true,
    group_empty = false,
    highlight_git = true,
    highlight_opened_files = "all",
  },
}

if vim.g.i_like_trees == 1 then
  nvimTreeConfig.open_on_setup = true
  nvimTreeConfig.open_on_setup_file = true
  nvimTreeConfig.open_on_tab = true
end

if vim.g.pretty_icons == 0 then
  nvimTreeConfig.renderer.icons = {
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
  }
end

local ok, lib = pcall(require, 'nvim-tree')
if ok then
  lib.setup(nvimTreeConfig)
end

EOF

" Clear gutter bg color
hi clear SignColumn

" ----- DAP -----

lua <<EOF
local ok, dap = pcall(require, 'dap')
if ok then
      dap.adapters.node2 = {
        type = 'executable',
        command = 'node',
        args = {os.getenv('HOME') .. '/dev/microsoft/vscode-node-debug2/out/src/nodeDebug.js'},
      }
      dap.configurations.javascript = {
        {
          name = 'Launch',
          type = 'node2',
          request = 'launch',
          program = '${file}',
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
        },
        {
          -- For this to work you need to make sure the node process is started with the `--inspect` flag.
          name = 'Attach to process',
          type = 'node2',
          request = 'attach',
          processId = require'dap.utils'.pick_process,
        },
      }
      dap.configurations.typescript = {
        {
          name = 'Launch',
          type = 'node2',
          request = 'launch',
          program = '${file}',
          cwd = vim.fn.getcwd(),
          sourceMaps = true,
          protocol = 'inspector',
          console = 'integratedTerminal',
        },
        {
          -- For this to work you need to make sure the node process is started with the `--inspect` flag.
          name = 'Attach to process',
          type = 'node2',
          request = 'attach',
          host = function()
          local value = vim.fn.input "Host [127.0.0.1]: "
          if value ~= "" then
                return value
                end
                return "127.0.0.1"
          end,
          port = function()
                local val = tonumber(vim.fn.input("Port: ", "54321"))
                assert(val, "Please provide a port number")
                return val
          end,
        },
      }
end
EOF

nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
nnoremap <silent> <Leader>b <Cmd>lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <Leader>B <Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <Leader>lp <Cmd>lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
nnoremap <silent> <Leader>dr <Cmd>lua require'dap'.repl.open()<CR>
nnoremap <silent> <Leader>dl <Cmd>lua require'dap'.run_last()<CR>
nnoremap <silent> <Leader>dt <Cmd>lua require'dapui'.toggle()<CR>

" ----- Telescope settings -----
nmap <c-p> :Telescope git_files<cr>
nmap <c-f> :Telescope live_grep<cr>

lua << EOF
local ok, telescope = pcall(require, 'telescope')
if ok then
  telescope.setup{
    defaults = {
      mappings = {
        n = {
          ["<CR>"] = 'select_tab',
        },
        i = {
          ["<CR>"] = 'select_tab',
        },
      },
    },
  }
end
EOF

" ----- CoC settings -----

" Tab completion
inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
inoremap <expr> <Tab> coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"

" Intellisesnse
if g:use_inline_definition_previews
  nmap <silent> gd :PreviewDefinition<CR>
  nmap <silent> gy :PreviewTypeDefinition<CR>
  nmap <silent> <leader>gd <Plug>(coc-definition)
  nmap <silent> <leader>gy <Plug>(coc-type-definition)
else
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> <leader>gd :PreviewDefinition<CR>
  nmap <silent> <leader>gy :PreviewTypeDefinition<CR>
endif
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gi <Plug>(coc-implementation)

" Show documentation (\h)
nnoremap <silent> <leader>h :call ShowDocumentation()<CR>

function! ShowDocumentation()
  call CocActionAsync('doHover')
endfunction

" Rename (\rn)
nmap <leader>rn <Plug>(coc-rename)

" Inline previews (similar to VSCode)
function! OpenPreviewInline(...)
    let fname = a:1
    let call = ''
    if a:0 == 2
        let fname = a:2
        let call = a:1
    endif

    " Create the scratch buffer displayed in the floating window
    let buf = nvim_create_buf(v:false, v:true)

    " Get the current UI
    let ui = nvim_list_uis()[0]

    " Create the floating window
    let opts = {'relative': 'cursor',
                \ 'width': 70,
                \ 'height': 12,
                \ 'col': 0,
                \ 'row': 1,
                \ 'anchor': 'NW',
                \ 'style': 'minimal',
                \ 'border': 'single',
                \ }
    let win = nvim_open_win(buf, 1, opts)

    execute 'edit ' . fname
endfunction
command! -nargs=+ CocOpenPreviewInline :call OpenPreviewInline(<f-args>)

command! -nargs=0 PreviewDefinition :call CocActionAsync('jumpDefinition', 'CocOpenPreviewInline')
command! -nargs=0 PreviewTypeDefinition :call CocActionAsync('jumpTypeDefinition', 'CocOpenPreviewInline')

let g:coc_user_config = {
  \ 'suggest.noselect': 1,
  \ }

" BG for inline previews
"hi Pmenu ctermbg=233 guibg=#1d2021

" ----- Spectre -----

" Global search
nnoremap <leader>S :lua require('spectre').open()<CR>

" Search current word
nnoremap <leader>sw :lua require('spectre').open_visual({select_word=true})<CR>
vnoremap <leader>s :lua require('spectre').open_visual()<CR>
" Search in current file
nnoremap <leader>sp viw:lua require('spectre').open_file_search()<cr>

" ----- Mouse -----

" let g:VM_mouse_mappings = 1
" Doing this manually because CTRL Left click is an osx thing
" So biunding to both left and right mouse
nmap <C-LeftMouse> <LeftMouse>g<Space>
nmap <C-RightMouse> <LeftMouse>g<Space>
imap <C-LeftMouse> <esc><LeftMouse>g<Space>
imap <C-RightMouse> <esc><LeftMouse>g<Space>

" scroll only one line at a time for smoother scrolling
map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>

" ----- Other Settings ----

" Enable vim mouse compat
" http://vim.wikia.com/wiki/Make_mouse_drag_not_select_text_or_go_into_visual_mode
set mouse=a
" Fix mouse selection on long lines
" https://stackoverflow.com/questions/7000960/in-vim-why-doesnt-my-mouse-work-past-the-220th-column
if !has('nvim')
  set ttymouse=sgr
endif

" Fix Copy Paste
" https://stackoverflow.com/questions/17561706/vim-yank-does-not-seem-to-work
if system('uname -s') == "Darwin\n"
  set clipboard=unnamed "OSX
else
  set clipboard=unnamedplus "Linux
endif

" Stop auto comment insertion
" https://superuser.com/questions/271023/can-i-disable-continuation-of-comments-to-the-next-line-in-vim
autocmd BufNewFile,BufRead * setlocal formatoptions-=cro

" Ctrl q to quit
nmap <c-q> :q<cr>
imap <c-q> <esc>:q<cr>a

" Crtl s to save
nmap <c-s> :w<cr>
imap <c-s> <esc>:w<cr>a

" Reselect visual paste after shifting block
" https://vi.stackexchange.com/questions/598/faster-way-to-move-a-block-of-text
xnoremap > >gv
xnoremap < <gv

" Tabs to spaces, and indentation
:set tabstop=2
:set shiftwidth=2
:set expandtab

" Disable swap files for git
set noswapfile

" Change cursor for normal vs insert mode
" https://stackoverflow.com/questions/15217354/how-to-make-cursor-change-in-different-modes-in-vim
autocmd InsertEnter * set cul
autocmd InsertLeave * set nocul

" Automatically write the file
if g:write_on_focusloss
  autocmd FocusLost * nested silent! wall
elseif g:write_on_change
  autocmd TextChanged,TextChangedI <buffer> silent write
endif


" Change Vim Cursor Depending on mode:
" http://vim.wikia.com/wiki/Change_cursor_shape_in_different_modes
let &t_SI = "\<Esc>[4 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

" ----- Move lines vertically -----

nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

