* babel 的转换通过插件(plugins)完成的

* 官方插件都以 @babel 为 scope

* presets 是一组插件的集合, 预设了一些插件

* 配置文件可以是 `.babelrc` 也可以是 `babel.config.js` 也可以是 `.babelrc.js` 也可以是 `package.json` 中的一个 `babel` 字段

* 现在推荐用 `preset-env` 了, 以前的 `babel-preset-es2015` 之类的不推荐了, 也不推荐 `babel-preset-stage-0` 这样的了

* `@babel/preset-react` 这样的可以简写成 `@babel/react`

* `babel-` 这样的包也都可以写成 `@babel/`

* 插件也可以从 `@babel/plugin-transform-arrow-functions` 简写成`@babel/transform-arrow-functions`, 插件名带有 `babel-plugin-xxx` 的, 都可以简写成 `xxx`

* `babel-preset-xxx` 的 preset 也可以简写成 `xxx`

* 插件主要有两类, 一类是解析用的插件, 比如解析 jsx 的插件, 一类是转换用的插件, 前者在 `parserOpts.plugins` 中配置, 作为 parser 的插件, 后者直接在 `plugins` 中配置

* plugins 和 presets 在配置中声明的顺序是有意义的

  * 插件从前往后(数组顺序)执行
  * presets 从后往前执行
  * plugins 总是比 presets 先执行

* 配置插件就直接用字符串, 配置插件及插件选项用 `[<string>, <options>]`

  ```json
  {
      "plugins": [
          "pluginA",
          ["pluginB", {}]
      ]
  }
  ```

* presets 配置也像插件一样可以指定选项

  ```json
  {
      "presets": [
          "presetA",
          ["presetB", {}]
      ]
  }
  ```

* 插件开发参考 https://github.com/jamiebuilds/babel-handbook

* 定义自己的 presets 参考这里 https://babeljs.io/docs/en/presets

* 常用选项 `presets`, `plugins`, `sourcesMaps`, `exclude`, `env`, 具体看这里 https://babeljs.io/docs/en/options

* `preset-env` 常用选项 `modules` (通常置为 `false` 以便 tree shaking), `loose` 宽松模式, 即不严格按照语义转换代码, 比如 class, 某些程度上会减少转换后的代码大小, `useBuiltIns`, 具体看这里 https://babeljs.io/docs/en/babel-preset-env#options

* 大部分时候会用 `transform-runtime` 而不是 `polyfill` 的插件, 具体配置看 https://babeljs.io/docs/en/babel-plugin-transform-runtime

* `tranform-runtime` 不能转换 `[1, 2, 3].includes(1)`, `'123'.includes('1')` 这样的代码