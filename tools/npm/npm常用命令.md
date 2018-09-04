* `npm i -g npm@latest` 更新 npm

* `npm completion >> ~/.bashrc` 和 `npm completion >> ~/.zshrc` 可以为 npm 增加子命令的补全

* `npm adduser` 创建新用户

* `npm login` 登录 npm

* `npm logout` 退出登录

* `npm whoami` 查看当前登录的用户

* `npm profile set password` 修改密码

* `npm profile get [<key> <value>]` 查看用户信息, 不填 key value 就是查看所有信息

* `npm profile set <key> <value>` 设置用户信息如 email

* `npm i [-options] <package>` 安装包, 常用选项 `-P` 即 `--save-prod`, 是默认选项, 安装到运行时依赖. `-D` 即 `--save-dev`, 安装到开发时依赖, `-O` 即 `--save-optional`, 安装到可选依赖, `--no-save` 不添加到任何依赖, `-g` 全局安装

* `npm rm [-options] <package>` 删除已安装的包, 常用选项 `-S` 即 `--save`, 删除运行时依赖, 天知道为什么它不和前面的 `-P` 对应. `-D` 即 `--save-dev`, `-O` 即 `--save-optional`, 删除可选的包, `-g` 删除全局

* `npm up [-options][<package>]` 更新包, 默认只更新最顶层依赖的包, 即 package.json 中列出来的包. 它还会安装缺失的包. 不指定具体包名则更新所有. 如果需要更新依赖树的更深部分, 可以指定 `--depth 9999` 等深度. `-g` 更新全局下面的包

* `npm outdated [<package>]` 查看哪些包过期了(有新版本), 同样默认只查看依赖树顶层的包是否过期, 这里说下输出信息的 `wanted` 字段, 是表示符合 package.json 中指定的 semver 范围下安全的最大版本

* `npm version <version> | major | minor | patch | premajor | preminor | prepatch | prerelease -m <commit message>` 更新包版本, 可以手动指定比如 1.1.1, 也可以用关键字如 `patch`. 使用该命令会产生一个 git 提交记录以及一个 tag, 也默认触发 git hook, 可以使用 `-m` 选项添加 git 提交信息. `patch` 更新一个小版本, 比如 1.0.0 -> 1.0.1, `minor` 更新一个中版本, 比如 1.0.8 -> 1.1.0, `major` 更新一个大版本, 比如 1.1.8 -> 2.0.0

* `npm publish <folder> [--access <public|restricted>] [--tag <tag>]` 发布一个 npm 包, `--access` 用来指定发布一个私有包还是公有包, `--tag` 用来指定一个 tag, 这个不是 git tag, 默认 latest, 也可以是 next, stable, beta 之类

* `npm dist-tag add <package>@<version> [tag]` 给仓库里已发布的包的特定版本指定一个 tag, 比如已经发布了一个包 test@1.1.0, 使用 `npm dist-tag add test@1.1.0 next` 会使得其他人 `npm i test@next` 下载的是 1.1.0 版本的, 这个命令操作的是 npm 中心仓库或镜像的内容而非本地的内容, `publish` 的 `--tag` 选项是在发布的时候指定 tag, 这个是在发布之后追加 tag

* `npm dist-tag rm <package> <tag>` 也可以删除一个包的 tag

* `npm dist-tag ls <package>` 列出一个包已有的 tag

* `npm unpublish [<@scope>/]<pkg>[@<version>]` 取消发布某个版本的包, 但是只能在该版本发布的 72 小时内才能取消

* `npm deprecate <pkg>[@<version>] <message>` 弃用某个版本的包, 可以添加一些说明信息

* `npm owner add <user> [<@scope>/]<pkg>` 为一个包添加一个维护者, 维护者有权修改发布包

* `npm owner rm <user> [<@scope>/]<pkg>` 删除一个维护者

* `npm owner ls [<@scope>/]<pkg>` 列出所有维护者

* 每个组织和个人默认都有一个自己的 scope, 可以在创建项目的时候指定 scope, `npm init --scope=username`, 或者自己修改 package.json 的 `name` 字段为 `@username/project-name`

* org/team, 没用过, 看上去是组织就相当于一个 scope, 可以在这里(用户 profile 面板下) https://www.npmjs.com/org/create 创建一个组织, team 相当于组织下面的实体, 所以 team 相关的命令都是这样的.

  ```
  npm team create <scope:team>
  npm team destroy <scope:team>
  
  npm team add <scope:team> <user>
  npm team rm <scope:team> <user>
  
  npm team ls <scope>|<scope:team>
  
  npm team edit <scope:team>
  ```

  这里的 scope 也就是组织名了. 有了 org 和 team, 就可以给成员分配权限了. 通过 `npm access` 命令, 具体可以参考这些. https://docs.npmjs.com/misc/orgs, https://docs.npmjs.com/cli/team, https://docs.npmjs.com/cli/access

* npm 的配置通常在以下文件

  * `project/.npmrc` 针对特定项目的配置
  * `~/.npmrc` 用户的 npm 配置
  * `/etc/npmrc` 全局的 npm 配置, 通过 `--globalconfig` 或环境变量  `$NPM_CONFIG_GLOBALCONFIG` 指定这里的配置
  * `path/to/npm/npmrc` npm 内置的配置

  可以通过 `npm config ls -l` 查看所有 npm 配置选项的默认值. 这些选项的作用分散在每个 npm 命令里, 比如 `commit-hooks` 这个选项就是用来配置 `npm version` 命令是否触发 git hook 的. 所有选项的说明也可以看这里 https://docs.npmjs.com/misc/config, 可以使用 `npm config` 命令配置这些选项, 特别是代理!!!

  比如这是个人常用的一些 npm 配置.

  ```
  PUPPETEER_DOWNLOAD_HOST = "https://npm.taobao.org/mirrors"
  chromedriver_cdnurl = "https://npm.taobao.org/mirrors/chromedriver/"
  disturl = "https://npm.taobao.org/dist"
  electron_mirror = "https://npm.taobao.org/mirrors/electron/"
  msvs_version = "2015"
  phantomjs_cdnurl = "https://npm.taobao.org/mirrors/phantomjs/"
  python = "C:/Devtools/Python2/python.exe"
  registry = "https://registry.npmjs.org/"
  sass_binary_site = "https://npm.taobao.org/mirrors/node-sass/"
  ```

* 如果只是更新 README 的话, 官方给的操作是 `npm version patch` 然后 `npm publish`

* 测试 .npmignore 或 `files` 字段是否正确过滤/包含了指定文件, 官方给的操作是用 `npm pack`

* `npm ls -g --depth 0` 查看全局安装了哪些包

* `npm cache clean` 清除缓存目录下的所有包

* `npm ci` 这个命令和 `npm install` 的效果差不多, 区别是它要求项目必须要有一个 package-lock.json 文件, 它只能安装所有包, 它不会更新依赖项也就意味着不会更新 package.json 和 package-lock.json, 所以它通常在 CI 时用, 比如 Jenkins 上就可以不用写 `npm install` 而是写 `npm ci` 了

* 如果觉得 node_modules 目录太大的话, 也可以通过 `npm dedupe` 来减少被重复依赖的包

