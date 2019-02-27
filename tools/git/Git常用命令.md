## 术语及常见文件

* 版本库, 即 .git 目录中记录的目录树, 也叫仓库, 或 repo
* 工作区, 即 .git 目录所处的目录, 直接和用户交互的文件系统内容
* 暂存区, 也叫提交任务, stage, index, 也在 .git 中, 由 .git/index 文件记录, 即暂存区变动了会引起该文件变动
* `.git/objects` 目录, 存放文件变动的内容
* HEAD, 就是一个默认指向当前分支最新提交的游标, 其实就是 .git/HEAD 文件, 文件内容又指向了另一个文件, 比如 .git/refs/heads/master, 即表示 HEAD 指向了 master 分支, 而 .git/refs/heads/master 的文件内容又是一个 hash, 即 master 分支最新的 commit 对象的 id, 所以 master 这个名字就表示了当前分支最新的 commit, 所以默认情况下 `git log -l HEAD` `git log -l master` `git log -l refs/heads/master` 的输出都是一样的
* 引用, HEAD, master, refs/heads/master 都叫做一个引用, .git/refs 保存了这些引用, 而 .git/refs/heads 下的引用就被称为分支, 使用 refs/heads/master 和使用 master 这样的名称是等价的, 通过命令 `git rev-parse master` 可以查看 master 引用对应的提交, 同理 master 也可以换成 HEAD 或 refs/heads/master, 只要是一个引用就行, `^` 表示一个引用的父提交/上次提交, 可以 `HEAD^^`, 也可以 `HEAD^2`(从 1 开始) 
* add, 就是把工作区内容写入暂存区
* commit, 就是把暂存区写入版本库
* 对象, git 中有许多对象, 对象是对一次提交(commit), 一个目录树(tree), 一个提交的上一次提交(parent)的抽象, 每个对象有一个 hash 表示的 id, 或者说一个 hash 唯一标识了一个 git 对象. 一个对象就当它是一个数据结构, 有一个 id 字段, 值是一个 hash, 而一个 commit 就包含了自身 id, tree, parent, author 等字段, 其中 id, tree, parent 都是 hash,指向了其他的 commit 对象或 tree, 形成一个链表一样的结构. 这些对象都保存在 .git/objects 目录下, 通过 `git cat-file [options] <hash>` 来查看一个对象的类型, 内容等信息, -t 查看类型, -p 查看内容, -s 查看大小



## 初始配置

* `git config --global core.quotePath false` 如果中文文件名在 Git 命令输出中是 `\350\257` 这样的话, 需要执行这个来修坟
* `git config --global i18n.logOutputEncoding gbk` 对于非 UTF-8 环境下, 要改变 Git 输出的字符集, 用这个, 必要时考虑 `--system`
* `git config --global i18n.commitEncoding gbk` 对于非 UTF-8 环境下, 要改变 Git 提交信息的字符集, 用这个, 必要时考虑 `--system`
* `git config --global user.name "username"` 设置用户名, 必要
* `git config --global user.email "email"` 设置邮箱, 必要
* `git config --global color.ui true` Git 输出开启颜色, 必要
* `git config --global alias.ci commit` 为命令设置 alias, 也可以加选项 `git config --global alias.ci "commit -m"`
* `git config --global user.name` 像这样如果后面不跟值的话, 就是查看某个配置的值
* `--global` 是用户配置, 配置在用户目录下 `~/.gitconfig`, `--system` 是全局配置, 通常是所有用户, 配置在 `/etc/gitconfig` 下, 如果都不加, 则是当前项目配置, 配置在当前项目的 `.git/config` 下
* `git config -e --global` 即可编辑用户的配置文件, 之前所有配置命令都可以直接通过修改配置文件完成, 对应的也可以 `--system` 来修改全局配置等等
* `git config --unset --global user.name` 清除某一项配置





* `git init` 创建版本库
* `git add -i` 交互式执行 add 操作
* `git add -u <file>` add 已经 tracked 的文件而不 add 新增文件
* `git add -A` todo
* `git commit --amend` 修改上一次提交的提交信息, 但是实际上是相当于 reset 之后再 commit, 会导致提交的 hash 发生变化
* `git rm --cached <file>` 从暂存区删除某个文件, 但是不影响工作区, 即撤销对某个文件的 add
* `git stash`/`git stash pop` 把暂存区的保存下来, 但是不保存未 tracked 的文件
* `git clean -fd`
* `git diff` 比较暂存区和工作区的差异(--- 暂存区, +++ 工作区)
* `git diff HEAD` 比较版本库和工作区的差异(--- 版本库, +++ 工作区)
* `git diff --cached/--staged` 比较版本库和暂存区的差异(--- 版本库, +++ 暂存区), --cached 和 --staged 是一样的
* `git status -s` 精简的 status 输出
* `git checkout -- <file>` 从暂存区检出文件到工作区
* `git checkout HEAD <file>` 从版本库检出文件到工作区, 但是不影响暂存区
* `git reset HEAD` 从版本库检出文件到暂存区, 但是不影响工作区, 默认是 --mixed, 即从版本库检出到暂存区而不影响工作区, --soft 则是, --hard 则是用版本库替换暂存区以及工作区, 但是不影响未 tracked 的文件, 所以如果要清理干净, 那 `git reset --hard HEAD` 之后再加个 `git clean -fd`
* `git ls-tree -l HEAD` 查看 HEAD 指向的版本库的目录树
* `git ls-files -s` 查看暂存区的目录树