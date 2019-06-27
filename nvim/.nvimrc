""" Vim-Plug
call plug#begin()
" Aesthetics - Main
Plug 'morhetz/gruvbox' " Adds gruvbox theme
Plug 'altercation/vim-colors-solarized'
Plug 'dracula/vim', { 'commit': '147f389f4275cec4ef43ebc25e2011c57b45cc00' }
Plug 'vim-airline/vim-airline'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/seoul256.vim'
Plug 'zaki/zazen'

" Aethetics - Additional
"Plug 'nightsense/nemo'
Plug 'yuttie/hydrangea-vim'
Plug 'chriskempson/tomorrow-theme', { 'rtp': 'vim' }
Plug 'rhysd/vim-color-spring-night'
Plug 'ap/vim-buftabline' " To show the tabs at the top of vim

" Functionalities
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
"Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clangd-completer --java-completer --ts-completer' }
" Adds LateX functionality
"Plug 'lervag/vimtex'
Plug 'christoomey/vim-tmux-navigator'

"Plug 'zchee/deoplete-jedi'
"Plug 'ervandew/supertab'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/vim-easy-align'
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-abolish'
"Plug 'Yggdroot/indentLine'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'sheerun/vim-polyglot'
Plug 'chrisbra/Colorizer'
Plug 'heavenshell/vim-pydocstring'
Plug 'vim-scripts/loremipsum'
Plug 'metakirby5/codi.vim'
Plug 'dkarter/bullets.vim'
Plug 'w0rp/ale'
Plug 'SirVer/ultisnips'
"Plug 'honza/vim-snippets'

" Entertainment
"Plug 'ryanss/vim-hackernews'

call plug#end()

""" Python3 VirtualEnv
let g:python3_host_prog = expand('~/.config/nvim/env/bin/python')

""" Coloring
syntax enable
set background=dark
let g:gruvbox_termcolors=16
let g:gruvbox_italic=1
color gruvbox
highlight Pmenu guibg=white guifg=black gui=bold
highlight Comment gui=bold
highlight Normal gui=none
highlight NonText guibg=none
:set guitablabel=%t  " show only the file name an not the path

" Opaque Background (Comment out to use terminal's profile)
set termguicolors

" Transparent Background (For i3 and compton)
highlight Normal guibg=NONE ctermbg=NONE
highlight LineNr guibg=NONE ctermbg=NONE

""" Other Configurations
filetype plugin indent on
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab autoindent
set incsearch ignorecase smartcase hlsearch
set ruler laststatus=2 showcmd showmode
" wrapping lines when arrows are pressed
set whichwrap+=<,>,h,l,[,]
" Unprintable chars mapping syntax
set list listchars=tab:▶\ ,eol:↲,nbsp:␣,trail:~,extends:»,precedes:«
set fillchars+=vert:\
set wrap breakindent
set encoding=utf-8
set title
set number
set relativenumber
set rnu
set mouse=a
set scrolloff=10
set fillchars+=vert:\ " Changing the styling of vertical borders for windows

" Searching
set ignorecase " case insensitive searching
set smartcase " case-sensitive if expresson contains a capital letter
set hlsearch
set incsearch " set incremental search, like modern browsers
"set nolazyredraw " don't redraw while executing macros
set ttyfast
set lazyredraw
set softtabstop=4
set nopaste


"Cursor

"changes cursor color between insert mode and normal mode
if &term =~ "xterm\\|urxvt"
 " use an orange cursor in insert mode
 let &t_SI = "\<Esc>]12;green\x7"
 " use a red cursor otherwise
 let &t_EI = "\<Esc>]12;red\x7"
 silent !echo -ne "\033]12;red\007"
 " reset cursor when vim exits
 autocmd VimLeave * silent !echo -ne "\033]112\007"
 " use \003]12;gray\007 for gnome-terminal and urxvt up to version 9.21
endif


set guicursor=n-v-sm:block,c-i-ci-ve:ver25-Cursor,r-cr-o:hor20
if $TERM_PROGRAM =~ "iTerm"
    let &t_SI = "\<Esc>]50;CursorShape=1\x7" " Vertical bar in insert mode
    let &t_EI = "\<Esc>]50;CursorShape=1\x7" " Vertical bar in normal mode
    "let &t_EI = "\<Esc>]50;CursorShape=0\x7" " Block in normal mode
endif

if exists('$TMUX')
  let &t_SI = "\ePtmux;\e\e[5 q\e\\"
  let &t_EI = "\ePtmux;\e\e[2 q\e\\"
else
  let &t_SI = "\e[5 q"
  let &t_EI = "\e[2 q"
endif

