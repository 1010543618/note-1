这篇文章并不想讨论诸如「为什么不用 ES6 的 class」这样的问题, 所以那些「ES6 大法好」「都 8012 年了...」的可以退散了. 其实个人也很喜欢各种语法糖, 毕竟人生苦短, 语法糖也能有效提高生活质量. 然而 ES6 class 屏蔽了许多细节, 但基于原型链的继承机制却并没有改变, 可能会带来一些问题, 另一方面是我还是更喜欢精细控制一些, 所以这里我们主要讨论传统的 class 实现方式.

先让我们来考虑一个例子. 我们有一个 `Person` 类, `Person` 类的实例具有 `name`, `age` 两个属性, 其中 `name`, `age` 是公有的, 我们的 `Person` 还有一个 `sayHello` 的公有方法. 实现起来当然是很简单.

```javascript
function Person(name, age) {
	this.name = name;
	this.age = age;
	this.sayHello = function () {
		console.log(`Hello, I'm ${this.name}, I'm ${this.age} years old.`);
	}
}

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

a.sayHello();
b.sayHello();
// Hello, I'm aaa, I'm 18 years old.
// Hello, I'm bbb, I'm 19 years old.
```

然而我们很快发现事情不对, `sayHello` 作为函数表达式, 每次实例化 `Person` 的时候都会创建一个 `sayHello`, 当有很多个 `Person` 实例的时候, 这会浪费很多的内存. 所以我们希望 `sayHello` 是所有实例共享的. 在实现共享方法这一点上, 我们很容易想到的是把方法写在原型上, 当然, 还有另一种方式, 借助一个唯一的外部作用域.

```javascript
function Person(name, age) {
	this.name = name;
	this.age = age;
}

Person.prototype.sayHello = function () {
	console.log(`Hello, I'm ${this.name}, I'm ${this.age} years old.`);
}

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

a.sayHello();
b.sayHello();
```

或者这样

```javascript
var Person = function () {
	function Person(name, age) {
		this.name = name;
		this.age = age;
		this.sayHello = sayHello;
	}
	function sayHello() {
		console.log(`Hello, I'm ${this.name}, I'm ${this.age} years old.`);
	}
	return Person;
}();


var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

a.sayHello();
b.sayHello();
```

当然, 这里毫无疑问通过原型实现会更好一些, 起码我们可以少创建一个毫无意义的闭包(`sayHello` 到 IIFE 的闭包). 不过后面的写法也会有它的意义, 这个之后会看到.

然而我们并不希望把 `sayHello` 绑定细节暴露在我们的 class 外面, 起码我们希望它能够看起来更像是一个类, 毕竟你没见过其他语言中的方法写在 class 外部. 不过这个问题也很好解决, 我们把 `sayHello` 的绑定放在构造函数里面就好了.

```javascript
function Person(name, age) {
	var self = this instanceof Person ? this : Object.create(Person.prototype);
	
	self.name = name;
	self.age = age;
	if (typeof self.sayHello !== 'function') {
		Person.prototype.sayHello = function () {
			// 注意这里是 this 不是 self
			console.log(`Hello, I'm ${this.name}, I'm ${this.age} years old.`);
		};
	}

	return self;
}

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

a.sayHello();
b.sayHello();
```

**如果说我们需要实现的类只有公有变量和公有方法, 那我想这应该是最合适的方式了**. 需要注意的是, 我们这里实现了 new 无关的构造函数, 我们也可以在 `sayHello` 中使用诸如 `self.name` 这样的, 但显然这是有问题的.

```javascript
function Person(name, age) {
	var self = this instanceof Person ? this : Object.create(Person.prototype);
	
	self.name = name;
	self.age = age;
	if (typeof self.sayHello !== 'function') {
		Person.prototype.sayHello = function () {
			// 现在我们用 self
			console.log(`Hello, I'm ${self.name}, I'm ${self.age} years old.`);
		};
	}

	return self;
}

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

a.sayHello();
b.sayHello();
// Hello, I'm aaa, I'm 18 years old.
// Hello, I'm aaa, I'm 18 years old.
```

