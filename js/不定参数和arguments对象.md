#### `arguments`

在过去, `arguments` 常常被来实现函数的多态. 关于它的特性/用法已经有很多资料详细地说明过了. 当然这里也还是会俗套地简单介绍.

`arguments` **自身不是一个数组, 而是一个对象**, 只不过具有数字索引和 `length` 属性, 通常我们把这叫做 Array-Like 对象(其实只要有 `length` 的都是 Array-Like 对象).

`arguments` 的一个特性是**在非严格模式下, 会跟踪参数的变化**, 即 `arguments` 中元素的值会随参数的变化而变化, 对它们的修改也会修改到参数.

```javascript
function test(a) {
	a = 10;
	console.log(arguments[0]);
	arguments[0] = 20;
	console.log(a);
}

test(1);
// 10
// 20
```

`arguments` 还有以下几个属性:

* `arguments.callee` 指向当前指向的函数, 即 `arguments` 所在的函数自身, **在严格模式下不能使用这个属性**, 会报错
* `arguments.length` 实际传入的参数个数, 与之对应的是 `Function.length`, 函数期望传入的参数个数, 即参数列表中参数的个数(不包括不定参数)
* `arguments.caller` 废弃
* 一个迭代器, 即 `arguments` 是可迭代的

关于为什么严格模式不让用 `arguments.callee`, 甚至是任何的 `caller`, 简单来说, 因为它们不利于对函数进行内联或尾调用的优化. 具体可以参考[这里](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/arguments/callee).

##### 一个去优化行为

毫无疑问, 直接将 `arguments` 传给其他函数使用是不利于 JS 引擎进行优化的. 于是我们常常会将 `arguments` 转换成数组, 传给后续的函数作为参数使用. 像这样.

```javascript
var args = Array.prototype.slice.call(arguments);
// 或者这样
var args = [].slice.call(arguments);
```

不过这依然是一个不利于优化的行为, 正确的操作应该是这样.

```javascript
var args = (arguments.length === 1 ? [arguments[0]] : Array.apply(null, arguments));
```

可以看到, 其实使用 `arguments` 总是需要小心翼翼, 它和它的属性们总是很容易导致不利于解释器优化的行为, 所以建议是, 如果条件允许, 不要使用 `arguments` 和它相关的属性. 那我们用什么?

比如这个例子.

```javascript
function factorial(n) {
	return n <= 1 ? 1 : n * factorial(n - 1);
}

function calc(cb, n) {
	return cb(n);
}

console.log(calc(factorial, 3));
```

当然, 这样没什么问题, 但是如果我想给 calc 传入一个匿名函数, 而不是实现定义一个 factorial 函数, 那不是只能用到 `arguments.callee`? 我们可以这样.

```javascript
function calc(cb, n) {
	return cb(n);
}

console.log(calc(function factorial(n) {
	return n <= 1 ? 1 : n * factorial(n - 1);
}, 3));
```

 那如果我想把 factorial 赋值给其他变量, 再调用它呢? 也是一样的.

```javascript
var test = function factorial(n) {
	return n <= 1 ? 1 : n * factorial(n - 1);
}

function calc(cb, n) {
	return cb(n);
}

console.log(calc(test, 3));
```

那我们怎么处理不定个数的参数?



#### 新的选择 Rest parameters

通常翻译成不定参数. 不过我觉得理解成剩余参数更好一点. 语法像很多其他语言一样.

```javascript
function test(a, ...args) {
	console.log(args);
}

test(1, 2, 3);
// [2, 3]
```

我们显式地声明在函数参数列表中, 它是一个数组. Rest parameters 和 `arguments` 的区别主要有以下几点:

* Rest parameter 只处理剩余的参数(参数列表中没有对应名字的), `arguments` 则包含了所有参数
* `arguments` 是一个对象, Rest parameter 只是一个数组
* `arguments` 还带有其他属性, 如 `callee`

##### Rest parameters 可以使用解构赋值

```javascript
function test(...[a, b, c]) {
	console.log(a, b, c);
}

test(1, 2, 3);
// 1 2 3
```



##### 每个函数最多只能声明一个 Rest parameters, 并且只能放在参数列表末尾

##### Rest parameters 不能用于 setter 方法

```javascript
var obj = {
    set name(...args) {
        // ...
    }
}
// error
```

 

##### Rest parameters 不会参与到 `Function.length` 的计算

```javascript
function test(a, ...args) {
    // ...
}
console.log(test.length);
// 1
```



##### 无论是否使用 Rest parameters, `arguments` 总是包含所有参数

另外默认参数对 `arguments` 也是有影响的, 具体参考 [默认参数的一些细节](./默认参数的一些细节.md).



##### 带有 Rest parameters 参数的函数不能使用严格模式, 否则报语法错误

准确来说, 是如果函数参数带有以下几种的, 则函数都不能使用严格模式.

* 默认参数
* 参数解构
* 剩余参数(Rest parameters)

即下面这些都是不行的.

```javascript
function test(...args) {
	'use strict';
	console.log('test');
}

// or
function test(a = 1) {
	'use strict';
	console.log('test');
}

// or
function test({a, b}) {
	'use strict';
	console.log(a, b);
}
```





#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/arguments
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/arguments/callee
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Errors/Strict_Non_Simple_Params
* 深入理解 ES6