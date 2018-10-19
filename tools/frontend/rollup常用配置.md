Rollup 配置比较简单, 具体看文档, 这里列几个个人觉得比较重要也比较常用的配置.



### 配置选项

* `input` 必需的, 不用说
* `external` 其实不常用, 不过特定情况下会需要, 要知道这东西是做什么的
* `plugins` 插件, 几乎也是必需的
* `output.file` 必需的
* `output.dir` 只在 `experimentalCodeSplitting` 开启时会用到, 一般用不到
* `output.format` 必需的
* `output.name` 打包 umd 模块的时候导出的全局变量名, 需要注意的是这个和 `export default` 冲突, 即如果 `export default` 存在则不能使用 `output.name`
* `output.globals` 通常配合 `external` 使用, 一般用不到
* `output.banner`/`output.footer` 加一些版本号, 许可证, 作者等信息时有用
* `output.sourcemap` 生成 sourcemap, 不过不知道和 uglifyJS 和 babel 的 `sourcemap` 选项是否冲突, 测试之后只要用 Rollup 的 `sourcemap` 选项就好, 插件的可以不用
* `output.sourcemapPathTransform` 这个比较重要, 如果你的源文件是 src/index.js, 打包的文件是 a.min.js, 那生成 sourcemap 之后在 Devtools 中 Ctrl+P 只能搜索 src/index.js 才能找到源文件, 而使用这个转换以后, 可以通过 Ctrl+P 搜索 a.js, 即转换 sourcemap 映射的路径
* `output.sourcemapFile` 指定生成的 sourcemap 文件名, 一般用不到
* `output.extend` 在打包 umd 模块时需要注意, 但是一般用不到
* `output.strict` 默认是 `true`, 即打包出来的模块是严格模式的
* `treeshake` 默认开启的
* `treeshake.pureExternalModules` 在有 `external` 的时候可能会用到, 表明外部依赖是否是 pure 的(无副作用), 不是要真的无副作用, 是你觉得它无副作用就行, 这样 Rollup 在做 tree shaking 的时候可以把它删掉
* `treeshake.propertyReadSideEffects` 这个就比较有用了, 可以告诉 Rollup 你的代码中任何对对象属性的右值查询都是无副作用的, 即 Rollup 担心获取属性值会触发 getter 从而不敢做 tree shaking, 默认是 `true` 即认为读取对象属性都是有副作用的, 个人大部分写库的时候都可以把它设成 `false`
* `acorn` 用来指定 Rollup 的 parser 选项, 一般用不到, 有空去看看 acorn 支持些什么选项, 也许会有用
* `context` 用来指定全局作用域的上下文, 即如 `window` 之类, 只有你在全局使用了 `this` 的时候才会关心它, 一般用不到
* `moduleContext` 和 `context` 类似, 但是它是指定每个模块文件的全局上下文的, 一般用不到
* `experimentalDynamicImport` 支持 `import().then()` 动态导入, 一般用不到
* `experimentalCodeSplitting` 代码分割, 后面的实验特性都是和它有关的, 有时间还需要具体看下



### 插件

插件可以看这里 https://github.com/rollup/awesome

个人常用插件

* rollup-plugin-uglify, 压缩代码
* rollup-plugin-babel-minify, 压缩代码, 但是它和 uglify 的区别是, uglify 只能压缩 ES5 的代码, 即 ES5未压缩 -> ES5 压缩, 而它可以压缩 ES6 代码, 即 ES6 未压缩 -> ES6 压缩, 如果你不想兼容低版本浏览器, 用它 + module + sideEffects 会大大减少打包到最终被引入后的包的大小
* rollup-plugin-json, 支持导入 JSON, 即 `imort 'xxx.json'` 是 OK 的, 没有它则不能这样导入
* rollup-plugin-babel, babel 不用说
* rollup-plugin-node-resolve, 支持以 node 查找包路径的算法来找包, 即 `import 'xxx'` 是和 node 一样从依次从相对路径, 逐级往上的 node_modules 中查找包, 但是包必须是 ES6 module 的
* rollup-plugin-commonjs, 支持将 CommonJS 模块以 ES6 模块形式导入, 通常配合上面的用, 即 `import 'xxx'` 中 xxx 可以是一个 CommonJS 模块