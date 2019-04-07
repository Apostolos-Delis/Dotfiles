" ------------------------------------------------------------------------
" set theruntime path to include Vundle and initialize
set hidden
set autochdir
set clipboard^=unnamed " This sets the clipboard as the default register. Useful for copy paste from tmux

set nocompatible " This tells vim not to act like it predecessor vi
syntax enable " enables syntax highlighting
filetype plugin indent on    " identify the kind of filetype automatically

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'SirVer/ultisnips'
"Plugin 'honza/vim-snippets'
Plugin 'Valloric/YouCompleteMe'
Plugin 'ap/vim-buftabline'
Plugin 'tikhomirov/vim-glsl'
Plugin 'morhetz/gruvbox'
Plugin 'lervag/vimtex'
Plugin 'vimwiki/vimwiki', { 'branch': 'dev' }
Plugin 'vim-airline/vim-airline'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'nvie/vim-flake8' " Vim Linting
Plugin 'Raimondi/delimitMate' " Complete parenthesis and stuff
Plugin 'ryanoasis/vim-devicons' " Cool icons
" Plugin 'scrooloose/syntastic' "code syntax
call vundle#end()

"---------------------------------------------------------------------
" Airline Stuff (https://vimawesome.com/plugin/vim-airline-superman)

let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#formatter = 'default'
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline_powerline_fonts = 1

"---------------------------------------------------------------------
"Util snips info
let g:UltiSnipsUsePythonVersion = 3

set runtimepath+=~/.vim/UltiSnips
" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.

let g:UltiSnipsExpandTrigger="<CR>"
let g:UltiSnipsJumpForwardTrigger="<c-v>"
let g:UltiSnipsJumpBackwardTrigger="<c-c>"
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips']
" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"---------------------------------------------------------------------
syntax on " Turn on coloring for syntax

"---------------------------------------------------------------------
" prevent vim from giving a warning it the swp file is open
set shortmess=A
set cursorline
set magic " Set magic on, for regex
scriptencoding utf-8
set fileencoding=utf-8
set encoding=utf-8

set ignorecase
set nobackup

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
set virtualedit=onemore

" code folding settings
set foldmethod=syntax " fold based on indent
set foldnestmax=10 " deepest fold is 10 levels
set nofoldenable " don't fold by default
set foldlevel=1


" -----------------------------------------------------------------------------------------
set laststatus=2
" -----------------------------------------------------------------------------------------
" This sets the color scheme
set background=dark
colorscheme gruvbox

" -----------------------------------------------------------------------------------------
" wrapping lines when arrows are pressed
set whichwrap+=<,>,h,l,[,]

" -----------------------------------------------------------------------------------------
" scrolling up and down multiple lines atonce
:nmap <c-j> +3
:vmap <c-j> +3
:nmap <c-k> -3
:vmap <c-k> -3

" -----------------------------------------------------------------------------------------
" Shift between multiple buffers with tab and shift-tab
nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>

" -----------------------------------------------------------------------------------------
" Unbind the cursor keys in insert, normal and visual modes.
for prefix in ['i', 'n', 'v']
 for key in ['<Up>', '<Down>', '<Left>', '<Right>']
   exe prefix . "noremap " . key . " <Nop>"
 endfor
endfor

" -----------------------------------------------------------------------------------------
" autocomplete
let g:ycm_global_ycm_extra_conf = '$HOME/.vim/.ycm_extra_conf.py'
let g:ycm_auto_trigger = 1
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_confirm_extra_conf = 0
let g:ycm_autoclose_preview_window_after_insertion = 1
"Make sure the blacklist is empty
let g:ycm_filetype_blacklist = {}

" -----------------------------------------------------------------------------------------
" other editor settings
set number
set relativenumber
set rnu
set mouse=a
set tabstop=4
set softtabstop=4 " edit as if the tabs are 4 characters wide
set shiftwidth=4
set expandtab
set ttyfast " faster redrawing
set autoindent
set shiftround
set smarttab "tabs will then only be used for indenting (in the third and fourth lines), while spaces will be used for alignment:
set smartindent
set splitbelow "Causes splits to happen in the lower window


