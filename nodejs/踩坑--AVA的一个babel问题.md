撸了个小轮子, 试了下 AVA 这个测试框架, 感觉还可以, 但是遇到一个神坑.

首先我们的项目源码是 `src/index.js`, 是一个 ES6 module, 大概是这样子.

```javascript
// ...
export function demo() {}
```

然后我们的项目中因为用到了 tree shaking, 所以需要将 `.babelrc` 配置为这样

```json
{
	"plugins": [
		"array-includes"
	],
	"presets": [
		[
			"@babel/env",
			{
				"loose": true,
				"modules": false
			}
		]
	]
}
```

我们把 `moudles` 设置成了 `false`, 意味着 babel 不会将源码中的 `export` 导出转换成 CommonJS 导出.

然后我们的测试代码长这样子.

```javascript
import { demo } from '../src';
// ...
```

没错, 我们依然用 ES6 module 引入, 因为 AVA 官方文档说了, 它内置了 babel 转换, 所以我们测试代码也可以用 ES6 module.

然而当你跑测试的时候就会给你报一个错误.

```shell
# ...
  export function demo() {
  ^^^^^^

  SyntaxError: Unexpected token export
```

不是说好的支持 ES6 ? 仔细看了下[官方文档](https://github.com/avajs/ava/blob/v1.0.0-rc.1/docs/recipes/babel.md)他说默认不会转译 `/test` 目录之外的文件, , 只转译 `/test` 下的测试代码以及 `_` 开头的文件和 `helpers` 目录下的文件(`_` 开头的文件和 `/tset/helpers` 目录的文件不会被作为测试代码, 只是作为测试代码的辅助工具被引入), 如果你要让 babel 也处理项目源码的话, 你需要使用 `@babel/register`.

> AVA does not currently compile source files. You'll have to load [Babel's `register` module](http://babeljs.io/docs/usage/require/), which will compile source files as needed.

也给出了一个配置, 在 `package.json` 中添加

```json
{
    "ava": {
        "require": [
            "@babel/register"
        ]
    }
}
```

当你配置好了以后再跑测试, 会发现它还是报了这么个错误, 并没有什么改变. 这就很智障了, 于是又查了下. 发现一个老哥遇到和我一样的问题, 官方开发者说了, 这是因为 `.babelrc` 中 `modules: false` 导致的, 想了想好像是的, 遂改成默认 `modules: "commonjs"`, 再跑一边.

```shell
  Uncaught exception in test\index.test.js

  C:\Codes\javascript\tinyjx\test\index.test.js:16

   15:
   16: test.before(async t => {
   17:   browser = await puppeteer.launch({

  ReferenceError: regeneratorRuntime is not defined
```

emmm...这次错误换了一个, 缺少 `regeneratorRuntime`, 直觉上讲, 应该是少了 `@babel/polyfill` 或者 `@babel/transform-runtime`, 又看了下官方文档, 果然是这样.

> AVA lets you write your tests using new JavaScript syntax, even on Node.js versions that otherwise wouldn't support it. However, it doesn't add or modify built-ins of your current environment. Using AVA would, for example, not provide modern features such as `Object.entries()` to an underlying Node.js 6 environment.
>
> By loading [Babel's `polyfill` module](https://babeljs.io/docs/usage/polyfill/) you can opt in to these features. Note that this will modify the environment, which may influence how your program behaves.

于是又手动装一个 `@babel/polyfill`, 在 `package.json` 也加上.

```json
  "ava": {
    "require": [
      "@babel/register",
      "@babel/polyfill"
    ]
  }
```

再跑一遍, OK, 一切正常. 当然, 你也可以手动在测试代码中引入 `@babel/polyfill`.

```javascript
import '@babel/polyfill';
```

不过肯定是在配置引入看起来舒服些.

但是到这里还是有问题啊, 我们把 `.babelrc` 中的 `modules` 改成 `"commonjs"` 了, 那我们的 tree shaking 怎么办? 总不能每次测试的时候手动改一下, 测完再手动改回来吧? 这他妈太傻屌了.

我们还是把它改回来 `modules: false`, 但是又回到开头的那个错误. 问题在于 AVA 会读取项目目录下的 `.babelrc` 作为它的 babel 配置, 而我们的配置里面为了 tree shaking 设置了 `modules: false`. 一个简单的想法是, 有两份 babel 配置就好了, 官方也确实为我们提供了[这一点](https://github.com/avajs/ava/blob/v1.0.0-rc.1/docs/recipes/babel.md#make-ava-skip-your-projects-babel-options).

> You may not want AVA to use your project's Babel options, for example if your project is relying on Babel 6. You can set the `babelrc` option to `false`.

```json
{
    "ava": {
        "babel": {
            "testOptions": {
                "babelrc": false
            }
        }
    }
}
```

就可以让 AVA 不使用项目的 babelrc 了, 然后我们再手动为它指定一个 babel 配置.

```json
  "ava": {
    "require": [
      "@babel/register",
      "@babel/polyfill"
    ],
    "babel": {
      "testOptions": {
        "babelrc": false
      }
    }
  }
```

然而, 还是没有用, 还是原来的错误. 但是这不能证明 AVA 还是读取了项目目录的 `.babelrc`, 也可能是其他原因, 不过我们还是把 `.babelrc` 的 `modules` 改成 `"commonjs"` 确认下. 改完发现又好了, 那说明 AVA 这个配置没用, 还是会读取 `.babelrc`.

原因在这个 [issue](https://github.com/avajs/ava/issues/1139) 和这个 [issue](https://github.com/avajs/ava/issues/1767) 提到了.

> Ah! The issue is with `babel-core/register` using the `.babelrc` config, which isn't set up to transform module syntax. Currently there's nothing AVA can do about this.
>
> That said, you could still simplify the `ava.babel` section to:
>
> ```
> {
>   "plugins": ["transform-es2015-modules-commonjs"]
> }
> ```
>
> And the test files themselves will run.
>
> I've been thinking about how we could provide better support for Babel-based projects. I'll keep your use case in mind, where you want AVA to transpile source files using a different config than used by your build step.

> I guess the problem is `@babel/register`. `@babel/register` will read the config from `.babelrc` unless You specify options like below
>
> ```
> require('@babel/register')({
>   babelrc: false
> })
> ```

是说, AVA 虽然配置了不会读取 `.babelrc`, 但是 `@babel/register` 这个坑逼还是会去读取项目目录下的 `.babelrc`. 这就很傻屌了, 引入它是为了解决这个问题, 结果它又把这个问题带回来了.

好在这位老哥给出了一个解决方案, 后来官方文档也更新了.

手动写一个脚本 `test/_register.js`, 下划线开头的文件不会被作为测试代码.

```javascript
/* eslint-disable */
require('@babel/register')({
	babelrc: false,
	ignore: ['node_modules/**', 'test/**']
});
```

也可以给它传入其他 babel 配置, 不过这样的话, 它不会使用 `.babelrc` 中的配置了, 也就不会对测试代码中引入的项目代码 `src/demo.js` 做转换了, 因为它相当于没有配置 babel.

为了避免重复好几份 babel 配置, 我们可以读取 `.babelrc`.

`test/_register.js`, 这个文件可以用 ES6 写, 它在 `/test` 下会被转译

```javascript
import fs from 'fs';
import register from '@babel/register';
let babelConfig = JSON.parse(fs.readFileSync('./.babelrc', 'utf8'));
babelConfig.babelrc = false;
babelConfig.ignore = ['node_modules/**', 'test/**'];
babelConfig.presets[0][1].modules = 'commonjs';
register(babelConfig);
```

`package.json`

```json
  "ava": {
    "require": [
      "./test/_register",
      "@babel/polyfill"
    ]
  }
```

最终的配置这样就可以了. 需要注意的是, 这里 AVA 会读取 `.babelrc` 来处理测试代码, 如果希望 AVA 对测试代码的处理和打包的处理不一样的话, 还是需要单独为 AVA 配置 babel. 即 `package.json` 中改成这样.

```json
  "ava": {
    "require": [
      "./test/_register",
      "@babel/polyfill"
    ],
    "babel": {
      "testOptions": {
        "babelrc": false,
        "plugins": [
          "array-includes"
        ],
        "presets": [
          [
            "@babel/env",
            {
              "loose": true,
              "modules": "commonjs"
            }
          ]
        ]
      }
    }
  }
```

其它不变. 相当于我们在三个地方配置了 babel, `.babelrc` 用来配置处理 Rollup 的打包, `package.json` 中 AVA 的 `babel` 字段配置 AVA 如何用 babel 处理测试代码, `test/_register.js` 中 `@babel/register` 的选项用来配置如何用 babel 处理测试代码中引入的项目代码, 大部分时候, 它应该是和打包的配置一致的, 除了会处理 ES6 module, 而 AVA 对测试代码的处理则可能不一致, 坏的情况下还是要维护两份 babel 配置还是比较麻烦的.

另外需要注意的是, AVA 默认用到了自己的l两个 presets `@ava/stage-4` 和 `@ava/transform-test-files` 来实现对 power-assert 的支持, 如果覆盖了 AVA 的 babel 配置, 不确定对这个是否会有影响, 如果有的话, 记得手动在覆盖的配置中加上这些 presets.



### 参考资料

* https://github.com/avajs/ava/blob/v1.0.0-rc.1/docs/recipes/babel.md
* https://github.com/avajs/ava/issues/1767
* https://github.com/avajs/ava/issues/1139