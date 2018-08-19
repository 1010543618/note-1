这里简单罗列一些模块的细节吧.

* 模块中的代码默认运行在严格模式下

* 模块作用域中的变量都不会被添加到全局作用域

* 模块顶层作用域中的 `this` 是 `undefined`

* 模块中不支持 HTML 注释

* `export` 导出的内容必须要有标识符, 即变量名

* `export default` 可以导出匿名的变量/函数/class 等

* `export` 的语法有以下这些

  ```javascript
  export { name1, name2, …, nameN };
  export { variable1 as name1, variable2 as name2, …, nameN };
  export let name1, name2, …, nameN; // also var, const
  export let name1 = …, name2 = …, …, nameN; // also var, const
  export function FunctionName(){...}
  export class ClassName {...}
  
  export default expression;
  export default function (…) { … } // also class, function*
  export default function name1(…) { … } // also class, function*
  export { name1 as default, … };
  
  export * from …;
  export { default } from …;
  export { name1, name2, …, nameN } from …;
  export { import1 as name1, import2 as name2, …, nameN } from …;
  ```

  需要注意的是第一种, 它不是导出一个对象, 因为 `export` 不能导出匿名的变量, 这里更像是一个对象解构(语法一样), 它导出了多个变量, 而第二种也一样, 将变量导出为指定的 name, 而最后四种则是直接将其他模块的内容导出, 省去了 `import` 再导出这样的步骤. 需要注意的是, `export * from` 这样的只会导出其他模块的命名内容, 而不导出其他模块的 `default`, 所以需要 `export {default} from`

* `import` 的基本语法.

  ```javascript
  import defaultExport from "module-name";
  import * as name from "module-name";
  import { exportName } from "module-name";
  import { exportName as alias } from "module-name";
  import { exportName1 , exportName2 } from "module-name";
  import { exportName1 , exportName2 as alias2 , [...] } from "module-name";
  import defaultExport, { exportName [ , [...] ] } from "module-name";
  import defaultExport, * as name from "module-name";
  import "module-name";
  var promise = import(module-name);
  ```

  需要注意的是, 导入时, 默认值必须排在非默认值之前, 就像第七条和第八条那样.

  另外, 尽管 `import {a, b} from 'module.js'` 看上去像是一个解构赋值, 但是并不是, 所以你不能指望下面这种情况是正确的.

  ```javascript
  // a.js
  export default {
      a: 1,
      b: 2
  };
  
  // b.js
  import {a, b} from 'a.js'
  // 这里 a b 都是 undefined
  ```

* 使用 `import` 导入绑定标识符和 `const` 是一样的, 即我们不能修改一个 `import` 导入的变量名的指向, 也不能在 `import` 导入之前使用对应的变量名(临时死区), 这也意味着, 如果导出的是一个基本类型, 那导入的模块里是不能修改变量的值的, 然而另一方面是, 如果导出模块提供了函数来修改另一个导出的变量, 则导入模块中通过函数来修改对应变量时, 也会反映到导出模块的变量上

* 不论 `import` 导入同一个模块多少次, 该模块中的代码只执行一次

* `export` 和 `import` 都必须在其他语句和函数之外使用, 换句话说, `export` 和 `import` 语句必须处于当前文件的最顶层作用域, 这也意味着不存在条件导入或条件导出这样的事, 比如 `if(true) import {a} from 'a.js'`, 当然动态导入还是可以根据条件来的

* 浏览器环境下的模块使用 `<script type="module">` 引入, 模块可以是内联也可以是外部文件, 但是无论哪个, 它都符合上面的要求, 比如模块中的变量不暴露到全局

* 对于外部模块, 默认是 `defer` 加载, 必须整个依赖树加载完才开始执行

* 浏览器如果不能识别 `<script type="module">` 的话, 则它也会认为是数据块, 并忽略掉 `src`, 这样就相当于浏览器如果不识别 `<script type="module">` 的话, 则不会下载模块文件, 也不会报错, 具有向后兼容性

* 多模块入口的话(即多个 `<script type="module">`), 按照它们 DOM 顺序执行, 无论是外部模块还是内联模块

* `async` 的模块之间也不保证执行顺序

* 引入模块的路径必须是绝对路径或 `/` `./` `../` 这样的相对路径, 相对路径是相对 URL 的路径, 不是物理路径, 所以不存在 `import {a} from 'a.js'` 这样的, 会报错

* 其他相关参考 [script标签的一些细节](./script标签的一些细节.md)

* Worker 相关到时候再写, TODO



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/export
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/import.meta
* https://zhuanlan.zhihu.com/p/40733281
* 深入理解 ES6