当我们只实例化一个对象的时候, 看起来似乎并没有什么毛病, 然而我们实例化了两个对象, 它们的 `name` 和 `age` 是一样的. 这里问题的关键是, 我们只在 `prototype` 上实例化了一次 `sayHello`, 并且是在第一次调用构造函数的时候实例化的, 所以在 `sayHello` 创建闭包的时候, 绑定的也只是第一次调用构造函数时的 `self`, 即我们的 a 对象, 然而 `sayHello` 作为所有实例共享的方法, 却只能拿到第一次调用构造函数的实例, 并且还因此创建了一个无意义的闭包, 这显然是有问题的, 所以还是应当像之前那样使用 `this` 而不是 `self`, 也不会因此创建闭包, 简单, 实用.

我们之前说, 如果实现的类只有公有变量和公有方法, 前面的方案是很不错的, 然而这世界上并没有那么多如果, 在其他语言中存在着私有变量和私有方法, 作为图灵完备的语言, JS 也应当可以吧.

OK, 让我们再来加上一个私有方法, 我们给每个实例悄悄地加上一个绰号, 就用后缀表示吧, 在打招呼的时候我们不使用实例的 `name` 了, 我们使用自己的绰号向别人介绍, 因为起绰号这事情是我们自己给自己起的, 所以我们定义一个起绰号的私有方法好了.

```javascript
function Person(name, age) {
	var self = this instanceof Person ? this : Object.create(Person.prototype);
	
	self.name = name;
	self.age = age;

	function __getSuffixName() {
		return `${self.name} Stormrage`;
	}

	if (typeof self.sayHello !== 'function') {
		Person.prototype.sayHello = function () {
			var suffixName = __getSuffixName();
			console.log(`Hello, I'm ${suffixName}, I'm ${this.age} years old.`);
			console.log(this.__getSuffixName === __getSuffixName);
		};
	}

	// 为了调试方便, 我们还是暴露这个私有方法
	self.__getSuffixName = __getSuffixName;

	return self;
}

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

console.log(a.__getSuffixName === b.__getSuffixName);
a.sayHello();
b.sayHello();
// false
// Hello, I'm aaa Stormrage, I'm 18 years old.
// true
// Hello, I'm aaa Stormrage, I'm 18 years old.
// false
```

看起来还行, 我们定义了一个私有方法 `__getSuffixName`, 并且只能通过公有方法 `sayHello` 调用它. 然而结果告诉我们这样是错误的. 首先我们的私有方法 `__getSuffixName` 在每次实例化对象的时候都会创建一个新函数, 而不能像 `sayHello` 那样所有实例共享同一个函数, 带来了无意义的内存占用. 另一方面是, 这个实现的正确性也没能得到保证, 它和之前的例子是同样的问题, 我们的 `sayHello` 只实例化了一次, 闭包中的 `__getSuffixName` 是第一次实例化时创建的, 也即对象 a 中的 `__getSuffixName`, 从几个判断语句中也可以看出来. 当然, 这里的 `__getSuffixName` 本身是没有问题的, 尽管用的是 `self`, 但每个 `__getSuffixName` 都是不同的, 它们的闭包拿到的都是各自对应的实例, 只是说它引用了外部的变量(`self`)会导致创建闭包而已.

尽管错了, 但是这里的大概思路还是没有问题的, 我们需要的只是简单地修改一下.

```javascript
function Person(name, age) {
	var self = this instanceof Person ? this : Object.create(Person.prototype);
	
	self.name = name;
	self.age = age;

	function __getSuffixName() {
		return `${this.name} Stormrage`;
	}

	if (typeof self.sayHello !== 'function') {
		Person.prototype.sayHello = function () {
			var suffixName = __getSuffixName.call(this);
			console.log(`Hello, I'm ${suffixName}, I'm ${this.age} years old.`);
			console.log(this.__getSuffixName === __getSuffixName);
		};
	}

	// 为了调试方便, 我们还是暴露这个私有方法
	self.__getSuffixName = __getSuffixName;

	return self;
}

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

console.log(a.__getSuffixName === b.__getSuffixName);
a.sayHello();
b.sayHello();
// false
// Hello, I'm aaa Stormrage, I'm 18 years old.
// true
// Hello, I'm bbb Stormrage, I'm 19 years old.
// false
```

