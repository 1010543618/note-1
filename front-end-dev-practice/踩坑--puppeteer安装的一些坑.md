讲道理其实很少会遇到安装库的时候出问题. 上一个是 `node-canvas`.

最近做一个生成 PDF 的小玩具时用到了 puppeteer, Windows 下跑起来一路畅通, 没遇到什么问题. 于是部署到我的小鸡上去了. 结果一跑就报了个错, 忘记截图了, 完整的报错忘了. 总之就是连这么一句

```javascript
const browser = await puppeteer.launch();
```

都跑不起来, 错误关键词是

```shell
Syntax error: Unterminated quoted string
```

这就很诡异了, 讲道理我还不至于智障到写个字符串都忘记闭合引号吧...仔细看了下报错的倒也并不是我的代码, 而是 Chrome 的二进制文件, 然而它到底做了个什么报了这么个错误也是不得而知.

查吧, 让我去看官方的 Troubleshooting, 里面大多是解决依赖缺失问题的. 找了半天也没什么结果, 似乎没人遇到我这么个问题啊. 不过到时其他应用在 Linux 下也遇到了类似报错, 索性也看看吧.

其中一个老外提到说大概率是你的二进制文件不支持这个平台.

emmm...之前安装 puppeteer 的时候倒也没报错不是, 如果不支持那它肯定会报错吧. 再说了, Google 家的东西怎么可能不支持我这么个普通的 Ubuntu 16.04 32bit.

不过抱着试试的态度, 还是看看这个二进制文件吧

```shell
$ cd node_modules/puppeteer/.local-chromium/linux-549031/chrome-linux/
$ file chrome
chrome: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, not stripped
```

emmm...等等, 你怎么是个 64bit 的? 可我这是 32bit 的系统啊. 所以为什么 puppeteer 它要给我个 64bit 的二进制呢?

知道了问题, 但是还是不是很好办啊. 为了一个库去重装了系统这行为很傻吊, 剩下的路子找预编译的 32bit 的二进制文件, 或者自己编译. 然而并没有找到预编译的 32bit 文件, puppeteer 官方也没看到有编译教程, 目测需要编译 Chromium, 我这个 1C1G 的小鸡也吃不消...于是最后的解决办法竟然还是我去重装了个 64bit 的系统...

不过后来看参考资料里那个 issue 也可以自己从 Ubuntu 的源里去下载个 Chromium, 然后在 `puppeteer.launch()` 的选项中指定 `executablePath` 参数为自己的 Chromium. 感觉这应该是个比较靠谱的方案, 不过我已经用了智障方案了就没测试了.

之后换了系统就没遇到这问题了, 不过还是有依赖缺失, 解决方案照官方就好.

```shell
$ cd node_modules/puppeteer/.local-chromium/linux-549031/chrome-linux/
$ ldd chrome | grep not
```

看看缺少哪些库, 一个个补上就好.

基本问题就这些吧. 话又说回来, 也是奇怪居然没多少人遇到类似问题吗, 还是大佬们都用上 4G/64bit 了...



#### 参考资料

* https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md
* https://github.com/GoogleChrome/puppeteer/issues/550
* http://iron-rhine.1d35.starter-us-east-1.openshiftapps.com/googlejia-kai-yuan-de-puppeteershi-yong-bugxiu-fu/