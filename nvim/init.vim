" Neovim Config of Apostolos Delis
" Reference: https://github.com/Apostolos-Delis/dotfiles
" ---------------------------------------------------------------------------- "
" Vim-Plug
call plug#begin()
" Aesthetics - Main

Plug 'joshdick/onedark.vim'
Plug 'morhetz/gruvbox' " Adds gruvbox theme
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'itchyny/lightline.vim'
"Plug 'ryanoasis/vim-devicons'
"Plug 'ap/vim-buftabline' " To show the tabs at the top of vim
Plug 'sheerun/vim-polyglot'
"
"" Functionalities
"Plug 'tpope/vim-fugitive'
"Plug 'tpope/vim-sensible'
"Plug 'tpope/vim-surround'
"Plug 'easymotion/vim-easymotion'
"Plug 'majutsushi/tagbar'
"Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'scrooloose/nerdcommenter'
""Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"
Plug 'codota/tabnine-vim'
"" Adds LateX functionality
""Plug 'lervag/vimtex'
Plug 'christoomey/vim-tmux-navigator'
Plug 'mhinz/vim-startify'
"
""Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
"Plug 'kovisoft/paredit', { 'for': ['clojure', 'scheme'] }
"
""Plug 'zchee/deoplete-jedi'
""Plug 'ervandew/supertab'
"Plug 'jiangmiao/auto-pairs'
"Plug 'junegunn/vim-easy-align'
"Plug 'alvan/vim-closetag'
"Plug 'tpope/vim-abolish'
""Plug 'Yggdroot/indentLine'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
"
"Plug 'chrisbra/Colorizer'
"Plug 'vim-scripts/loremipsum'
"Plug 'metakirby5/codi.vim'
"Plug 'dkarter/bullets.vim'
Plug 'dense-analysis/ale'
Plug 'SirVer/ultisnips'
"Plug 'honza/vim-snippets'
call plug#end()


" ---------------------------------------------------------------------------- "
" Other General Configurations
"
" Python3 VirtualEnv
let g:python3_host_prog = expand('/usr/local/bin/python3')

" Enable filetype plugins (Default=True for Neovim)
filetype plugin indent on

set ruler
set laststatus=2
set showmode                        " If in I, R or V mode put a message on the last line.
set clipboard^=unnamed
" wrapping lines when arrows are pressed
set whichwrap+=<,>,h,l,[,]
set history=2000
set timeout ttimeout
set cmdheight=1                     " Height of the command line
set timeoutlen=500                  " How long for Commands/Macros before timeout
set ttimeoutlen=10
set updatetime=100                  " Default is 4000, can lead to delays
set undofile
set undodir=~/.tmp/undo
set backspace=indent,eol,start      " Make more versetile backspace
set guitablabel=%t                  " show only the file name an not the path
set showcmd                         " Show the command run on bottom line of screen
set nocursorline                    " Get rid of Cursorline
set hidden                          " Deals with hiding unsaved buffers
set lazyredraw                      " Dont redraw for macros
set shortmess=aFc                   " Shorten 'Press Enter to Continue'
set signcolumn=yes                  " Set signcolumn to be the number column
set completefunc=emoji#complete
set completeopt=longest,menu        " Related to autocomplete display
set completeopt-=preview
set autoread                        " Read a file again if it is changed elsewhere
set list                            " Make whitespace visible
set listchars=tab:»·,eol:↲,nbsp:␣,trail:·,extends:→,precedes:←
set wrap                            " Wrap lines
set breakindent                     " Every wrapped line continues visually indented
set encoding=utf-8                  " UTF-8 encoding
set title                           " Title of window set to value of titlestring
set number                          " Enable Numbers
set relativenumber                  " Add Relative Numbers
set mouse=a                         " Enable Mouse
set scrolloff=10                    " Keep the scroll 10 below/above cursor
set fillchars+=vert:\               " Changing the styling of vertical borders for windows
set nopaste
set rtp+=/usr/local/opt/fzf         " To use fzf

" Gaster loading, since I don't use GUI
let did_install_default_menus = 1
let did_install_syntax_menu = 1

