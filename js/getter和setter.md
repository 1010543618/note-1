在过去, 我们要定义 getter 和 setter 通常是借助 `Object.defineProperty()` 或 `Object.defineProperties`.

```javascript
var a = {};
Object.defineProperty(a, 'name', {
	get: function () {
		return this.__name;
	},
	set: function (val) {
		this.__name = val;
	}
});
// or
var a = {};
Object.defineProperties(a, {
	name: {
		get: function () {
			return this.__name;
		},
		set: function (val) {
			this.__name = val;
		}
	}
});
```

这里先简单介绍 `Object.defineProperty()`, 对于 `Object.defineProperties()` 也类似.



####Object.defineProperty()

语法

```javascript
Object.defineProperty(obj, prop, descriptor)
```

* `obj` 对象, Object
* `prop` 对象的属性名, String/Symbol
* `descriptor` 属性描述符, Object

根据属性描述符对象的属性可以分为数据描述符(data descriptors)和访问描述符(accessor descriptors). 属性描述符可以有以下属性:

* `configurable` 默认值 false, 注, 也影响 `delete`, false 时属性不能被 `delete`(无效但不报错)
* `enumerable` 默认值 false, 属性是否可以被 `for...in` `Object.keys()` 获取
* `value` 默认值 undefined
* `writable` 默认值 false, 注 `delete` 与它无关
* `get` 默认值 undefined
* `set` 默认值 undefined

其中数据描述符只可能包含 `configurable` `enumerable` `value` `writable` 中的一个或多个, 访问描述符只可能包含 `configurable` `enumerable` `get` `set` 中的一个或多个, 这意味着 `value` 或 `writable` 和 `get` 或 `set` 是互斥的, 即如果一个属性描述符对象既包含 `value` 又包含 `get` 则会报错.

需要注意的是这种情况.

```javascript
var Person = (function () {
	function P(params) {}
	var name;
	Object.defineProperty(P.prototype, 'name', {
		get() {
			return name;
		},
		set(val) {
			name = val;
		}
	});
	return P;
})();

var a = new Person();
var b = new Person();
a.name = 'test';
console.log(b.name);
```

因为这个 getter setter 是定义在原型上的, 自然 getter setter 方法是共享的, 还共享了同一个 name 属性, 显然这不是我们期望的结果, 不过正常人也不会这么写. 下面的才是正确的路子.

```javascript
var Person = (function () {
	function P(params) {}
	Object.defineProperty(P.prototype, 'name', {
		get() {
			return this.__name;
		},
		set(val) {
			this.__name = val;
		}
	});
	return P;
})();

var a = new Person();
var b = new Person();
a.name = 'test';
console.log(b.name);
```

这里的细节是, getter setter 方法的 this 指向不是属性描述符对象, 而是实例本身.

另外, `Object.defineProperty()` 可能会抛出异常(比如属性描述符混用了 get 和 value), 必要时考虑加上 try-catch.



#### get/set 语法

现在我们可以用 get/set 语法来实现 getter/setter, 语法比较简单.

```javascript
var obj = {
    get name() {
        return this.__name;
    },
    set name(val) {
        this.__name = val;
    }
}
// or
var name = 'test';
var obj = {
    get [name]() {
        return this.__name;
    },
    set [name](val) {
        this.__name = val;
    }
}
// or
var obj = {
    get 'name'() {
        return this.__name;
    },
    set 'name'(val) {
        this.__name = val;
    }
}
// or
class Person {
	get name() {
		return this.__name;
	},
	set name(val) {
		this.__name = val;
	}
}
```

通过 get/set 定义的属性可以被 `delete` 删除. 其中 get 不能带参数, set 只能带一个参数, 否则报错.



#### 两者的其他共同点

还有一个细节是, 它们都可以拦截到函数调用. 即以下例子都是 OK 的.

```javascript
var a = {
	name: 'test',
	get test() {
		return function () {
			console.log(this.name);
		}
	}
};
a.test();
// test

var a = {
	name: 'test',
};

Object.defineProperty(a, 'test', {
	get() {
		return function () {
			console.log(this.name);
		}
	}
});

a.test();
// test
```

个人理解这更像是拦截了一个左值查询(LHS)的操作, 即我们把函数调用 `a.test()` 分成两个部分, 先对 `a.test` 进行求值, 再对该值进行函数调用, 于是最终我们的匿名会被调用. 另一个值得注意的是, 我们返回的匿名函数的 `this` 最终还是绑定到了对象上.

另外, 这里简单地补充一下, 尽管看上去它们都是可以拦截函数调用的, 但是这个过程是相对静态的(相对于 Proxy 来说), 即我们必须在调用属性方法之前就使用这些 getter/setter 定义这些属性方法, 否则会出现错误. 换句话说, 我们在调用方法时, 方法必须是存在的. 尽管你可以说, 我们可以在运行时通过 `Object.defineProperty()` 来为对象定义方法怎么就静态了? 然而我们必须小心翼翼地确保在调用方法时, 已经使用 `Object.defineProperty()` 定义过我们需要的方法了, 否则就会出错. 这看上去理所应当, 毕竟没有这个方法你怎么能够调用它呢? 所以这整个顺序需要作为开发者的我们来确保, 而不能是对象在自己的方法被调用时知道自己是否存在对应方法. 不过之后我们会接触到更为强大的反射 API -- Proxy, 就像对象照了镜子一样, 知道自己有哪些方法并在没有的时候创建它再给出来.



#### 两者区别

基本上来说, 只有一点点区别.

* ` Object.defineProperty()` 可以在对象实例化之后定义 getter/setter, get/set 语法在对象实例化时就定义了 getter/setter, 对于需要根据条件定义 getter/setter 的场景还是得用 ` Object.defineProperty()`
* 在使用 class 的情况下, 使用 get/set 的对象不能通过 `Object.getOwnPropertyDescriptor` 拿到属性描述符(undefined), 而使用 `Object.defineProperty()` 的对象则可以通过 `Object.getOwnPropertyDescriptor` 拿到属性描述符



#### 一些实践中的问题

在前面的例子中, 我们的 getter/setter 都类似下面这样.

```javascript
var obj = {
    get name() {
        return this._name;
    },
    set name(val) {
        this._name = val;
    }
};
```

看上去并没有什么毛病, 但是我们默认了 `_name` 是一个私有属性, 那意味着我们不希望它暴露出来, 然而大多数时候, 在设计一个对象或者 class 时, 我们都没有仔细考虑过这个问题, 所以这里的 `_name` 是可以在外部访问到的, 并且可以被 `for...in` `Object.keys()` 枚举, 显然这不会是我们期望的. 所以在写 getter/setter 的时候, 最好先确认下这些内部属性是否要暴露, 以及是否可以被枚举.



#### 补充

在 IE9 之前, 也可以用 `__defineGetter__()` 和 `__defineSetter__()` 来实现, eg.

```javascript
var obj = {};
obj.__defineGetter__('name', function() {
    return this._name;
});
obj.__defineSetter__('name', function(val) {
    this._name = val;
});
```





#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperties
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty/Additional_examples
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/get
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/set