" Added this for pasting in tmux
" Reference: https://coderwall.com/p/if9mda/automatically-set-paste-mode-in-vim-when-pasting-in-insert-mode
function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif

  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"

  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction

let &t_SI .= WrapForTmux("\<Esc>[?2004h")
let &t_EI .= WrapForTmux("\<Esc>[?2004l")

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

""" Bindings

" scrolling
:nnoremap k gk
:nnoremap j gj


" Absolute conversions for when mistyping :wq
:ab Wq :wq
:ab W :w
:ab WQ :wq
:ab Q :q

let mapleader = ','

" set a map leader for more key combos
map <Leader> <Plug>(easymotion-prefix)

" Clear search highlight
nnoremap <leader><leader> :noh<CR>

" Edit vimrc
nnoremap <leader>ev :e! ~/.vimrc<CR>
" Edit bashrc
nnoremap <leader>eb :e! ~/.bashrc<CR>
" Edit zshrc
nnoremap <leader>ez :e! ~/.zshrc<CR>
" Edit aliases
nnoremap <leader>ea :e! ~/.aliases<CR>
" Edit tmux config
nnoremap <leader>et :e! ~/.tmux.conf<CR>
" Edit init.vim
nnoremap <leader>ei :e! +200 ~/.config/nvim/init.vim<CR>
" Edit snippet file
nnoremap <leader>es :UltiSnipsEdit<CR>
" Edit file
nnoremap <leader>ed :edit
" Edit file in new window
nnoremap <leader>ew :vert new

" Restart nvimrc
nnoremap <leader>rs :so ~/.config/nvim/init.vim<CR>:noh<CR>
"
" Set nopaste
nnoremap <leader>sp :set nopaste<CR>:%s/<Paste>//g<CR>
" Toggle Spell check
set spelllang=en
nnoremap <leader>st :setlocal spell!<CR>
inoremap <C-T> <c-g>u<Esc>[s1z=`]a<c-g>u
" Toggle list
nnoremap <leader>ts :set list!<CR>
" Toggle Tags
nmap <leader>tt :TagbarToggle<CR>
" Toggle Rainbow Parentheses
nnoremap <leader>tr :RainbowParentheses!!<CR>
" Toggle ALE
nnoremap <leader>ta :ALEToggle<CR>

" Get rid of all trailing whitespace
nnoremap <leader>dw :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>:noh<CR>
" Remove trailing lines
nnoremap <leader>ds :%s#\($\n\s*\)\+\%$##<CR>:noh<CR>

" Open a terminal and then run make
nnoremap <leader>mk :make<CR>

" Open a terminal and then make test and then open the last edited pdf and exit
nnoremap <leader>mo :make<CR>:!!CR>
" Open a terminal and run make and make test
nnoremap <leader>mt :make<CR>:make test<CR>

" Fuzzy Find files in the current directory
nnoremap <leader>fd :Files<CR>

" Fussy Find files in the git repo
nnoremap <leader>gd :GFiles<CR>

" Toggle Limelight on and off
nmap <leader>ll :Limelight!!<CR>
xmap <leader>ll :Limelight!!<CR>

" Apply Pydocstring
nmap <leader>ps <Plug>(pydocstring)

nmap <leader>a gaip*

" Remap so it quits rather than entering ex mode
nnoremap Q :q<CR>

" Highlight non-ascii characters
nnoremap <leader>hn /[^\x00-\x7F]<CR>

" Converts the current line to Title Case
" Reference: https://vim.fandom.com/wiki/Switching_case_of_characters
"nnoremap <leader>rc :s#\v(\w)(\S*)#\u\1\L\2#g<CR>:s/\<\(\w\)\(\w*\)\>/\u\1\L\2/g<CR>:noh<CR>
nnoremap <leader>rc :s/\<\(\w\)\(\w*\)\>/\u\1\L\2/g<CR>:noh<CR>

" Replaces all tabs to 4 spaces
nnoremap <leader>rt :%s/\t/    /g<CR>:noh<CR>

"" ---------------------------------------------------------------------------- "
" Windows
set splitbelow
set splitright

nnoremap <leader>wv :vnew<CR>
"nnoremap <leader>wv :vsplit<CR>

nnoremap <leader>ws :new<CR>
nnoremap <leader>cw :bd!<CR>

""nnoremap <C-J> <C-W><C-J>
""nnoremap <C-K> <C-W><C-K>
""nnoremap <C-L> <C-W><C-L>
""nnoremap <C-H> <C-W><C-H>

" This causes esc to resize if there is more than one window so :(
"nnoremap + <C-w>+
"nnoremap - <C-w>-
"nnoremap = <C-w>=
"nnoremap <C-]> <C-W>>
"nnoremap <C-[> <C-W><

" Tmux with windows
let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <C-H> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-J> :TmuxNavigateDown<cr>
nnoremap <silent> <C-K> :TmuxNavigateUp<cr>
nnoremap <silent> <C-L> :TmuxNavigateRight<cr>
nnoremap <silent> <C-/> :TmuxNavigatePrevious<cr>

""" Plugin Configurations

