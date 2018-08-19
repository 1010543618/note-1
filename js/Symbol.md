#### Symbol 是什么

`Symbol` 是 ES6 引入的新类型, 并且它**是一个基本类型**, 所以我们**不能通过 `new Symbol()` 来创建一个 `Symbol` 的实例, 会报错**. 要创建一个 `Symbol` 的实例, 我们只能通过 `Symbol()`.

```javascript
var s = Symbol();
```

调用 `Symbol()` 方法会返回一个 `Symbol` 实例, 那 `Symbol` 是什么呢? 其实可以简单理解为它是另一种形式的字符串, 是一个 uuid, 或者某个 hash 值, 所以**每一个 `Symbol` 实例都是唯一的**. 即

```javascript
var s0 = Symbol(), s1 = Symbol();
console.log(s0 === s1); // false
```

`Symbol()` 方法支持一个可选的描述字符串.

```javascript
var s = Symbol('test');
```

但这个字符串的作用也就仅限描述了, 方便调试. 所以下面这样是不相等的.

```javascript
var s0 = Symbol('test'), s1 = Symbol('test');
console.log(s0 === s1); // false
```

**它并不是像某个 hash 函数一样, 接受的值一样则得到的值也一样**. 可能有人会关心它怎么实现的, 怎么就确保了唯一? 会不会产生碰撞? 其实这种问题不是我们需要关心的, 实现细节那是编译器厂商的事情, 每个厂商也可能不同, 我们就当有个上帝, 他造出的每个 `Symbol` 实例都不一样, 世界上不存在两个一样的 `Symbol` 实例. 而如果真的产生了碰撞, 那只能是厂商的实现有 bug, 可以去提交 bug 了.

另外, 这个描述字符串可以从 `Symbol` 实例的 `toString()` 中得到, 如果你希望知道一个 `Symbol` 的描述字符串的话.

```javascript
var s = Symbol('test');
console.log(s.toString()); // Symbol(test)
```

前面我们说过它是基本类型了. 所以

```javascript
var s = Symbol();
console.log(typeof s); // symbol
```

而另一方面, 因为它是基本类型, 所以不要指望对它使用 `instanceof`.

```javascript
var s = Symbol();
console.log(s instanceof Symbol); // false
```



#### Symbol 的作用

那么 `Symbol` 有什么作用? 为什么要搞出这么一个类型来? 之前我们已经提到了可以简单地理解 `Symbol` 为另一种字符串, 那么字符串可以作为对象属性名, 同样, `Symbol` 也可以.

```javascript
var key = 'name';
var obj = {
    [key]: 'test'
};
// or
obj[key] = 'test';
```

那 `Symbol` 作为属性名, 也是可以的.

```javascript
var key = Symbol('name');
var obj = {
	[key]: 'test'
};
console.log(obj[key]); // test
```

准确来说, `Symbol` 可以用于所有使用可计算属性名的地方, 或 `Object.defineProperty()` 或 `Object.defineProperties()`.

```javascript
var key = Symbol('name');
var obj = {
	[key]: 'test'
};
// or
var key = Symbol('name');
var obj = {};
Object.defineProperty(obj, key, {
	value: 'test'
});
// or
var key = Symbol('name');
var obj = {};
Object.defineProperties(obj, {
	[key]: {
		value: 'test'
	}
});
```

所以这又有什么用? 我们明明已经有字符串了, 这只不过是另一种形式的字符串而已.

借助 `Symbol` 的唯一性, 其实我们可以做到许多以前做不到的事情, 比如实现私有变量.

```javascript
const key = Symbol('name');
export default {
	[key]: 'test'
};
```

在以前, 我们要实现一个单例的私有变量, 通常需要借助闭包特性, 使用 IIFE 或者模块模式等, 代码冗余, 而现在这样, 短短几行就有了一个私有变量. 当然也有人会说, 这个属性还不是挂在对象上, 完全暴露在外面, 只要有这个 `key` 就能访问到了. 的确, 但是关键就是想要有这个 `key` 并不容易, 只要实现者不暴露, 外部就无法拿到属性的值.

