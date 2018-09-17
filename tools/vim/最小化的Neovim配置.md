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
"set ve=all "set virtualedit 光标可以在没有字符的位置移动
set tw=80 "set textwidth 光标超过80列自动换行
"set cc=80 "set colorcolumn 在80列设置对齐线
set cul "set cursorline 设置光标处横线
"set cuc "set cursorcolumn 设置光标处对齐线
"set sm "set showmatch 打开这个选项后，当输入后括号(包括小括号、中括号、大括号) 的时候，光标会跳回前括号片刻，然后跳回来 
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
"set is "set incsearch 增量搜索, 即输入就开始移动光标

"fold
set nofen "set nofoldenable 启动vim时不要自动折叠代码
set fdm=indent "set foldmethod 根据缩进折叠
set fdl=99 "set foldlevel

"Themes
"set t_Co=256 "256色, 对于win下vim就不用这个了,win下nvim有没有都一样
"set termguicolors
set bg=dark "set background 设置背景色
colorscheme delek "还是用默认主题, win下其他主题显示都很蛋疼, 其他主题记得放到插件加载之后
hi Pmenu      ctermfg=White ctermbg=DarkGreen guifg=#ff0000 guibg=#00ff00
hi PmenuSel  ctermfg=Black ctermbg=DarkRed guifg=#ff0000 guibg=#00ff00
hi PmenuSbar  ctermfg=DarkGreen ctermbg=DarkGreen guifg=#ff0000 guibg=#00ff00
hi PmenuThumb ctermfg=DarkGreen ctermbg=DarkGreen guifg=#ff0000 guibg=#00ff00
hi CursorLine cterm=none ctermfg=DarkYellow ctermbg=none
hi SpellBad cterm=none ctermfg=DarkRed ctermbg=none
"hi NonText guifg=bg "删除行号的波浪线, 然而这个win下nvim会报错找不到bg color
"hi NonText ctermfg=bg "删除行号的波浪线

"Indent
set cin  "set cindent c语言自动缩进
set ai "set autoindent 自动缩进
set sw=2 "set shiftwidth 自动缩进时使用的tab的空格数
set ts=2 "set tabstop 插入tab时tab的空格数
set si "set smartindent 根据之前的格式对齐
"set et "set expandtab 所有tab用空格替代

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
"set lm=zh_CN.utf-8  "set langmenu 菜单栏编码
"language message zh_CN.utf-8 系统提示设置编码
"set hlg=cn "set helplang 帮助文档的语言
"

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
	set ttimeout ttimeoutlen=50
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



"set shell=C:/Devtools/Git/bin/bash.exe "设置shell, win下设置为git bash会导致git相关插件崩掉
"**************************************************


"*********** Neovim ************
let g:python_host_skip_check=1
let g:python3_host_skip_check=1
let g:ruby_host_skip_check=1
let g:python3_host_prog='C:/Devtools/Python3/python.exe'
let g:python_host_prog='C:/Devtools/Python2/python.exe'
let g:ruby_host_prog='C:/Devtools/Ruby24/bin/ruby.exe'
let g:node_host_prog  = 'C:/Devtools/Nodejs/node.exe'
"***********************************************
```