OK, 我们已经确保了结果是正确的了. 尽管 `__getSuffixName` 中使用的是 `this`, 并且它不属于任何对象, 但是我们通过在 `sayHello` 中使用 `call` 调用它, 也让它不需要借助外部变量 `self` 就能拿到实例的属性 `name`. 并且因为没有引用外部变量 `self`, 在某些环境下也会少创建一个闭包

*注: V8 中尽管 `__getSuffixName` 没有引用外部变量, 但是还是会创建闭包, 因为 `sayHello` 引用了外部变量 `__getSuffixName`.*

> In V8, once there is any closure in the context, the context will be attached to every function 

所以大部分场景下, 我们还是需要小心这里面潜在的带来内存泄漏的可能性.

然而这里还有一个问题没解决, 那就是每次实例化对象时, 依然会创建不同的 `__getSuffixName`. 解决这个问题的一个方法是像 `sayHello` 那样, 将 `__getSuffixName` 放在 `prototype` 上面, 这样每个实例就能够共享同一个私有方法 `__getSuffixName` 了. 但是放在 `prototype` 上面, 那就意味着 `__getSuffixName` 暴露给用户了, 而不再是私有. 好在我们之前提到了, 还有一个方法.

```javascript
var Person = function () {
	function Person(name, age) {
		var self = this instanceof Person ? this : Object.create(Person.prototype);

		self.name = name;
		self.age = age;

		return self;
	}

	function __getSuffixName() {
		return `${this.name} Stormrage`;
	}

	Person.prototype.sayHello = function () {
		var suffixName = __getSuffixName.call(this);
		console.log(`Hello, I'm ${suffixName}, I'm ${this.age} years old.`);
	};

	return Person;
}();

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

a.sayHello();
b.sayHello();
// Hello, I'm aaa Stormrage, I'm 18 years old.
// Hello, I'm bbb Stormrage, I'm 19 years old.
```

**如果一个 class 只有公有变量, 公有方法和私有方法, 那上面这样应该算是一个不错的解决方案(不过这里还有个小问题是我们没有考虑继承).** 可惜这也只是如果, 如果我有一个亿, 如果这世界上没有傻逼...那这世界真是太美好了.

扯远了, 一个很自然的想法是, 我们有时候也希望有私有变量, 然而这个东西实在有些卧槽, 所以放在最后写吧. 还是先让我们看看静态变量和静态方法, 或者说类变量和类方法, 当然, 我们也会区分是公有的还是私有的.

首先是静态公有变量和静态公有方法, 这个可以说非常简单了, 就不多说明了.

```javascript
function Person() {
	++Person.total;
}
Person.total = 0;
Person.getTotal = function () {
	return this.total;
};
var a = new Person();
var b = new Person();
console.log(Person.getTotal());
// 2
```

非常简单, 我们只需要在 class 上直接定义属性就好, 如果不希望把实现细节暴露在外, 也可以包一层 IIFE, 不过没啥必要, 平时都是用各种模块方案, CommonJS, ES6 module 等等, 所以直接这么写就好了.

接下来看看静态私有变量和静态私有方法.

```javascript
var Person = function () {
	function Person(name, age) {
		var self = this instanceof Person ? this : Object.create(Person.prototype);

		++total;

		return self;
	}

	var total = 0;

	function staticPrivateMethod() {
		return total;
	}

	Person.getTotal = function () {
		return staticPrivateMethod();
	};

	return Person;
}();

var a = new Person();
var b = new Person();

console.log(Person.getTotal());
```

也不是很难, 依然是通过 IIFE 实现. 到目前为止, 即便是复杂一点的情况, 比如有公有变量, 公有方法, 私有方法, 静态私有变量, 静态公有变量, 静态私有方法, 静态公有方法, 并且实例可以使用静态变量, 静态方法, 我们都可以通过组合之前的方案来实现.