" ---------------------------------------------------------------------------- "
" Searching
set ignorecase      " Ignore case
set smartcase       " Keep case when searching with a capital letter
set infercase       " Adjust case in insert completion mode
set incsearch       " Incremental search
set hlsearch        " Highlight search results
set wrapscan        " Searches wrap around the end of the file
set showmatch       " Jump to matching bracket
set cindent
set matchpairs+=<:> " Add HTML brackets to pair matching
set matchtime=1     " Tenths of a second to show the matching paren
set cpoptions-=m    " showmatch will wait 0.5s or until a char is typed
set grepprg=rg\ --vimgrep\ $*
set wildignore+=*.so,*~,*/.git/*,*/.svn/*,*/.DS_Store,*/tmp/*

" ---------------------------------------------------------------------------- "
" Text Editing Settings
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smarttab
set autoindent

" ---------------------------------------------------------------------------- "
" Filetype Specific Config

" ---------------------------------------------------------------------------- "
" Bindings

" scrolling
:nnoremap k gk
:nnoremap j gj

" Absolute conversions for when mistyping :wq
:ab Wq :wq
:ab W :w
:ab WQ :wq
:ab Q :q

" Remap so it quits rather than entering ex mode
nnoremap Q :q<CR>

" Yank to end of the line
nnoremap Y y$

" enable . command in visual mode
vnoremap . :normal .<cr>

" set a map leader for more key combos
let mapleader = ','

"map <Leader> <Plug>(easymotion-prefix)

" clear highlighted search
noremap <space> :set hlsearch! hlsearch?<cr>

" Toggle Spell check set spelllang=en
nnoremap <leader>sp :setlocal spell!<CR>
" Fix Spelling of previous word
inoremap <C-T> <c-g>u<Esc>[s1z=`]a<c-g>u

nnoremap <leader>st :Startify<cr>

" Restart nvimrc
nnoremap <leader>rs :source $MYVIMRC<CR>:noh<CR>

" ---------------------------------------------------------------------------- "
" Edit-related bindings

" Edit vimrc
nnoremap <leader>ev :e! ~/.vimrc<CR>
" Edit gitconfig
nnoremap <leader>eg :e! ~/.gitconfig<CR>
" Edit bashrc
nnoremap <leader>eb :e! ~/.bashrc<CR>
" Edit zshrc
nnoremap <leader>ez :e! ~/.zshrc<CR>
" Edit aliases
nnoremap <leader>ea :e! ~/.aliases<CR>
" Edit tmux config
nnoremap <leader>et :e! ~/.tmux.conf<CR>
" Edit TabNine config
" Edit init.vim
nnoremap <leader>ei :e! +230 ~/.config/nvim/init.vim<CR>
" Edit Notes
nnoremap <leader>en :e! +230 ~/Documents/notes<CR>
" Edit snippet file
nnoremap <leader>es :UltiSnipsEdit<CR>
" Edit file
nnoremap <leader>ed :edit

" ---------------------------------------------------------------------------- "
" Toggle Bindings

" Toggle list
nnoremap <leader>ts :set list!<CR>
" Toggle Tags
nmap <leader>tt :TagbarToggle<CR>
" Toggle Rainbow Parentheses
nnoremap <leader>tr :RainbowParentheses!!<CR>
" Toggle ALE
nnoremap <leader>ta :ALEToggle<CR>
" Toggle  between current and last buffer
nnoremap <leader>tb <c-^>

" ---------------------------------------------------------------------------- "
" Delete Related Bindings
"
" Get rid of all trailing whitespace
nnoremap <leader>dw :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>:noh<CR>
" Remove trailing lines
nnoremap <leader>ds :%s#\($\n\s*\)\+\%$##<CR>:noh<CR>

" ---------------------------------------------------------------------------- "
" Make related bindings

" Open a terminal and then run make
nnoremap <leader>mk :make<CR>
" Open a terminal and then make test and then open the last edited pdf and exit
nnoremap <leader>mo :make<CR>:!!CR>
" Open a terminal and run make and make test
nnoremap <leader>mt :make<CR>:make test<CR>

" ---------------------------------------------------------------------------- "
" Git Bindings for Fugitive
nnoremap <silent> <leader>gs :Gstatus<cr>
nnoremap <leader>ge :Gedit<cr>
nnoremap <silent><leader>gr :Gread<cr>
nnoremap <silent><leader>gb :Gblame<cr>

" Git Grep
nnoremap <leader>gg :GGrep<CR>
" Reference: fzf documentation
command! -bang -nargs=* GGrep
  \ call fzf#vim#grep(
  \   'git grep --line-number -- '.shellescape(<q-args>), 0,
  \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

" ---------------------------------------------------------------------------- "
" Fuzzy find Bindings

" Find files in the current directory
nnoremap <leader>ff :Files<CR>
" Find files in the git repo
nnoremap <leader>fg :GFiles<CR>
" Find modified files in git repo
nnoremap <leader>fm :GFiles?<CR>
" Find Snippets
nnoremap <leader>fs :Snippets<CR>
" Find buffers
nnoremap <leader>fb :Buffers<CR>
"Find Lines in Open buffers
nnoremap <leader>fl :Lines<CR>
" Find Tags
nnoremap <leader>ft :Tags<CR>
" Find History
nnoremap <leader>fh :History<CR>
" Find Commits
nnoremap <leader>fc :Commits<CR>
" Find Maps
nnoremap <leader>fm :Maps<CR>

" ---------------------------------------------------------------------------- "
" Navitagion Bindings
nmap <silent> <leader>ne <Plug>(ale_previous_wrap)
nmap <silent> <leader>nE <Plug>(ale_next_wrap)

" ---------------------------------------------------------------------------- "
" Highlight Bindings

" Highlight non-ascii characters
nnoremap <leader>hn /[^\x00-\x7F]<CR>

" ---------------------------------------------------------------------------- "
" Replace Bindings

" Converts the current line to Title Case
" Reference: https://vim.fandom.com/wiki/Switching_case_of_characters
nnoremap <leader>rc :s/\<\(\w\)\(\w*\)\>/\u\1\L\2/g<CR>:noh<CR>

" Replaces all tabs to 4 spaces
nnoremap <leader>rt :%s/\t/    /g<CR>:noh<CR>

" ---------------------------------------------------------------------------- "
" Buffers and Windows

" Shift between multiple buffers with tab and shift-tab
nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>

set splitbelow
set splitright

nnoremap <leader>wv :vnew<CR>
nnoremap <leader>ws :new<CR>

" Delete a buffer without saving
nnoremap <leader>bd :bd!<CR>

" ---------------------------------------------------------------------------- "
" Coloring/Theme

syntax enable
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set background=dark

" Enable true colors if supported
if (has("termguicolors"))
    if (!(has("nvim")))
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    endif
    set termguicolors
endif

" Gruvbox
let g:gruvbox_termcolors=256
let g:gruvbox_italic=1
let g:gruvbox_improved_warnings=1
" colorscheme gruvbox
colorscheme onedark

let g:airline_theme='gruvbox'
let g:airline_theme='onedark'

" ---------------------------------------------------------------------------- "
" Tmux (including tmux-vim-navigator)

" Tmux vim navigator
let g:tmux_navigator_no_mappings = 1
let g:tmux_navigator_disable_when_zoomed = 1

nnoremap <silent> <C-H> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-J> :TmuxNavigateDown<cr>
nnoremap <silent> <C-K> :TmuxNavigateUp<cr>
nnoremap <silent> <C-L> :TmuxNavigateRight<cr>
nnoremap <silent> <C-/> :TmuxNavigatePrevious<cr>

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

" ---------------------------------------------------------------------------- "
" NERDCommenter

" press // for comment using nerd commenter
nmap // <plug>NERDCommenterToggle
vmap // <plug>NERDCommenterToggle

" Do not add default mappings
let g:NERDCreateDefaultMappings = 0
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
" Enable NERDCommenterToggle to check all selected lines is commented or not
let g:NERDToggleCheckAllLines = 1

" ---------------------------------------------------------------------------- "
" Vim Ale

let g:ale_linters = {
    \ 'python3': ['flake8'],
    \ 'javascript': ['prettier', 'eslint'],
    \ 'typescript': ['prettier', 'eslint'],
    \ 'typescriptreact': ['prettier', 'eslint'],
    \ 'ruby': ['rubocop'],
    \ }

let g:ale_fix_on_save = 1
let g:ale_sign_error = '✖'
let g:ale_sign_warning = '⚠'
let g:ale_sign_info = 'ℹ'

" Python
let g:ale_python_flake8_options = '--max-line-length=80'

let g:ale_fixers = {
    \ '*': ['remove_trailing_lines', 'trim_whitespace'],
    \ 'css': [ 'prettier' ],
    \ 'html': [ 'prettier' ],
    \ 'javascript': [ 'prettier' ],
    \ 'typescript': [ 'prettier' ],
    \ 'typescriptreact': [ 'prettier' ],
    \ 'json': [ 'prettier', ],
    \ 'markdown': [ 'prettier', 'textlint' ],
    \ 'python': [ 'autopep8', 'isort' ],
    \ 'ruby': [ 'rubocop' ],
    \ }

" ---------------------------------------------------------------------------- "
" Airline / Airline-Themes

let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1"
let g:airline#extensions#tabline#formatter = 'unique_tail'

" ---------------------------------------------------------------------------- "
" Startify

" Don't change to directory when selecting a file
let g:startify_change_to_dir = 0    " When opening a file/bookmark, change to its directory
let g:startify_custom_header = []   " Get rid of cow quote at the top
let g:startify_relative_path = 1
let g:startify_use_env = 1

let g:startify_commands = [
\   { 'uc': [ 'Clean Plugins', ':PlugClean' ] },
\   { 'up': [ 'Update Plugins', ':PlugUpdate' ] },
\   { 'ug': [ 'Upgrade Plugin Manager', ':PlugUpgrade' ] },
\ ]

let g:startify_bookmarks = [
    \ { 'c': '~/.config/nvim/init.vim' },
    \ { 'g': '~/.gitconfig' },
    \ { 'z': '~/.zshrc' }
\ ]

autocmd User Startified setlocal cursorline

" ---------------------------------------------------------------------------- "
" UltiSnips

" set runtimepath+=~/.vim/UltiSnips
let g:UltiSnipsExpandTrigger="<nop>"
let g:UltiSnipsJumpForwardTrigger="<c-e>"
let g:UltiSnipsJumpBackwardTrigger="<c-q>"
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips']
let g:UltiSnipsUsePythonVersion = 3

" If you want :UltiSnipsEdit to split your indow.
let g:UltiSnipsEditSplit="vertical"

" Need this to actually trigger snippets
inoremap <expr> <CR> pumvisible() ? "<C-R>=UltiSnips#ExpandSnippetOrJump()<CR>" : "\<CR>"
