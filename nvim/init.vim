" Use asdf instead of hjkl for navigation
nnoremap a h
nnoremap s j
nnoremap d k
nnoremap f l

" Save and exit
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>x :x<CR>
nnoremap <Leader>wq :wq<CR>

" Other useful keybindings
nnoremap <Leader>c :q!<CR>
nnoremap <Leader>u :undo<CR>
nnoremap <Leader>r :redo<CR>
nnoremap <Leader>/ :nohlsearch<CR>

" Insert mode navigation
inoremap <C-a> <Left>
inoremap <C-s> <Down>
inoremap <C-d> <Up>
inoremap <C-f> <Right>

" Visual mode navigation
vnoremap a <gv
vnoremap s <C-n>
vnoremap d <C-p>
vnoremap f >gv

" Remap leader key to space
let mapleader = "\<Space>"

" Set line numbers and enable syntax highlighting
set number
syntax enable

" Custom settings
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent

" Use case-insensitive searching
set ignorecase
set smartcase

" Enable mouse support
set mouse=a

" Enable line wrapping
set wrap
set linebreak
set nolist

" Highlight current line
set cursorline

" Enable clipboard support
set clipboard=unnamedplus

" Plugin time

call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'

Plug 'navarasu/onedark.nvim'
Plug 'dense-analysis/ale'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.2' }
" or                                , { 'branch': '0.1.x' }

Plug 'nvim-tree/nvim-web-devicons' " optional
Plug 'nvim-tree/nvim-tree.lua'
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'romgrk/barbar.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'numToStr/Comment.nvim'
Plug 'karb94/neoscroll.nvim'
Plug 'norcalli/nvim-colorizer.lua'

call plug#end()
lua require('Comment').setup()
colorscheme onedark