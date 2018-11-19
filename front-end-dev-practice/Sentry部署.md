没有自建 Sentry, 用的是免费的 Sentry 服务, 作为自己博客来讲够用了. 这里简单记录下一些坑.

首先注册账号没什么好讲, 创建 org, 创建 project, 建议 project 和 Github 的 repo 名字一样, 也可以不一样就是了.

然后本地工具先装个 sentry-cli, 建议 Windows 下不要用 npm 装, Win10 64 + Node 11 下用 npm 装总是会谜之卡死.  所以去他 [Github](https://github.com/getsentry/sentry-cli/releases/) 上下载对应平台的安装包, 完了随便丢哪个目录配置下环境变量就行了.

CLI 装好之后, 登录一下.

```shell
$ sentry-cli login
```

他会让你去领个 token, 也可以自己事先创建好, 在 Settings - Account - API -Auth Tokens 下可以找到生成 token, 在[这里](https://sentry.io/settings/account/api/auth-tokens/). 特别注意这个 token 的权限, 除了默认权限, 建议(必须)把 `project:write` 这个权限勾上, 不然等会上传 sourcemap 就要报 401 错误了. 官方文档这点没有提, 给坑了半天.

登录完之后, 本地暂时没什么要操作的. 去 Settings - 对应的 org - Integrations 下面把 Github 的插件装上, 也就是[这里](https://sentry.io/settings/lowbteam/integrations/), Github 那边也装个 Sentry 的插件, 注意 Github 是装在 Installed Github Apps 下, 不是其他两个, 不过做完这些操作之后其他两个下面一般也会有 Sentry 就是.

之后再到 Settings - 对应 org - Repositories 下面, 也就是[这里](https://sentry.io/settings/lowbteam/repos/), 添加下自己对应的 Github repo.

现在我们 Sentry 下面有了一个 project, 和一个 Github repo, 要把它们关联起来. 具体操作看[这里](https://docs.sentry.io/workflow/releases/?platform=browsernpm#link-repository). 这里提下重点.

执行以下命令.

```shell
$ export SENTRY_AUTH_TOKEN=...
$ export SENTRY_ORG=my-org
$ VERSION=$(sentry-cli releases propose-version)
$ sentry-cli releases new -p projectName $VERSION
$ sentry-cli releases set-commits --auto $VERSION
```

`$VERSION` 是提交的 hash, 建议在最后一步之前先往 repo 中 push 一个 commit, 用来触发 Webhook 给 Sentry, 不然最后一步会报错. 完成之后会在 Sentry 的 project 中的 release 面板下看到刚刚创建的 release, 说明关联成功.

可以成功创建 release 之后, 说明之后我们可以在 Webpack  构建中加入 Sentry 帮我们自动上传 sourcemap 了.

项目中需要两个 Sentry 组件, 一个是 sentry-webpack-plugin, 一个是 @sentry/browser, 前者开发时依赖, 后者运行时依赖. 前者的功能和 sentry-cli 是一样的, 用来帮我们创建 release 和上传 sourcemap, 集成到 Webpack 中的好处是让这一步骤加入到工作流中, 自动化处理了. 然而这个插件和 sentry-cli 一个毛病, 谜之卡死, 如果遇到, 建议

```shell
$ npm i -D -f sentry-webpack-plugin
```

执行下载的时候可以 `ctrl+c` 掉, 手动把之前下载好的 sentry-cli.exe 复制到 node_modules/@sentry/cli/bin 下面, 如果 package.json 和 .lock 文件没更新就再执行一下就好了

```shell
npm i -D -f sentry-webpack-plugin
```

它不会再去下载 sentry-cli.exe 了.

然后项目下面创建一个 .sentryclirc 的文件.

```:black_nib:
[defaults]
url = https://sentry.io
org = your-org
project = your-project
```

然后在 build 之前或者 CI 环境下配置环境变量

```:black_nib:
$ export SENTRY_AUTH_TOKEN=...
```

把之前的 token 填上, 虽然也可以放在 .sentryclirc 里面, 但是这是敏感信息, 就不放进去了. 如果觉得 org 和 project 也是敏感信息, 也可以都通过环境变量指定. 具体参考[这里](https://docs.sentry.io/cli/configuration/).

接着是 Webpack 的配置. 默认情况下 sentry-webpack-plugin 会去找当前根目录下的 .sentryclirc 文件, 找不到就找 ~/.sentryclirc, 似乎也会看环境变量.

其实配置也没啥好说, 看[这里](https://github.com/getsentry/sentry-webpack-plugin)吧. 具体作用也可以看[这里](https://docs.sentry.io/cli/releases/)

个人觉得比较重要的, `include` 配置为 dist, `urlPrefix` 会比较有用, 其他默认就好.

客户端的配置也没太多, `dsn` 肯定要配的, 可以在[这里](https://sentry.io/settings/lowbteam/blog-mobile/keys/)找到. 这里贴下自己的配置.

```:black_nib:
import('@sentry/browser').then(Sentry => {
	Sentry.init({
		dsn: '<url>',
		integrations: [new Sentry.Integrations.Vue({Vue})],
		release: process.env.VERSION,
		environment: process.env.NODE_ENV
	});
});
```









## 参考资料

* https://docs.sentry.io/workflow/releases/?platform=browsernpm#link-repository
* https://docs.sentry.io/cli/installation/
* https://docs.sentry.io/cli/configuration/
* https://docs.sentry.io/cli/releases/
* https://docs.sentry.io/error-reporting/configuration/?platform=browsernpm
* https://blog.fritx.me/?2017/07/sentry-sourcemap-guide