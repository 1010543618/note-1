* `ChildNode.remove()` 元素将自身从 DOM 中删除(https://developer.mozilla.org/en-US/docs/Web/API/ChildNode/remove), 再也不用通过父元素删除了 `Node.removeChild()`
* `elem.classList` 再也不用通过 className 操作元素的 class了 (https://developer.mozilla.org/en-US/docs/Web/API/Element/classList)
* `document.currentScript` 获取当前 js 所属的 `<script>` 元素
* `Function.name` 获取函数名
* `Object.getPrototypeOf()` 获取对象的原型, 当然也可以直接 `obj.__proto__`, 不过前者更标准一点
* `Object.prototype.hasOwnProperty()` / `obj.hasOwnProperty()` 判断属性是否属于对象自身而非原型, 很重要的一点是它不会向上查找原型链, (据说)是唯一一个处理属性而不查找原型链的方法, 在需要排除掉继承来的属性时有用
* `isFinite()` / `isNaN()` / `Number.MAX_VALUE` / `Number.MIN_VALUE` / `Number.MAX_SAFE_INTEGER` / `Number.MIN_SAFE_INTEGER`
* 16 进制转义序列(以 `\x` 开头), eg. `'\xA9'`, unicode 转义序列(以 `\u` 开头接码点, 码点至少 4 字符), eg. `'\u00A9'`
* `Object.getOwnPropertyNames()` 获取对象所有属性的 key, 包括不可枚举的属性
* `Object.preventExtensions()` 禁止为对象添加新属性
* `JSON.stringify()` 的第二个参数的数组参数和函数参数
* `obj.constructor` 属性, 指向生成对象的构造函数, 在运行时不知道对象的构造函数却希望调用该对象构造函数时有用
* `obj.isPrototypeOf()` 判断对象是否是另一个对象的原型
* `obj.propertyIsEnumerable()` 用来判断对象属性是否可以枚举
* `[].reduceRight()` reduce 常用, 但是总是会忘记还有个 reduceRight
* `frames`/`window.frames`
* `top`/`window.top`
* `Node.contains()` 用来检测一个节点是否是另一个节点的子节点, 兼容性很好
* `document.onvisibilitychange`/`document.visibilityState` 通常用这两个结合来判断页面是否可见, 即当前 Tab 是否是 active 的
* `location.reload()`/`location.reload(true)` 强制浏览器刷新, 前者可能从缓存获取, 后者强制从服务器获取
* `ChildNode.remove()` 将节点自身从文档中移除, 虽然知道有 `Node.removeChild()`, 但这个显然用起来方便些, 不过可惜 IE 不支持, 另外其实还有 `ChildNode.before()`/`ChildNode.after()`/`ChildNode.replaceWith()` 不过这几个都要比较高版本的浏览器了, Chrome 54+/FF 49+
* `document.title`/`document.domain`/`document.referrer` 其中 title 和 domain 可写, domain 用来做某些跨域姿势, 不过只能设置为更上级的域, 并且一旦设置为更高级的域, 就不能再设置为低级的域
* `document.getElementsByName()` 在某些时候有点卵用, 那就是获取一组 `name` 相同的表单元素
* HTML 元素的标准属性都可以直接通过 DOM 对象取得, 也可以通过它们设置, eg. `elem.title`/`elem.id` /`elem.className`/`elem.src`/`script.async` 等等, 并且它们的兼容性也很好, 虽然平时都是用 `getAttribute()`/`setAttribute()`, 不过熟悉的话, 这样少敲几个字符
* `elem.matchesSelector()` 判断一个元素是否与给定选择器匹配, `querySelector()` 和 `querySelectorAll()` 比较常用, 不过这个平时没怎么用
* `elem.children`/`elem.firstElementChild`/`elem.lastElementChild`/`elem.previousElementSibling`/`elem.nextElementSibling` 是 `elem.childNodes`/`elem.firstChild`/`elem.lastChild`/`elem.previousSibling`/`elem.nextSibling` 的元素版, 其中 `elem.children` 是 `HTMLCollection`, 而 `elem.childNodes` 是 `NodeList`, 不过它们都是实时的. 这些都是 IE9+(IE8 也支持 `children`, 不过会包含注释节点)
* `document.activeElement` 获取当前获得焦点的元素, 这个兼容性很好
* `elem.scrollIntoView()` 如果参数为 true, 则窗口滚动至元素顶部与视口顶部(尽可能)平齐, 如果 false, 则元素尽可能全部出现在视口, 基本支持可以到 IE8
* `event.type` 在某些情况下有那么点用, 比如想通过一个函数处理不同类型的事件
* `document.createEvent()` 有些时候有点用
* `elem.offsetParent` 获取元素的包含块元素

