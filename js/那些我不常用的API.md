* `ChildNode.remove()` 元素将自身从 DOM 中删除(https://developer.mozilla.org/en-US/docs/Web/API/ChildNode/remove), 再也不用通过父元素删除了 `Node.removeChild()`
* `Element.classList` 再也不用通过 className 操作元素的 class了 (https://developer.mozilla.org/en-US/docs/Web/API/Element/classList)
* `document.currentScript` 获取当前 js 所属的 `<script>` 元素
* `Function.name` 获取函数名
* `Object.getPrototypeOf()` 获取对象的原型, 当然也可以直接 `obj.__proto__`, 不过前者更标准一点
* `Object.prototype.hasOwnProperty()` / `obj.hasOwnProperty()` 判断属性是否属于对象自身而非原型, 很重要的一点是它不会向上查找原型链, (据说)是唯一一个处理属性而不查找原型链的方法, 在需要排除掉继承来的属性时有用
* `isFinite()` / `isNaN()` / `Number.MAX_VALUE` / `Number.MIN_VALUE` / `Number.MAX_SAFE_INTEGER` / `Number.MIN_SAFE_INTEGER`
* 16 进制转义序列(以 `\x` 开头), eg. `'\xA9'`, unicode 转义序列(以 `\u` 开头接码点, 码点至少 4 字符), eg. `'\u00A9'`
* `Object.getOwnPropertyNames()` 获取对象所有属性的 key, 包括不可枚举的属性
* `Object.preventExtensions()` 禁止为对象添加新属性