```javascript
var Person = function () {
	function Person(name, age) {
		var self = this instanceof Person ? this : Object.create(Person.prototype);

		// public
		self.name = name;
		// public
		self.age = age;

		// use static private variable
		console.log(total);
		// use static public variable
		console.log(Person.info);
		// call static private method
		_increaseTotal();
		// call static public method
		console.log(Person.getTotal());

		return self;
	}

	// private
	function __getSuffixName() {
		return `${this.name} Stormrage`;
	}

	// public
	Person.prototype.sayHello = function () {
		var suffixName = __getSuffixName.call(this);
		console.log(`Hello, I'm ${suffixName}, I'm ${this.age} years old.`);
	};

	// static private
	var total = 0;
	// static private
	function _increaseTotal() {
		++total;
	}

	// static public
	Person.info = 'Info';
	// static public
	Person.getTotal = function () {
		return total;
	};

	return Person;
}();

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

a.sayHello();
b.sayHello();
console.log(Person.getTotal());
```

这里是一个综合的例子, 不过很少情况我们需要写得如此啰嗦, 大部分时候, 我们可以根据场景, 选择合适的方案, 比如只有公有变量和公有方法, 那选择前面例子中的方案既简单又清晰.



#### 万恶之源的私有变量

OK, 让我们回到最开始的例子.

```javascript
function Person(name, __age) {
	this.name = name;
	this.sayHello = function () {
		console.log(`Hello, I'm ${this.name}, I'm ${__age} years old.`);
	}
}

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

a.sayHello();
b.sayHello();
```

现在我们稍稍修改一下, 我们希望 `age` 是一个私有属性, 毕竟年龄也是隐私对吧. 这也很简单.

```javascript
function Person(name, __age) {
	this.name = name;
	this.sayHello = function () {
		console.log(`Hello, I'm ${this.name}, I'm ${__age} years old.`);
	}
}

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

a.sayHello();
b.sayHello();
```

现在我们没办法通过 `a.age` 这样访问到 `age` 了, 只能通过 `a.sayHello()` 才能访问到它, 结果上说, 这没有任何毛病. 现在我们再增加一个私有方法, 来获得每个实例的虚岁好了.

```javascript
function Person(name, __age) {
	function __getVirtualAge() {
		return __age + 1;
	}
	this.name = name;
	this.sayHello = function () {
		var virtualAge = __getVirtualAge();
		console.log(`Hello, I'm ${this.name}, I'm ${virtualAge} years old.`);
	}
}

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

a.sayHello();
b.sayHello();
```

很好, 这段代码也能够正常地工作. 就实现需求而言, 我们已经做得很好了. 然而它依然存在我们之前提到的问题, 每次实例化一个对象, 都会创建一个新的 `__getVirtualAge` 和 `sayHello` 方法. 作为一个有洁癖的人肯定是无法忍受这一点的.

一个自然的想法是, 我们按照之前的操作, 把它们写在原型上, 或者把它们从构造函数中拿出来就好了. 依然是公有方法放 `prototype` 上, 私有方法通过 IIFE 实现.

```javascript
var Person = function () {
	function Person(name, __age) {
		this.name = name;
	}

	function __getVirtualAge() {
		// __age ???
		return __age + 1;
	}

	Person.prototype.sayHello = function () {
		// __age ???
		console.log(__age);
		var virtualAge = __getVirtualAge();
		console.log(`Hello, I'm ${this.name}, I'm ${virtualAge} years old.`);
	};
	return Person;
}();

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

a.sayHello();
b.sayHello();
```

上面这段代码是错误的, 它并不能正常工作. 我们可以发现, 无论是私有方法 `__getVirtualAge` 还是公有方法 `sayHello` 都没有办法拿到私有变量 `__age`. 当然有人会说这好办, 我们还是把它们放里面, 然后让它们只实例化一次就好.

```javascript
var Person = function () {
	function Person(name, __age) {
		this.name = name;
		if (typeof __getVirtualAge !== 'function') {
			__getVirtualAge = function () {
				return __age + 1;
			};
		}
		if (typeof this.sayHello !== 'function') {
			Person.prototype.sayHello = function () {
				var virtualAge = __getVirtualAge();
				console.log(`Hello, I'm ${this.name}, I'm ${virtualAge} years old.`);
			};
		}
	}

	var __getVirtualAge = null;


	return Person;
}();

var a = new Person('aaa', 18);
var b = new Person('bbb', 19);

a.sayHello();
b.sayHello();
// Hello, I'm aaa, I'm 19 years old.
// Hello, I'm bbb, I'm 19 years old.
```

