```

"********************** Normal Config *********
if has("syntax") 
  syntax on
endif

set nocompatible "关闭兼容模式
set nu "设置行号
set nobackup "禁止生成备份文件
set noswapfile "禁止生成.swp文件
set ru "设置标尺，状态栏显示当前行号列号以及整个文件百分比
set cmdheight=1 "设置状态栏高度占两行
set foldlevel=100 "启动vim时不要自动折叠代码
set autoread "当文件在其他地方被修改时自动读入新文件
set virtualedit=all "光标可以在没有字符的位置移动
set ignorecase "搜索时忽略大小写
set hlsearch "高亮搜索到的关键字
set tw=80 "光标超过80列自动换行
set cc=80 "在80列设置对齐线
"set cursorline 设置光标处对齐线
"set cursorcolumn 设置光标处横线
set sm "打开这个选项后，当输入后括号(包括小括号、中括号、大括号) 的时候，光标会跳回前括号片刻，然后跳回来 
set backspace=indent,eol,start "删除时可以拼接前后的行
set mouse=a "允许使用鼠标
set lazyredraw "减少刷新和重绘
set linebreak "换行不截断单词
set shell=C:/Devtools/Git/bin/bash.exe "设置shell



"Themes
colorscheme desert
highlight Pmenu      ctermfg=1 ctermbg=5 guifg=#ff0000 guibg=#00ff00
highlight PmenuSel  ctermfg=5 ctermbg=3 guifg=#ff0000 guibg=#00ff00
highlight PmenuSbar  ctermfg=2 ctermbg=3 guifg=#ff0000 guibg=#00ff00
highlight PmenuThumb ctermfg=2 ctermbg=3 guifg=#ff0000 guibg=#00ff00

"Indent
set cindent  "c风格缩进
set ai "set autoindent 自动缩进
set shiftwidth=2 "自动缩进时使用的tab的空格数
set tabstop=2 "插入tab时tab的空格数
set si "根据之前的格式对齐
"set expandtab "所有tab用空格替代

"FileType
filetype indent on "根据文件类型采用不同的自动缩进
filetype plugin on
filetype plugin indent on  "启动智能补全 
au FileType xml,html,python,vim,javascript,php,css setl shiftwidth=2
au FileType xml,html,python,vim,javascript,php,css setl tabstop=2
au FileType c,c++,java setl shiftwidth=4
au FileType c,c++,java setl tabstop=4


"Encoding
set fencs=utf-8,gbk "打开保存文件时尝试使用的编码
set encoding=utf-8 "vim内部编码，比如工具栏的编码
set termencoding=utf-8 "vim与shell交互时的编码
set fileformats=unix,dos "区分操作系统，主要是\r\n
"set langmenu=zh_CN.utf-8 菜单栏编码
"language message zh_CN.utf-8 系统提示设置编码
"set helplang=cn 帮助文档的语言
"

"Leader
let mapleader=","


"Keymap
inoremap <c-l> <Esc>A
inoremap jk <Esc>
nnoremap <Leader>p "+p
vnoremap <Leader>y "+y
au FileType c,c++,java,php,javascript,css inoremap <c-j> <Esc>A;<CR>
au FileType c,c++,java,php,javascript,css inoremap ;; <Esc>A;



"set spell
"set t_Co=256
"hi NonText guifg=bg "删除行号的波浪线
"hi NonText ctermfg=13
"**************************************************

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'mattn/emmet-vim'
Plug 'vim-scripts/Mark'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'terryma/vim-multiple-cursors'
Plug 'gcmt/wildfire.vim'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdcommenter'
Plug 'heronotears/vim-cs-explorer'
Plug 'vim-scripts/auto_mkdir'
Plug 'airblade/vim-gitgutter'
Plug 'w0rp/ale'
"Plug 'SirVer/ultisnips'
"Plug 'vim-scripts/VisIncr'
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
endif

call plug#end()

"Nerdtree
let NERDTreeWinSize=22
autocmd vimenter * NERDTree
autocmd vimenter * wincmd p
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


"Emmet
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

"Ctrlp
let g:ctrlp_root_markers = ['pom.xml', 'package.json']
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe

"deoplete
let g:deoplete#enable_at_startup = 1

"ale
let g:ale_fixers = {
\   'javascript': ['eslint'],
\}
let g:ale_linters = {
\   'javascript': ['eslint'],
\}
let g:ale_fix_on_save = 1
```

