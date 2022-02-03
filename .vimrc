" Based on https://github.com/jez/vim-as-an-ide/commit/dff7da3

" Uses Vundle

" Enable most vim settings
set nocompatible

" FZF Git files only
let $FZF_DEFAULT_COMMAND = 'ag -g "" --hidden --ignore .git'

" Force bash as shell (fish/vundle not compatible)
set shell=/bin/bash

" Vundle Setup
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Vundle set up
Plugin 'VundleVim/Vundle.vim'

" Status bar
Plugin 'itchyny/lightline.vim'

" Color Scheme
Plugin 'morhetz/gruvbox'

" File Tree
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'

" Editor Config
Plugin 'editorconfig/editorconfig-vim'

" Syntax Checking and Highlighting
Plugin 'sheerun/vim-polyglot'

" Inline Git
Plugin 'airblade/vim-gitgutter'

" Fuzzy Finding
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'

" NeoVim required for performance
if has('nvim')
  " Autocomplete
  Plugin 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
endif

" Comment blocks
Plugin 'preservim/nerdcommenter'

call vundle#end()

filetype plugin indent on

" General Vim Settings
set backspace=indent,eol,start
set ruler
set number
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

" ----- Plugin Settings -----

" Theme
let g:gruvbox_contrast_dark = 'hard'
colorscheme blackboard
set background=dark
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }

" File tree
" ----- jistr/vim-nerdtree-tabs -----
" Open/close NERDTree Tabs with \t
nmap <silent> <leader>t :NERDTreeTabsToggle<CR>
" To have NERDTree always open on startup
let g:nerdtree_tabs_open_on_console_startup = 1
let NERDTreeShowHidden=1
autocmd VimEnter * call NERDTreeAddKeyMap({ 'key': '<2-LeftMouse>', 'scope': "FileNode", 'callback': "OpenInTab", 'override':1 })
    function! OpenInTab(node)

      call a:node.activate({'reuse': 'all', 'where': 't'})
    endfunction

" Clear gutter bg color
hi clear SignColumn

" ----- Deoplete settings -----
if has('nvim')
  let g:deoplete#enable_at_startup = 1

  " Tab completion
  inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
endif

" ----- fzf settings -----
" fzf new tab
let g:fzf_action = {
      \ 'return': 'tab split', 
      \ 'ctrl-i': 'split',
      \ 'ctrl-s': 'vsplit' }
" Command for git grep
" - fzf#vim#grep(command, with_column, [options], [fullscreen])
command! -bang -nargs=* GGrep
      \ call fzf#vim#grep(
      \   'git grep --line-number '.shellescape(<q-args>), 0,
      \   { 'dir': systemlist('git rev-parse --show-toplevel')[0] }, <bang>0)
" When we need better searching / replacing
" https://thevaluable.dev/vim-search/
" Ctrl p to serch files
nmap <c-p> :Files<cr>
imap <c-p> <esc>:Files<cr>
" Ctrl f to search in project
nmap <c-f> :Ag<cr>
imap <c-f> <esc>:Ag<cr>

" Mouse
" let g:VM_mouse_mappings = 1
" Doing this manually because CTRL Left click is an osx thing
" So biunding to both left and right mouse
nmap <C-LeftMouse> <LeftMouse>g<Space>
nmap <C-RightMouse> <LeftMouse>g<Space>
imap <C-LeftMouse> <esc><LeftMouse>g<Space>
imap <C-RightMouse> <esc><LeftMouse>g<Space>

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

" Change Vim Cursor Depending on mode:
" http://vim.wikia.com/wiki/Change_cursor_shape_in_different_modes
let &t_SI = "\<Esc>[4 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

"Custom Boushi configs
nmap <S-q> :q<cr>
nnoremap w b

"Temporarily disabled settings

" Ctrl q to quit
" nmap <c-q> :q<cr>
" imap <c-q> <esc>:q<cr>a

nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

set foldmethod=syntax         
set foldlevelstart=99