然而这还是错的, 尽管我们的公有方法和私有方法都不再重复创建了, 并且它们也都能够拿到私有变量 `__age`, 然而还是那个问题, 它们只在第一个对象实例化时创建, 闭包拿到的也只能是第一个对象的 `__age`. So, 该怎么办呢?

好吧, 其实到这一步的时候已经无解了, 至少在 ES6 之前的技术手段来说是无解的, 我们没办法在一个类上很完美地实现一个私有变量, 诚然我们实现私有变量的第一种简单笨拙的方式是可以正确运行的, 但是它带来的额外开销是实践中不可接受的. 这是一个令人沮丧的结论, 然而事实就是这样. 说好的图灵完备呢? 当然, 如果你真的想要一个像其他语言一样的 `private` 声明的私有变量, 你也完全可以自己用 JS 实现一个解释器, 给它加上 `private`, 所以它还是图灵完备的, 但是这样做的代价也是不可接受的.

 

#### 基于约定

好了, 我们已经发现完美地实现一个带有私有变量的 class 是个不可能的任务. 所以不如把事情变得简单点, 让我们基于约定来实现? 我想很多人都是这么做的.

```javascript
function Person(name, age) {
	this.name = name;
	Object.defineProperty(this, '__age', {
		value: age,
		writable: true,
		enumerable: false
	});
}

Person.prototype.__getVirtualAge = function () {
	return this.__age + 1;
};
Object.defineProperty(Person.prototype, '__getVirtualAge', {
	enumerable: false
});
```

现在我们告诉大家, 别碰 `__` 开头的东西. 虽然事实上如果真有人想要修改这些私有的属性和方法, 他们还是可以轻易地做到, 另外子类继承它的时候, 也很有可能覆盖掉这些私有变量(如果子类的实现者不知道父类中存在 `__age` 这样一个挂在实例上的私有变量的话). 不过至少我们发出了一个免责声明, 意味着如果你修改了它, 那么后果自负. 虽然这看起来像是一个自欺欺人的东西, 不过它简单好用, 没有额外性能开销, 当然不排除像我这样的人还是会觉得很难接受. 不过另一方面是, 这份免责声明中很重要的一点是, 并非标记了 `__` 就代表如果因为修改这些私有内容导致的任何问题都不是我的责任了, 而是起码我们得确保别人不会遍历/枚举到这些属性, 毕竟使用 `for...in` `Object.keys()` 还是很常见的, 而大部分人在使用这些枚举操作的时候都默认了他们获取到的是你希望他们获取的属性, 而显然我们不希望他们获取到这些私有属性, 所以我们还是得将这些私有内容设置为不可枚举的, 让这些私有属性看上去更私有一些, 起码在某些场合中是这样. 这也让我稍稍好接受了一些.



#### The end

整个事情的矛盾之处在于我们希望方法始终是共享的, 我们希望属性始终是不共享的, 我们希望方法和属性都能根据需要决定是否暴露出来. 然而是否暴露和是否共享这两件事情总是无法兼得. 另一方面是, 从始自终, 我们通过各种奇技淫巧来解决这些问题, 也只是站在如何封装好当前这一个类的角度, 却没考虑过是否允许这个类被继承, 而继承又将带来更多的问题. 私有变量和私有方法尽管不在 `this` 或 `prototype` 上, 但人们潜意识认为它们也是属于实例的, 然而一旦实例的公有方法通过 `apply`/`call` 给其他对象使用, 这些私有的内容却并不能跟着转移.

*注: 这里讨论的关于私有变量私有方法的难点都是基于类而言, 如果是单例, 那其实没有什么难点.*



#### 希望

虽然个人并不喜欢 ES6 的 class, 这篇也没有讲 ES6 中如何实现一个能够满足各种面向对象的特性的 class, 但 ES6 的确为我们带来了一丝解决这些问题的希望, 比如 `Symbol`, 比如 `WeakMap`, 之后也会抽时间写下吧.



#### 参考资料

* http://efe.baidu.com/blog/javascript-private-implement/
* https://www.zhihu.com/question/23588490
* https://juejin.im/post/5a8e9b6d5188257a5f1ed826