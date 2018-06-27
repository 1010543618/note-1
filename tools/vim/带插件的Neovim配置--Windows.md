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
set bg=dark "set background 设置背景色
colorscheme delek "还是用默认主题, win下其他主题显示都很蛋疼, 其他主题记得放到插件加载之后
hi Pmenu      ctermfg=White ctermbg=DarkGreen guifg=#ff0000 guibg=#00ff00
hi PmenuSel  ctermfg=Black ctermbg=DarkRed guifg=#ff0000 guibg=#00ff00
hi PmenuSbar  ctermfg=DarkGreen ctermbg=DarkGreen guifg=#ff0000 guibg=#00ff00
hi PmenuThumb ctermfg=DarkGreen ctermbg=DarkGreen guifg=#ff0000 guibg=#00ff00
hi CursorLine cterm=none ctermfg=DarkYellow ctermbg=none
hi SpellBad cterm=none ctermfg=DarkRed ctermbg=none
hi NonText guifg=bg "删除行号的波浪线, 然而这个win下nvim会报错找不到bg color
hi NonText ctermfg=bg "删除行号的波浪线

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
"nnoremap <c-\> :vs<CR>
tnoremap <Esc> <C-\><C-n>
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l
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

call plug#begin('~/.vim/plugged') "nvim下是~/.local/share/nvim/plugged
Plug 'vim-airline/vim-airline'
Plug 'pangloss/vim-javascript' ", { 'for': 'javascript' }
Plug 'Yggdroot/LeaderF', { 'do': '.\install.bat' }
Plug 'tpope/vim-commentary'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive' "shell配置为git bash的时候这东西有点问题,shell配置为cmd正常
Plug 'junegunn/gv.vim'
Plug 'prettier/vim-prettier', { 'do': 'npm install', 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue'] } "shell配置为git bash的时候这东西也有点问题,shell配置为cmd正常
Plug 'w0rp/ale'
Plug 'mattn/emmet-vim', { 'for': ['html', 'css', 'scss', 'vue'] }
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin' "win下图标显示不出来
Plug 'vim-scripts/Mark--Karkat'
Plug 'mxw/vim-jsx', { 'for': ['javascript', 'jsx']}
Plug 'sirver/ultisnips'
Plug 'honza/vim-snippets'
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
"Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern', 'for': ['javascript', 'jsx', 'vue'] } "在win下还是有点bug
Plug 'skywind3000/asyncrun.vim'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'terryma/vim-multiple-cursors'
Plug 'jiangmiao/auto-pairs'
Plug 'gcmt/wildfire.vim'
Plug 'tpope/vim-repeat'

"Plug 'pbrisbin/vim-mkdir'
"Plug 'skywind3000/quickmenu.vim'
"Plug 'ctrlpvim/ctrlp.vim'
"Plug 'nathanaelkane/vim-indent-guides'
"Plug 'vim-scripts/ShowTrailingWhitespace'
""Plug 'vim-scripts/VisIncr'



"Theme
"Plug 'morhetz/gruvbox'
"Plug 'AlessandroYorba/Sierra'
"Plug 'nanotech/jellybeans.vim'
"Plug 'rakr/vim-one'

call plug#end()

"*******************************************

"***********Plugins****************************

"vim-javascript
let g:javascript_plugin_jsdoc = 1
augroup javascript_folding
    au!
    au FileType javascript setlocal foldmethod=syntax
augroup END

"LeaderF
let g:Lf_ShortcutF = '<c-p>'
let g:Lf_RootMarkers = ['.git', '.svn', '.hg', 'package.json', 'pom.xml'] 
let g:Lf_WildIgnore = {
        \ 'dir': ['.svn','.git','.hg', '.vscode', '.idea', 'node_modules', 'dist', 'docs'],
        \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
        \}

"vim-gitgutter
set updatetime=1000
let g:gitgutter_max_signs = 800 "监听800个变更

"prettier
nmap <Leader>j <Plug>(Prettier)
let g:prettier#exec_cmd_async = 1

"ale
let b:ale_linters = {'javascript': ['eslint']}
let b:ale_fixers = {'javascript': ['eslint']}
let g:ale_sign_error = 'xx'
let g:ale_sign_warning = 'ww'
let g:airline#extensions#ale#enabled = 1
let g:ale_set_quickfix = 1
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

"Emmet
let g:user_emmet_install_global = 0
autocmd FileType html,css,vue EmmetInstall


"Nerdtree
let NERDTreeWinSize=22
let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '-'
autocmd vimenter * NERDTree | wincmd p
nnoremap <c-q> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

"nerdtree-git-plugin
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

"ultisnips
let g:UltiSnipsUsePythonVersion = 3
let g:UltiSnipsSnippetsDir = '~/.vim/UltiSnips' "win下nvim是~/.local/share/nvim/UltiSnips
let g:UltiSnipsSnippetDirectories = ['UltiSnips']
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="ll"
let g:UltiSnipsJumpBackwardTrigger="hh"
let g:UltiSnipsEditSplit="vertical"

"deoplete
let g:deoplete#enable_at_startup = 1
"call deoplete#custom#option({
"\ 'auto_complete_delay': 100,
"\ 'max_list': 50,
"\ 'num_processes': 4,
"\ 'ignore_case': 1
"\ })

"deoplete-ternjs
"let g:deoplete#sources#ternjs#depths = 1
""let g:deoplete#sources#ternjs#docs = 1
"let g:deoplete#sources#ternjs#case_insensitive = 1
"let g:deoplete#sources#ternjs#include_keywords = 1
"let g:deoplete#sources#ternjs#filetypes = [ 'javascript', 'js', 'jsx', 'javascript.jsx', 'vue' ] "不确定应该是javascript还是js

""Ctrlp
"let g:ctrlp_root_markers = ['pom.xml', 'package.json']
"let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
"set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe
"

"vim下不需要这个,nvim需要
"没有什么是一个settimeout不能解决的, 如果有, 那就再加1s
"if has('timers')
"  func! MyHolyShit(timer)
"    set bg=dark 
"    colorscheme delek
"    hi Pmenu      ctermfg=White ctermbg=DarkGreen guifg=#ff0000 guibg=#00ff00
"    hi PmenuSel  ctermfg=Black ctermbg=DarkRed guifg=#ff0000 guibg=#00ff00
"    hi PmenuSbar  ctermfg=DarkGreen ctermbg=DarkGreen guifg=#ff0000 guibg=#00ff00
"    hi PmenuThumb ctermfg=DarkGreen ctermbg=DarkGreen guifg=#ff0000 guibg=#00ff00
"  endfunc
"  "为什么要500ms呢, 因为时间短了mark这个插件有bug用不了...必须看配色闪烁一下才能用,非常ZZ
"	let timer = timer_start(800, 'MyHolyShit')
"  "nnoremap <Leader>wf :call MyHolyShit('a')<CR>
"endif
```

