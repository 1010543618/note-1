```
"********************** Normal Config *********
if has("syntax") 
  syntax on
endif

set spell "拼写检查
set spelllang=en,cjk "不对中文做拼写检查, zg手动消除拼写检查错误, zw标识为拼写错误, 字典在~/AppData/Local/nvim/spell
set nocp "set nocompatible关闭兼容模式
set nu "set number 设置行号
set nobk "set nobackup 禁止生成备份文件
set noswf "set noswapfile 禁止生成.swp文件
set ru "set ruler 设置标尺，状态栏显示当前行号列号以及整个文件百分比
set ch=1 "set cmdheight 设置状态栏高度占两行
set ar "set autoread 当文件在其他地方被修改时自动读入新文件
set tw=80 "set textwidth 光标超过80列自动换行
set cul "set cursorline 设置光标处横线
set bs=indent,eol,start "set backspace 删除时可以拼接前后的行
set mouse=a "允许使用鼠标
set lz "set lazyredraw 减少刷新和重绘
set lbr "set linebreak 换行不截断单词
set fo+=mB "允许汉字断行
set cf "set confirm 未保存或文件只读时弹出提示
set sel=inclusive "set selection 光标所在位置字符也是被选中范围中的

"search
set ic "set ignorecase 搜索时忽略大小写
set hls "set hlsearch 高亮搜索到的关键字

"fold
set nofen "set nofoldenable 启动vim时不要自动折叠代码
set fdm=indent "set foldmethod 根据缩进折叠
set fdl=99 "set foldlevel

"Themes
set bg=dark "set background 设置背景色
colorscheme delek "还是用默认主题, win下其他主题显示都很蛋疼, 其他主题记得放到插件加载之后
hi Pmenu      ctermfg=White ctermbg=DarkGreen guifg=#ff0000 guibg=#00ff00
hi PmenuSel  ctermfg=Black ctermbg=DarkRed guifg=#ff0000 guibg=#00ff00
hi PmenuSbar  ctermfg=DarkGreen ctermbg=DarkGreen guifg=#ff0000 guibg=#00ff00
hi PmenuThumb ctermfg=DarkGreen ctermbg=DarkGreen guifg=#ff0000 guibg=#00ff00
hi CursorLine cterm=none ctermfg=DarkYellow ctermbg=none
hi SpellBad cterm=none ctermfg=DarkRed ctermbg=none

"Indent
set cin  "set cindent c语言自动缩进
set ai "set autoindent 自动缩进
set sw=2 "set shiftwidth 自动缩进时使用的tab的空格数
set ts=2 "set tabstop 插入tab时tab的空格数
set si "set smartindent 根据之前的格式对齐

"FileType
filetype plugin indent on  "根据文件类型采用不同的自动缩进
au FileType xml,html,python,vim,javascript,php,css setl shiftwidth=2
au FileType xml,html,python,vim,javascript,php,css setl tabstop=2
au FileType c,c++,java setl shiftwidth=4
au FileType c,c++,java setl tabstop=4


"Encoding
set fencs=utf-8,gbk "set fileencodings 打开保存文件时尝试使用的编码
set enc=utf-8 "set encoding vim内部编码，比如工具栏的编码
set tenc=utf-8 "set termencoding vim与shell交互时的编码
set ffs=unix,dos "set fileformats 区分操作系统，主要是\r\n
set ambw=double "set ambiwidth unicode支持

"Leader
let mapleader=","


"Keymap
inoremap <c-l> <Esc>A
inoremap jk <Esc>
nnoremap <Leader>p "+p
vnoremap <Leader>y "+y
nnoremap <c-\> :vs<CR>
tnoremap <Esc> <C-\><C-n>
if !has('nvim')
	exec "set <M-h>=\eh"
	exec "set <M-l>=\el"
	exec "set <M-j>=\ej"
	exec "set <M-k>=\ek"
	"set ttimeout ttimeoutlen=50
endif
tnoremap <M-h> <C-\><C-n><C-w>h
tnoremap <M-j> <C-\><C-n><C-w>j
tnoremap <M-k> <C-\><C-n><C-w>k
tnoremap <M-l> <C-\><C-n><C-w>l
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l
au FileType c,c++,java,php,javascript,css inoremap <c-j> <Esc>A;<CR>
au FileType c,c++,java,php,javascript,css inoremap ;; <Esc>A;



set shell=C:/Devtools/Git/bin/bash.exe "设置shell, win下设置为git bash会导致git相关插件崩掉
"**************************************************

"*************Plugin****************************
call plug#begin('~/.vim/plugged')
Plug 'Yggdroot/LeaderF', { 'do': '.\install.bat' }
Plug 'pangloss/vim-javascript' ", { 'for': 'javascript' }
Plug 'tpope/vim-commentary'
Plug 'airblade/vim-gitgutter'
Plug 'mattn/emmet-vim', { 'for': ['html', 'css', 'scss', 'vue'] }
Plug 'scrooloose/nerdtree'
Plug 'vim-scripts/Mark--Karkat'
Plug 'skywind3000/asyncrun.vim'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'terryma/vim-multiple-cursors'
Plug 'jiangmiao/auto-pairs'
Plug 'gcmt/wildfire.vim'
Plug 'tpope/vim-repeat'
Plug 'pbrisbin/vim-mkdir'
Plug 'jremmen/vim-ripgrep'



"Theme
Plug 'morhetz/gruvbox'
Plug 'AlessandroYorba/Sierra'
Plug 'nanotech/jellybeans.vim'
Plug 'rakr/vim-one'
call plug#end()

"***********Plugins****************************

"vim-javascript
let g:javascript_plugin_jsdoc = 1
augroup javascript_folding
    au!
    au FileType javascript setlocal foldmethod=syntax
augroup END


"vim-gitgutter
set updatetime=1000
let g:gitgutter_max_signs = 800 "监听800个变更


"Emmet
let g:user_emmet_install_global = 0
autocmd FileType html,css,vue EmmetInstall


"Nerdtree
let NERDTreeWinSize=22
let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '-'
let g:NERDTreeShowHidden = 1
autocmd vimenter * NERDTree | wincmd p
nnoremap <c-q> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

"LeaderF
let g:Lf_ShortcutF = '<c-p>'
let g:Lf_RootMarkers = ['.git', '.svn', '.hg', 'package.json', 'pom.xml'] 
let g:Lf_WildIgnore = {
        \ 'dir': ['.svn','.git','.hg', '.vscode', '.idea', 'node_modules', 'dist', 'docs'],
        \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
        \}


"ripgrep
let g:rg_binary = 'c:/Devtools/Ripgrep/rg.exe'
"let g:rg_highlight = true
```