" Vimtex
let g:tex_flavor='latex'
let g:vimtex_compiler_progname = 'nvr'
let g:tex_flavor='latex'
let g:vimtex_view_method='skim'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'


 "Compile latex file using latexmk with control T
"autocmd FileType tex nmap <buffer> <C-T> :!latexmk -pdf %<CR>

" Ale Lint
let g:ale_set_highlights = 0
let g:ale_change_sign_column_color = 0
let g:ale_sign_column_always = 0
let g:ale_fix_on_save = 1
let g:ale_lint_delay = 1000
let g:ale_lint_on_text_changed = 'always'
let g:ale_sign_error = '✖'
let g:ale_sign_warning = '⚠'
let g:ale_echo_msg_error_str = '✖'


" NERDTree
let g:NERDTreeWinSize=35
map <C-f> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let NERDTreeQuitOnOpen=1 " closes upon opening a file in nerdtree
let NERDTreeShowHidden=1 " show hidden files in NERDTree
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let NERDTreeNodeDelimiaer = "\u263a" " smiley face

" Airline
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#left_alt_sep = '|'
"let g:airline_section_z = ' %{strftime("%-I:%M %p")}'
let g:airline_powerline_fonts = 1
let g:airline_theme='gruvbox'


" Bullets.vim
let g:bullets_enabled_file_types = [
    \ 'text',
    \ 'gitcommit',
    \ 'scratch'
    \]

" Neovim :Terminal
autocmd BufWinEnter,WinEnter term://* startinsert
autocmd BufLeave term://* stopinsert

" Buftabline
" Shift between multiple buffers with tab and shift-tab
nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>

" Ultisnips
let g:UltiSnipsUsePythonVersion = 3

set runtimepath+=~/.vim/UltiSnips
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<CR>"
let g:UltiSnipsJumpForwardTrigger="<c-e>"
let g:UltiSnipsJumpBackwardTrigger="<c-q>"
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips']

" If you want :UltiSnipsEdit to split your indow.
let g:UltiSnipsExpandTrigger="<nop>"
let g:UltiSnipsEditSplit="vertical"


inoremap <expr> <CR> pumvisible() ? "<C-R>=UltiSnips#ExpandSnippetOrJump()<CR>" : "\<CR>"


" YouCompleteMe
let g:ycm_global_ycm_extra_conf = '$HOME/.vim/.ycm_extra_conf.py'
let g:ycm_auto_trigger = 1
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_confirm_extra_conf = 0
let g:ycm_autoclose_preview_window_after_insertion = 1
"let g:ycm_always_populate_location_list = 1 " C-w doesn't work with this on

" Turn off syntax check
let g:ycm_show_diagnostics_ui = 1
let g:ycm_enable_diagnostic_signs = 0
let g:ycm_enable_diagnostic_highlighting = 0

"Make sure the blacklist is empty
let g:ycm_filetype_blacklist = {}


" EasyAlign
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" indentLine
let g:indentLine_char = '▏'
let g:indentLine_color_gui = '#363949'

" TagBar
let g:tagbar_width = 30
let g:tagbar_iconchars = ['↠', '↡']

" NERDCommenter
" press // for comment using nerd commenter
nmap // <leader>c<space>
vmap // <leader>c<space>

" Rainbow Parentheses
let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['black',       'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]
let g:rbpt_max = 16
let g:rbpt_loadcmd_toggle = 0


" fzf-vim
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'Type'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Character'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

set ttimeout
set ttimeoutlen=0

""" Filetype-Specific Configurations

" Add support for PEP 8 file formatting
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix |
    \ set cc=80

autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
autocmd FileType python nmap <leader>pt :0,$!~/.config/nvim/env/bin/python -m yapf<CR>
autocmd FileType python noremap <leader>fb :!black -q --line-length 79 %<CR>


" HTML, XML, Jinja
autocmd FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType css setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType xml setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType htmldjango setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType htmldjango inoremap {{ {{  }}<left><left><left>
autocmd FileType htmldjango inoremap {% {%  %}<left><left><left>
autocmd FileType htmldjango inoremap {# {#  #}<left><left><left>

" Markdown
autocmd FileType markdown setlocal textwidth=89 autoindent expandtab

" Latex
autocmd FileType tex setlocal textwidth=89 autoindent expandtab

" Coloring
let g:gruvbox_termcolors=16
let g:gruvbox_italic=1
set background=dark
color gruvbox
