call plug#begin('~/.vim/plugs')
    Plug 'pangloss/vim-javascript'
    Plug 'roxma/vim-hug-neovim-rpc'
    Plug 'scrooloose/nerdcommenter'
    Plug 'scrooloose/nerdtree'
    Plug 'w0rp/ale'
    Plug 'jiangmiao/auto-pairs'
    Plug 'easymotion/vim-easymotion'
    Plug 'Lokaltog/vim-powerline'
    Plug 'prettier/vim-prettier', {'do': 'npm install'}
    Plug 'christianrondeau/vim-base64'
call plug#end()

" Plugins settings
set laststatus=2    "vim-powerline
let g:prettier#autoformat = 0   " Disable beautify on save
nmap <Leader>py <Plug>(Prettier)

filetype off
filetype plugin indent on
syntax on
set pastetoggle=<F2>    " Better copy & paste
set mouse=a             " Enable mouse on visual mode
set bs=2                " Fix backspace
set relativenumber
set autoread
set hlsearch
set incsearch
set ignorecase
set smartcase
set tabstop=2
set softtabstop=2
set shiftwidth=2
set shiftround
set nobackup
set nowritebackup
set noswapfile

set backspace=indent,eol,start
au CursorHold,CursorHoldI * checktime

colorscheme dank-neon

nmap <Space> <Plug>(easymotion-bd-w)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

vnoremap <Leader>s :sort<CR>    " Sort selection
vnoremap < <gv  " Indent selected
vnoremap > >gv

" Show line numbers and length
set tw=79   " Widght of document (used by gd)
set nowrap  " Don't auto-wrap on load
set fo-=t   " Don't auto-wrap when typing
set colorcolumn=80
highlight ColorColumn ctermbg=233

" Paragraph formatting
vmap Q gq
nmap Q gqap