而基于类的私有变量, 在以前实现起来几乎是不可能, 而现在通过 `Symbol` + `WeakMap` 也有了解决方案, 当然这里不是讨论如何实现私有变量的, 所以就不展开了.

又比如, 当我们有些时候实现一些配置的时候, 考虑如下例子.

```javascript
var apis = {
    getBooks() {...},
    getBooks() {...}
};
module.exports = apis;     
```

假如这是一个基于 js 对象的 API 的配置文件, 里面有上百个 API, 多人协作的时候, 没有人会在添加新 API 的时候有耐心看完里面到底有哪些 API, 于是同事 A 和同事 B 在两个不同业务中都命名了 `getBooks` 的 API, 于是测试的时候发现某个 API 的数据不对, debug 半天发现原来是命名冲突了, 一个 API 覆盖了另一个(注1), 于是我们不得不拆分成两个命名空间, 让 A B 两人分别维护各自命名空间中的 API.

```javascript
var apisA = {
    getBooks() {...}
};
var apisB = {
    getBooks() {...}
};
```

这的确解决了问题, 但是这样的划分十分简单粗暴, 这是基于人的划分, 而不是基于业务逻辑的划分, 万一某同事离职了呢? 他的命名空间中的 API 要合并到其他人的命名空间下吗? 合并了是否又会导致错误呢? 这种方案并没有杜绝掉冲突的可能性, 还带来了无意义的命名空间的划分.

*注1: 非严格模式下对象出现同名属性不会报错, 而是一个覆盖另一个, 在以前具体怎么覆盖取决于具体实现, 在某一个版本的严格模式下, 对象有同名属性会报错, 后来 ES6 又改为严格模式也不报错了, 并且规定了覆盖顺序是最后一个同名属性的覆盖前面的*

而有了 `Symbol`, 我们可以这样写.

```javascript
var apis = {
	[Symbol('getBooks')]() {
		console.log('test0')
	},
	[Symbol('getBooks')]() {
		console.log('test1')
	}
};
```

虽然麻烦了一点, 但它确保了不会产生冲突, 我们也不需要根据人来划分命名空间. 当然, 实际业务中如果一个配置文件非常长了还是考虑分割一下, 这里只是举个例子.



#### Symbol 的共享

OK, 我们已经知道 `Symbol` 是什么以及它的作用了. 但是我们发现一个问题, 那就是**要想获取一个 `Symbol` 为 key 的属性, 首先你需要这个 `Symbol` 实例**. 那如果我们在不同模块中都要获取某个单例对象的 `Symbol` 属性, 岂不是要跨模块传递这个 `Symbol` 实例? 于是每个文件都 `import` 了一堆的 `Symbol` 进来, 只为能够获取到某些对象的属性? 这显然是不现实的, 所以规范也考虑到了这点, 为我们提供了一个全局的容器.

##### `Symbol.for()`

`Symbol.for()` 方法接受一个字符串参数, 用来创建和获取一个指定描述的 `Symbol` 实例.

```javascript
var s0 = Symbol.for('s0');
console.log(s0.toString()); // Symbol(s0)
```

这句我们获取了一个描述为 s0 的 `Symbol` 实例, 这里我们并不关心它到底是创建了一个描述为 s0 的 `Symbol` 还是从容器中获取了这个描述为 s0 的 `Symbol`, 因为 **`Symbol.for()` 会在容器中不存在该描述的 `Symbol` 实例时创建一个实例, 而如果容器中存在, 则直接返回该描述的 `Symbol` 实例**. 容器相当于一个全局的 hash map, 所以我们可以通过一个描述字符串来跨模块获取同一个 `Symbol` 实例.

```javascript
// module A
var a = Symbol.for('s');
// module B
var b = Symbol.for('s');
// module C
console.log(a === b); // true
```