set backspace=indent,eol,start "Make Backspace work on all modes
set wildmenu

" setting indent markers-------------------------------------------------------------------
set list          " Display unprintable characters f12 - switches (displays symbol for spaces)
set showbreak=↪\
set listchars=tab:\|\ ,eol:↲,nbsp:␣,trail:•,extends:»,precedes:« " Unprintable chars mapping syntax

" Searching
set ignorecase " case insensitive searching
set smartcase " case-sensitive if expresson contains a capital letter
"set hlsearch
set incsearch " set incremental search, like modern browsers
set nolazyredraw " don't redraw while executing macros


" set a map leader for more key combos
let mapleader = ','

" Edit vimrc
map <leader>ev :e! ~/.vimrc<CR>
" Edit bashrc
map <leader>eb :e! ~/.bashrc<CR>
" Edit snippet file
map <leader>es :UltiSnipsEdit<CR>

" Restart vimrc
map <leader>rs :so ~/.vimrc<CR> "

" Get rid of all trailing whitespace
nnoremap <leader>dw :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" Open terminal
map <leader>t :terminal<CR>
" Open a terminal and then run make
map <leader>mk :terminal<CR>make<CR>
" Open a terminal and then run make and then open the last edited pdf and exit
map <leader>om :terminal<CR>make<CR>open <Up><CR>exit<CR>

" Remap so it quits rather than entering ex mode
nnoremap Q :q<CR>

" -----------------------------------------------------------------------------------------
" Nerd Tree file manager
let g:NERDTreeWinSize=60
map <C-f> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

let NERDTreeQuitOnOpen=1 " closes upon opening a file in nerdtree
let NERDTreeShowHidden=1 " show hidden files in NERDTree
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let NERDTreeNodeDelimiter = "\u263a" " smiley face


" -----------------------------------------------------------------------------------------
:ab Wq :wq
:ab W :w
:ab WQ :wq
:ab Q :q
:set guitablabel=%t  " show only the file name an not the path
:au FocusLost * :wa  " save when focus is lost (not sure if this is working. Test)

" -----------------------------------------------------------------------------------------
" press // for comment using nerd commenter
nmap // <leader>c<space>
vmap // <leader>c<space>

" UltiSnips stuff
let g:UltiSnipsExpandTrigger = "<nop>"
inoremap <expr> <CR> pumvisible() ? "<C-R>=UltiSnips#ExpandSnippetOrJump()<CR>" : "\<CR>"
let g:UltiSnipsSnippetDirectories = ['/$HOME/config_files/nvim/UltiSnips', 'UltiSnips']
" -------------------------------------------------------------------------------
" latex stuff
filetype plugin on
let g:tex_flavor='latex'
" Compile latex file using latexmk with control T
autocmd FileType tex nmap <buffer> <C-T> :!latexmk -pdf %<CR>

" -------------------------------------------------------------------------------
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
"---------------------------------------------------------------------
" If Iterm2 is open, let the cursor be a block in normal mode and a line in insert
" Reference:
" https://stackoverflow.com/questions/16137623/setting-the-cursor-to-a-vertical-thin-line-in-vim

if $TERM_PROGRAM =~ "iTerm"
    let &t_SI = "\<Esc>]50;CursorShape=1\x7" " Vertical bar in insert mode
    let &t_EI = "\<Esc>]50;CursorShape=1\x7" " Vertical bar in normal mode
    "let &t_EI = "\<Esc>]50;CursorShape=0\x7" " Block in normal mode
endif


au BufReadPost *
   \ if line("'\"") > 0 && line("'\"") <= line("$") && &filetype != "gitcommit" |
       \ execute("normal `\"") |
   \ endif

autocmd BufWritePost *.py call flake8#Flake8()

" Add support for PEP 8 file formatting
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix
