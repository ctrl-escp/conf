call plug#begin('~/.vim/plugs')
    " ====================================================================
    " Modern LSP & Autocomplete (replaces older completion systems)
    " ====================================================================
    Plug 'neoclide/coc.nvim', {'branch': 'release'}  " Modern LSP client with intellisense
    
    " ====================================================================
    " Language Support & Syntax (modern replacements)
    " ====================================================================
    Plug 'pangloss/vim-javascript'                    " Keep - still excellent for JS
    Plug 'leafgarland/typescript-vim'                 " TypeScript support for Node.js
    Plug 'maxmellon/vim-jsx-pretty'                   " Modern JSX support
    Plug 'vim-python/python-syntax'                   " Enhanced Python syntax
    Plug 'Vimjas/vim-python-pep8-indent'             " Better Python indentation
    Plug 'vim-scripts/bash-support.vim'               " Enhanced shell scripting support
    
    " ====================================================================
    " File Management & Navigation (modern alternatives)
    " ====================================================================
    Plug 'preservim/nerdtree'                        " Updated NERDTree (maintained fork)
    Plug 'Xuyuanp/nerdtree-git-plugin'               " Git integration for NERDTree
    Plug 'ryanoasis/vim-devicons'                     " File icons (requires nerd fonts)
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }  " Fuzzy finder integration
    Plug 'junegunn/fzf.vim'                          " FZF vim integration
    
    " ====================================================================
    " Editing & Productivity (modern replacements)
    " ====================================================================
    Plug 'tpope/vim-commentary'                      " Modern commenting (replaces nerdcommenter)
    Plug 'jiangmiao/auto-pairs'                      " Keep - still excellent
    Plug 'easymotion/vim-easymotion'                 " Keep - still excellent
    Plug 'tpope/vim-surround'                        " Surround text objects
    Plug 'wellle/targets.vim'                        " Additional text objects
    
    " ====================================================================
    " UI & Appearance (modern alternatives)
    " ====================================================================
    Plug 'vim-airline/vim-airline'                   " Modern statusline (replaces powerline)
    Plug 'vim-airline/vim-airline-themes'            " Airline themes
    
    " ====================================================================
    " Code Quality & Formatting (enhanced)
    " ====================================================================
    Plug 'dense-analysis/ale'                        " Updated ALE (maintained fork)
    Plug 'prettier/vim-prettier', {'do': 'npm install', 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html']}
    
    " ====================================================================
    " Git Integration
    " ====================================================================
    Plug 'tpope/vim-fugitive'                        " Comprehensive git integration
    Plug 'airblade/vim-gitgutter'                    " Git diff in gutter
    
    " ====================================================================
    " Utilities
    " ====================================================================
    Plug 'christianrondeau/vim-base64'               " Keep - useful utility
    Plug 'editorconfig/editorconfig-vim'             " EditorConfig support
call plug#end()

" ====================================================================
" Plugin Settings & Configuration
" ====================================================================

" Airline (replaces powerline)
set laststatus=2
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#ale#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme = 'dark'

" Prettier settings
let g:prettier#autoformat = 0   " Disable beautify on save
let g:prettier#autoformat_require_pragma = 0
nmap <Leader>py <Plug>(Prettier)

" CoC.nvim settings for LSP and autocomplete
let g:coc_global_extensions = [
  \ 'coc-python',
  \ 'coc-tsserver',
  \ 'coc-json',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-yaml',
  \ 'coc-sh',
  \ 'coc-prettier',
  \ 'coc-eslint'
  \ ]

" CoC completion settings
set hidden
set updatetime=300
set shortmess+=c
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" Make <CR> to accept selected completion item or notify coc.nvim to format
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" FZF settings
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>rg :Rg<CR>
nnoremap <leader>t :Tags<CR>

" NERDTree settings
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>nf :NERDTreeFind<CR>
let g:NERDTreeShowHidden = 1
let g:NERDTreeIgnore = ['\.pyc$', '\.pyo$', '\.rbc$', '\.rbo$', '\.class$', '\.o$', '\~$', '__pycache__']

" ALE settings (enhanced)
let g:ale_linters = {
\   'python': ['flake8', 'pylint', 'mypy'],
\   'javascript': ['eslint'],
\   'typescript': ['eslint', 'tslint'],
\   'sh': ['shellcheck'],
\   'bash': ['shellcheck'],
\   'zsh': ['shellcheck'],
\}
let g:ale_fixers = {
\   'python': ['black', 'isort'],
\   'javascript': ['prettier', 'eslint'],
\   'typescript': ['prettier', 'eslint'],
\   'json': ['prettier'],
\   'css': ['prettier'],
\   'html': ['prettier'],
\}
let g:ale_fix_on_save = 1
let g:ale_completion_enabled = 0  " Use CoC for completion
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1

" Python syntax settings
let g:python_highlight_all = 1

" Commentary settings (replaces nerdcommenter)
" Uses 'gc' for commenting, 'gcc' for current line

" ====================================================================
" Language-Specific Settings
" ====================================================================

" Python settings
autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd FileType python setlocal textwidth=88  " Black formatter default
autocmd FileType python setlocal colorcolumn=89

" JavaScript/TypeScript settings
autocmd FileType javascript,typescript,json setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType javascript,typescript setlocal colorcolumn=100

" Shell script settings
autocmd FileType sh,bash,zsh setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType sh,bash,zsh setlocal colorcolumn=80

" ====================================================================
" General Vim Settings
" ====================================================================

filetype off
filetype plugin indent on
syntax on
set encoding=utf-8
set pastetoggle=<F2>    " Better copy & paste
set mouse=a             " Enable mouse on visual mode
set bs=2                " Fix backspace
set number              " Show line numbers
set relativenumber      " Show relative line numbers
set autoread            " Auto-reload files when changed externally
set hlsearch            " Highlight search results
set incsearch           " Incremental search
set ignorecase          " Case insensitive search
set smartcase           " Case sensitive when uppercase present
set expandtab           " Use spaces instead of tabs
set smarttab            " Smart tab handling
set shiftround          " Round indent to multiple of shiftwidth
set autoindent          " Auto-indent new lines
set smartindent         " Smart indentation
set nobackup            " No backup files
set nowritebackup       " No backup while editing
set noswapfile          " No swap files
set wildmenu            " Enhanced command completion
set wildmode=longest:full,full
set completeopt=menu,menuone,noselect  " Better completion menu

set backspace=indent,eol,start
au CursorHold,CursorHoldI * checktime

" ====================================================================
" Appearance & Display
" ====================================================================

colorscheme dank-neon
set nowrap              " Don't auto-wrap on load
set fo-=t               " Don't auto-wrap when typing
set tw=79               " Text width for formatting (used by gq)
set colorcolumn=80      " Default column guide
highlight ColorColumn ctermbg=233

" ====================================================================
" Custom Keybindings & Shortcuts
" ====================================================================

" Leader key (default is \)
let mapleader = "\<Space>"

" EasyMotion shortcuts
nmap <Space> <Plug>(easymotion-bd-w)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

" Text manipulation
vnoremap <Leader>s :sort<CR>    " Sort selection
vnoremap < <gv                  " Keep selection when indenting
vnoremap > >gv                  " Keep selection when indenting

" Paragraph formatting
vmap Q gq                       " Format selection
nmap Q gqap                     " Format paragraph

" Clear search highlighting
nnoremap <Leader><Space> :nohlsearch<CR>

" Quick save and quit
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>wq :wq<CR>

" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <Leader>bn :bnext<CR>
nnoremap <Leader>bp :bprev<CR>
nnoremap <Leader>bd :bdelete<CR>

" Quick escape from insert mode
inoremap jk <Esc>
inoremap kj <Esc>

" ====================================================================
" Development Shortcuts Summary
" ====================================================================
" <Leader>f      - Find files (FZF)
" <Leader>b      - List buffers
" <Leader>rg     - Ripgrep search
" <Leader>n      - Toggle NERDTree
" <Leader>nf     - Find current file in NERDTree
" <Leader>py     - Format with Prettier
" <Leader>rn     - Rename symbol (CoC)
" gd             - Go to definition (CoC)
" gr             - Go to references (CoC)
" K              - Show documentation (CoC)
" [g / ]g        - Navigate diagnostics
" gcc            - Comment/uncomment line
" gc{motion}     - Comment motion (e.g., gcap for paragraph)