这样我们就不需要在每个模块引入一些 `Symbol` 实例了, 不过这也意味着, **容器中不存在具有同一描述的多个 `Symbol`, 换句话说, 描述字符串和容器中的 `Symbol` 实例是一一对应的**. 而在容器之外创建的多个 `Symbol` 实例是可以具有相同的描述的(但它们不相等).



##### `Symbol.keyFor()`

我们已经可以跨模块获取容器中的 `Symbol` 实例了, 但有时候我们从容器中拿到了一个 `Symbol` 实例, 却不知道它的描述字符串(比如用户通过函数参数传递了一个 `Symbol`), 我们希望知道这个 `Symbol` 实例的描述字符串, 这样就可以缓存起来下次自己直接去容器中找就行. 所以标准也为我们提供了一个 `Symbol.keyFor()` 方法, 用来根据一个 `Symbol` 实例去查找对应的描述字符串.

```javascript
var s = Symbol.for('test');
var desc = Symbol.keyFor(s); // test
```

但是它**只能查找容器中存在的 `Symbol` 实例的描述字符串, 如果容器中不存在该 `Symbol` 实例, 则返回 `undefined`**.

最后补充一点, **这个容器是跨 window 跨 worker 共享的.**



#### 遍历 Symbol 属性

如果一个对象属性的 key 是 `Symbol` 类型的话, 则 `for...in` `Object.keys()` `Object.getOwnPropertyNames()` 以及 `JSON.stringify()` 都无法遍历到, 不过好在标准为我们提供了一个 `Object.getOwnPropertySymbols()` 来获取.

`Object.getOwnPropertySymbols()` 接受一个对象参数, 返回一个数组, 数组包含该对象的所有 `Symbol` 实例, **包括不可枚举的属性的 `Symbol`**.



#### 类型转换

js 中几乎所有类型都可以参与运算, 会被执行隐式类型转换, 通过调用 `toString()` `valueOf()` 等方法, 比如

```javascript
'123' + 4 // ok
```

这些都是合法的, 但是 `Symbol` 呢? `Symbol` 作为一个基本类型, 是否也可以参与运算? 答案是基本上不可以.

```javascript
var s = Symbol('test');
s + 1; // error
s + 'test'; // error
s / 2; // error
```

**`Symbol` 只能参与除逻辑运算, `Symbol` 值参与其他运算都报错, 所有 `Symbol` 值都表现为 `true`**.

另外, 宽松相等性判断的时候, 下面这样是相等的.

```javascript
var s = Symbol();
Object(s) == s; // true
```





#### Well-known symbols

除了上面的作用, `Symbol` 还为我们暴露了一些底层细节, 让我们有机会去修改这些底层细节. `Symbol` 对象上包含了许多内置的 `Symbol` 实例, 其中最常用的大概是 `Symbol.iterator` 了, 不过这里不会多做介绍.

像 `Symbol.iterator` 这样的 `Symbol` 对象上的属性, 都被称为 Well-known symbols, 它们都暴露了一些底层的功能.

这里拿深入理解 ES6 上面的例子来说明好了.

每个函数都有一个 `Symbol.hasInstance` 的方法, 用于确定对象是否为函数的实例, 即

```javascript
obj instanceof Array;
// 等价于
Array[Symbol.hasInstance](obj);
```

于是现在我们可以修改 `instanceof` 的行为.

```javascript
function Person() {
	
}
Object.defineProperty(Person, Symbol.hasInstance, {
	value: function (v) {
		return true;
	}
});

console.log([] instanceof Person); // true
```

比如这里让我们自己的构造函数也能看起来像是数组的父类一样, 同样, 我们可以借助它修改一些内建对象的 `instanceof` 行为, 比如 `Array` 等, 当然不建议这么做. 注意为什么要使用 `Object.defineProperty()`, 因为有些属性可能是只读的, 只能通过它来修改.

总的来说, `Symbol` 的出现使得规范可以标准化许多底层的行为, 并提供了很多 Well-known symbols 让我们有机会去修改这些底层行为, 但大部分时候我们不需要去修改它们.

具体有哪些 Well-known symbols 可以参考 MDN.



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Symbol
* 深入理解 ES6