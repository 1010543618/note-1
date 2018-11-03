跟着书上先从 GHCi 开始吧...

安装好 Haskell Platform core 之后, 环境变量这些它都帮你搞好了, 所以命令行直接输入

```shell
$ ghci
```

就进入 REPL 环境了.

下面常用的命令有

* `:load` 简写为 `:l`, 加载一个文件, eg. `:l "c:\\test.hs"`, Win 下要转义
* `:reload` 简写为 `:r`, 重新导入当前文件, 因为文件更新了 GHCi 不会自动重新导入
* `:cd` 改变 cwd, eg. `:cd c:\test`, 为什么这里不需要加双引号?
* `:edit` 用默认文本编辑器编辑当前导入的文件
* `:module` 简写为 `:m`, 导入一个库, eg. `:m +<module1> <module2>` 导入两个库, `:m -<module1> <module2>` 移除两个库, 只输入 `:m` 会移除所有加载的库
* `:!` 执行系统命令, 看起来像 vim 下面的 `:!` 一样的
* `:quit` 退出 GHCi
* `:?` 显示帮助

启动 GHCi 之后的提示符是 `Prelude>`, 是已经载入了一个叫 Prelude 的库了, 可以在本地文档中找到它的说明, 还可以通过文档中的 source 链接看到它的源代码.