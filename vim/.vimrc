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
"Plugin 'SirVer/ultisnips'
"Plugin 'Valloric/YouCompleteMe'
Plugin 'ap/vim-buftabline'
Plugin 'tikhomirov/vim-glsl'
Plugin 'morhetz/gruvbox'
call vundle#end()            " required

"---------------------------------------------------------------------
" Pathogen and other plugins
execute pathogen#infect()
syntax on " Turn on coloring for syntax

"---------------------------------------------------------------------
" Syntactic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': [],'passive_filetypes': [] }
nnoremap <C-w>E :SyntasticCheck<CR> :SyntasticToggleMode<CR>

function Py2()
  let g:syntastic_python_python_exec = '/usr/local/bin/python2.7'
endfunction

function Py3()
  let g:syntastic_python_python_exec = '/usr/local/bin/python3.7'
endfunction

call Py3()   " default to Py3 because I try to use it when possible

"---------------------------------------------------------------------
" prevent vim from giving a warning it the swp file is open 
set shortmess=A
"set foldmethod=syntax
set cursorline
set encoding=utf8
set ignorecase
set nobackup
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
set virtualedit=onemore

" -----------------------------------------------------------------------------------------
set laststatus=0
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
:nmap <c-Up> -3
:nmap <c-Down> +3 
:vmap <c-Up> -3
:nmap <c-Down> +3 

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
"let g:ycm_global_ycm_extra_conf = '$HOME/config_files/nvim/.ycm_extra_conf.py'
"let g:ycm_auto_trigger = 1
"let g:ycm_min_num_of_chars_for_completion = 3
"let g:ycm_confirm_extra_conf = 0
"let g:ycm_autoclose_preview_window_after_insertion = 1

" -----------------------------------------------------------------------------------------
" other editor settings
set number
set mouse=a
set tabstop=4
set shiftwidth=4
set autoindent
set shiftround
set smarttab "tabs will then only be used for indenting (in the third and fourth lines), while spaces will be used for alignment:
set backspace=indent,eol,start "Make Backspace work on all modes

" setting indent markers-------------------------------------------------------------------
set listchars=tab:\|\ 
set list

" -----------------------------------------------------------------------------------------
" Nerd Tree file manager
let g:NERDTreeWinSize=60 
map <C-f> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeQuitOnOpen=1 " closes upon opening a file in nerdtree
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'


" -----------------------------------------------------------------------------------------
" navigates to the next buffer
:nmap <c-n> :bnext<CR>
:nmap <c-p> :bprev<CR>
:ab Wq :wq
:ab W :w
:ab WQ :wq
:ab Q :q
:set guitablabel=%t  " show only the file name an not the path 
:au FocusLost * :wa  " save when focus is lost (not sure if this is working. Test)

" start the terminal in the given path by typing :t on the minibuffer
:ab t :!urxvt -bg black --geometry 85x47+683+0&\|<CR> 
" -----------------------------------------------------------------------------------------
" press // for comment using nerd commenter
nmap // <leader>c<space>
vmap // <leader>c<space>

" -----------------------------------------------------------------------------------------
" toggling between insert, normal and visual mode upon triple key press
:imap vv <Esc>v
:nmap vv <Esc>v
:imap <c-l> <Esc>la
:nmap <c-l> e
:nmap <c-h> b
:nmap <C-Right> e
:imap <c-x><c-x> <Esc>:update<CR>\|<Esc>:!rxvt-unicode -bg black --geometry 85x47+683+0 -e sh -c "make && make run; bash"&<CR>\|<CR>  
:nmap <c-x><c-x> :update<CR>\|<Esc>:!rxvt-unicode -bg black --geometry 85x47+683+0 -e sh -c "make && make run; bash"&<CR>\|<CR>
":imap <c-x><c-x> <Esc>:update<CR>\|<Esc>:"make && make run"<CR>  
":nmap <c-x><c-x> :update<CR>\|<Esc>:"make && make run"<CR>
" ------------------------------------------------------------------------------
" UltiSnips stuff 
let g:UltiSnipsExpandTrigger = "<nop>"
inoremap <expr> <CR> pumvisible() ? "<C-R>=UltiSnips#ExpandSnippetOrJump()<CR>" : "\<CR>"
let g:UltiSnipsSnippetDirectories = ['/$HOME/config_files/nvim/UltiSnips', 'UltiSnips']
" -------------------------------------------------------------------------------
" latex stuff 
filetype plugin on
filetype indent on
let g:tex_flavor='latex'

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

au BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") && &filetype != "gitcommit" |
        \ execute("normal `\"") |
    \ endif
