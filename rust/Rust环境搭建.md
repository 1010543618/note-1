## 安装

以 Windows 为例, 在[这里](https://www.rust-lang.org/tools/install)下载 `rustup-init.exe`, 根据提示一路 next, 它会帮你完成设置环境变量等等操作非常方便. 但是安装的 `rustup` 默认是 32 位的, 可以在[这里](https://github.com/rust-lang/rustup.rs/blob/master/README.md#other-installation-methods)找到所有平台的 32 位或 64 位 `rustup`. `rustup` 是一个类似于 `nvm` 的工具, Rust 每六周发布一个新版本, 可以通过 `rustup` 来更新 Rust 的版本, `rustup` 也可以用来设置 Rust 编译的目标平台. 关于 `rustup` 的文档参考[这里](https://github.com/rust-lang/rustup.rs/blob/master/README.md).

安装好之后, 通过

```shell
$ rustc --version
```

检测是否正常工作.

需要 shell 自动补全 `rustup` 的子命令的话.

```shell
# Bash
$ rustup completions bash > /etc/bash_completion.d/rustup.bash-completion

# Bash (macOS/Homebrew)
$ rustup completions bash > $(brew --prefix)/etc/bash_completion.d/rustup.bash-completion

# Fish
$ rustup completions fish > ~/.config/fish/completions/rustup.fish

# Zsh
$ rustup completions zsh > ~/.zfunc/_rustup
```



### 更新 Rust

```shell
$ rustup update
```



### 更新 `rustup` 自己

```shell
$ rustup self update
```



### Windows

Windows 下建议安装 VS2015/VS2017/VS2019 或 [Windows Build Tools](https://github.com/felixrieseberg/windows-build-tools), 具体参考[这里](https://github.com/rust-lang/rustup.rs/blob/master/README.md#working-with-rust-on-windows).



### 离线安装

不过个人考虑国内的网络环境倾向于在[这里](https://forge.rust-lang.org/other-installation-methods.html)下载离线包. 不过两者稍稍有些区别, 前者是装了 `rustup` 再通过 `rustup` 安装整个 Rust 环境, 后者是直接安装了 Rust 相关工具链, 类似于前者通过 `nvm` 安装 Node, 后者直接通过压缩包安装 Node.

解压压缩包不要忘了执行里面的安装脚本, 之后还需要自己手动配置环境变量, 需要注意它不像 `rustup` 安装那样给这些工具链配置了软链, 所以要么配置多个目录的环境变量, 要么自己手动把那些工具链的可执行文件软链到一个目录下.

并且通过离线包安装的 Rust 环境, 相比于 `rustup` 安装的, 还是缺少了一些组件的, 具体对比 `~/.cargo/bin` 中的可执行文件.



### 更好的方式

参考[这里](https://mirrors.ustc.edu.cn/help/rust-static.html). 或者自己通过 `rustup` 安装成功后把相关目录压一个包.



## 换源

每个语言几乎都要做的事情...

> 在 $HOME/.cargo/config 中添加如下内容 
>
> ```
> [registry]
> index = "git://mirrors.ustc.edu.cn/crates.io-index"
> ```
>
> 如果所处的环境中不允许使用 git 协议, 可以把上述地址改为
>
> ```
> index = "http://mirrors.ustc.edu.cn/crates.io-index"
> ```
>
> 同步频率为每两个小时更新一次.
>
> 如果 cargo 版本为 0.13.0 或以上, 需要更改 $HOME/.cargo/config 为以下内容:
>
> ```
> [source.crates-io]
> registry = "https://github.com/rust-lang/crates.io-index"
> replace-with = 'ustc'
> [source.ustc]
> registry = "git://mirrors.ustc.edu.cn/crates.io-index"
> ```

参考[这里](https://lug.ustc.edu.cn/wiki/mirrors/help/rust-crates).



### VSCode

官方推荐了[这个](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust), 不过注意它依赖了 `rustup`.



## 调试

学新语言能够尽快掌握调试工具还是比较重要的, 不然错哪里都不知道. 对于 Windows, Rust 可以编译为 MSVC 和 GNU 两种不同的 ABI, 这里以 MSVC 为例.

首先去 VSCode 商店下载 [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb) 这个插件, 然后它会让你去下载 LLDB, 并且给了一个[指南](https://github.com/vadimcn/vscode-lldb/wiki/Installing-on-Windows), 其中提到 LLDB 对 MSVC 的支持不完全, 并且 64 位的 LLDB 不稳定, 所以我们需要把 Rust 的编译 target 改为 `i686-pc-windows-gnu`.

```shell
$ rustup install stable-gnu
$ rustup target add i686-pc-windows-gnu
$ rustup set default-host i686-pc-windows-gnu
```

然后下载 [LLVM 64bit](https://releases.llvm.org/download.html). 安装并添加环境变量. 然后安装 Python 3.5 以上的 64bit, 与 LLVM 对应.

然而这里有个坑爹的事情是, CodeLLDB 这个插件, 似乎硬编码了 Python 的版本, 只能是 3.5/3.6 的 Python, 而我这里 3.7 的 Python 它提示我找不到 Python, 所以没办法, 还是再装个 3.6.

然后开始调试, 目录中还需要两个配置, 一个 `settings.json`

```json
{
	"rust-client.channel": "stable",
	"lldb.executable": "lldb"
}
```

别问, 问就是不加会报错.

还有 `launch.json`

```json
{
	// Use IntelliSense to learn about possible attributes.
	// Hover to view descriptions of existing attributes.
	// For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
	"version": "0.2.0",
	"configurations": [
		{
			"type": "lldb",
			"request": "launch",
			"name": "Debug",
			"program": "${workspaceFolder}/main",
			"args": [],
			"cwd": "${workspaceFolder}"
		}
	]
}
```

然后 F5 下去, 它还提示需要装个插件 `vscode-lldb-windows.vsix`, 然而你如果通过 VSCode 自己去下载, 它从 Github 去下载, 这个资源在 AWS 上, 又他妈给 Q 了, 于是自己挂着梯子手动下好, 双击执行, 然而这个插件本身也很智障, 它会检测你系统中安装的 Visual Studio 和 VSCode, 但是它先检测到了 Visual Studio, 发现 Visual Studio 不能用, 于是给你报个错...所以我们需要在 VSCode 中去安装它, `> Extensions: Install from VSIX` 选择这个 .vsix 文件即可.

终于, 一切搞定, 编译一下.

```shell
$ rustc -C debuginfo=2 main.rs
```

*注: 这里 `-C` 支持的参数可以通过 `rustc -C help` 查看.*

然后 F5...断点成功, 然而给我看到的却是一片汇编...好吧, 今天先到这里吧, 有空再研究下怎么断到源文件.

也是不懂为什么大家都会推荐在 Windows 上用 GNU toolchains 而不是 MSVC...本菜鸡本来就不是很会 C/C++ 这套工具链...不过后来发现了另一个路子, 简单方便.

不要去用 LLDB 和 CodeLLDB 这个插件了, 也没 Python 什么事了, 那个 `settings.json` 也可以不需要了. 让我们还原到默认的 MSVC.

```shell
$ rustup set default-host x86_64-pc-windows-msvc
```

然后去下载这个 C/C++ 的 VSCode [插件](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)和这个[插件](https://marketplace.visualstudio.com/items?itemName=webfreak.debug), 不过这个 Native Debug 不是必要的, 如果不安装它, 需要项目目录下配置 `settings.json`.

```json
{
	"debug.allowBreakpointsEverywhere": true
}
```

然后配置 `launch.json`

```json
{
	// Use IntelliSense to learn about possible attributes.
	// Hover to view descriptions of existing attributes.
	// For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
	"version": "0.2.0",
	"configurations": [
		{
			"name": "(Windows) Launch",
			"type": "cppvsdbg",
			"request": "launch",
			"program": "${workspaceFolder}/target/debug/rust.exe",
			"args": [],
			"stopAtEntry": false,
			"cwd": "${workspaceFolder}",
			"environment": [],
			"externalConsole": true
		}
	]
}
```

就可以愉快地调试了.



## Linter

安装 clippy

```shell
$ rustup component add clippy
```

使用

```shell
$ cargo clippy
```

查看帮助

```shell
$ cargo clippy --help
```

关于它的配置参考[这里](https://github.com/rust-lang/rust-clippy#configuration). 另外这东西说是说和 Rust(rls) 这个插件集成了, 不过目前还没找到一个相关配置...不知道是否不需要配置, 另外也不知道怎么对单个文件做 lint.



## Format

安装 rust-fmt

```shell
$ rustup component add rustfmt
```

使用

```shell
$ cargo fmt
```

Rust (rls) 这个插件说是说集成了 rust-fmt, 不过实际测下来, 通过 VSCode 来格式化和通过 `cargo fmt` 格式化的效果并不一样, 找了半天也没找到这个插件怎么集成 rust-fmt, 除了一个保存时格式化, 但我并不想保存时格式化...

另外这个 rust-fmt 好像也没提供什么配置, 默认 4 格空格缩进也让人很难受...另外也不知道怎么格式化单个文件

*更新: 找到了 rust-fmt 的格式化配置, 参考[这里](https://github.com/rust-lang/rustfmt/blob/master/Configurations.md).*



## 参考资料

* https://www.rust-lang.org/tools/install
* https://github.com/rust-lang/rustup.rs/blob/master/README.md
* https://forge.rust-lang.org/other-installation-methods.html
* https://mirrors.ustc.edu.cn/help/rust-static.html
* https://lug.ustc.edu.cn/wiki/mirrors/help/rust-crates
* https://github.com/rust-lang/rustup.rs/issues/885
* https://stackoverflow.com/questions/37586216/step-by-step-interactive-debugger-for-rust
* https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb
* https://github.com/vadimcn/vscode-lldb/wiki/Installing-on-Windows
* https://github.com/vadimcn/vscode-lldb/blob/master/MANUAL.md#workspace-configuration
* https://github.com/rust-lang/rls-vscode/issues/167
* https://github.com/rust-lang/rls-vscode/issues/224
* https://stackoverflow.com/questions/48978766/visual-studio-code-warning-rls-could-not-set-rust-src-path-for-racer-because-it
* https://code.visualstudio.com/docs/editor/extension-gallery#_install-from-a-vsix
* https://fungos.github.io/blog/2017/08/12/setting-up-a-rust-environment-on-windows/
* https://github.com/Drops-of-Diamond/diamond_drops/wiki/Debugging-Rust-with-Visual-Studio-Code
* https://www.brycevandyk.com/debug-rust-on-windows-with-visual-studio-code-and-the-msvc-debugger/
* https://zhuanlan.zhihu.com/p/26944087
* https://github.com/rust-lang/rust-clippy
* https://github.com/rust-lang/rustfmt
* 