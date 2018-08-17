*注: 本文并不会介绍如何使用 Promise, 本文假定你已经能够熟练使用 Promise, 并读过 Promise/A+ 规范.*

在学习一个新东西的时候, 我总是会希望知道为什么会有这么个东西? 它解决了什么问题? 它背后有着怎样的思想? 而不是仅仅知道如何使用它, 所以这一篇会花很大篇幅来写这些内容, 受限于数学知识, 并不能够很好地从数学意义上来解释 Promise, 希望以后有机会能补上吧.

#### 回调的问题

我们已经很熟悉回调了, 在 js 中, 回调是很常见的一种模式. 回调函数作为我们自身逻辑的一部分, 被交给了其他函数执行, 这里的其他函数可能是我们自己实现的, 也可能是第三方的 API, 于是很好地做到了关注点分离, 我们的关注点不再混杂在一起, 每个回调函数只在特定时候触发, 也只处理特定的事件, 帮助我们完成了解耦.

从本质上讲, 这也是一种控制反转, 原本由我们控制何时调用的函数, 现在被交给了其他函数, 由它们来决定何时调用我们的函数.

##### 信任问题

尽管有这些优点, 但是回调也带来了一些问题, 如我们熟知的回调地狱, 还有回调模式本身不符合人类的思维方式, 毕竟人的脑子总是习惯顺序地执行. 当然回调地狱之所以被称为是地狱, 不仅仅是因为它的层层嵌套看上去丑陋, 还包括它带来的信任问题.

> 有关于回调的最麻烦的问题就是控制反转导致所有这些信任完全崩溃 

我们说过, 回调是一种控制反转, 原本受我们控制何时调用的代码, 现在它不再受我们控制了, 它在别人手里, 由别人决定何时调用, 是否调用, 调用几次. 理论上来说, 如果这些第三方的 API 没有 bug, 并且它一定会按照我们期望的方式去调用我们的代码, 那的确不会有什么问题. 然而只是理论上, 人的脑子总不是那么地可靠, 总是会犯错. 于是原本我们可以信任的代码变得不能够信任了, 信任崩溃. 更深层次地说, 回调只是一种口头约定而没有强制效力.

> 当你把你程序的一部分拿出来并把它执行的控制权移交给另一个第三方时，我们称这种情况为“控制倒转”。在你的代码和第三方工具之间有一个没有明言的“契约”——一组你期望被维护的东西 

于是我们会面临着这些问题:

> * 过早调用回调函数
> * 过晚调用回调函数
> * 回调函数没有被调用
> * 回调函数调用次数太多或太少
> * 回调函数被调用时没有被传入正确的参数
> * 回调函数中的错误/异常被吞掉了而没有得到通知
> * ...

于是我们试图修补这些问题, 比如针对过早调用, 那我们就在函数外部设置一个标记, 只有在合适的时候标记被置为 `true`, 然后在回调函数的开始检查这个标记, 如果还没到合适的时候就跳过. 比如针对回调函数被执行的次数太多或太少, 我们可以在外部设置一个计数器, 每次调用回调函数就加一, 然后在回调函数开始检测计算器判断是否执行了我们期望次数. 我们还可以对回调函数的参数做类型检查, 看看参数是否符合我们的期望...

理论上, 我们可以试图修补掉这些问题, 然而这会导致我们的代码中充斥着防御性的代码, 并且还得针对每个回调函数做不同程度的修补工作, So, 这才是真正的回调地狱.

##### 现在和稍后的值

可能很多时候我们一看到回调就联想到异步, 但其实回调和异步并没有什么关系, 回调当然也可以是同步调用的, 所以**回调不代表异步!!!** 比如下面这段代码.

```javascript
var doSth = function () {
	var val = null;
	return function (completeCallback) {
		if (val) {
			completeCallback(val);
		} else {
			setTimeout(() => (val = 1, completeCallback(val)), 1000)
		}
	}
}();

console.log('a');
doSth(data => {
	console.log(data);
});
console.log('b')

setTimeout(() => {
	console.log('c');
	doSth(data => console.log(data));
	console.log('d');
}, 2000);
// a
// b
// 1

// c
// 1
// d
```

这里 `doSth()` 第一次是异步调用了我们的回调函数, 第二次是同步调用了回调函数, 所以回调并不一定都是异步的. 这也导致了问题, 就是我们无法根据一个 API 的签名来判断我们的回调是会被同步调用还是被异步调用, 进而无法预测回调函数的执行顺序. 另外我们关心的往往是回调函数的结果, 也就是说这个结果可能是一个现在的值, 也可能是一个未来的值. 一个好的处理方式是, **在设计带有 callback 参数的 API 的时候, 我们应当确保 callback 调用时机的一致性, 即要么始终同步调用 callback, 要么始终异步调用, 在 js 语境下最好都异步调用**, 符合大多数人对 callback 的认知. 所以上面的例子中有时同步调用, 有时异步调用, 并不是一个好的写法. 而如果我们不确定一个回调的结果是现在的值还是未来的值, 同样最好把它们都当作是未来的值.

最后我们也还是把 `doSth()` 稍稍改动一下.

```javascript
var doSth = function () {
	var val = null;
	return function (completeCallback) {
		if (val) {
			setTimeout(() => completeCallback(val), 0);
		} else {
			setTimeout(() => (val = 1, completeCallback(val)), 1000)
		}
	}
}();
```

##### 另一种耦合

另一方面, 前面我们说了, 回调的优点之一是帮助解耦, 我们可以针对某一事件单独提供一个回调函数进行处理, 这个函数只关心如何处理事件, 而不必关心其他事情. 但是回调也带来了另一种形式的耦合, 那就是我们为了得到一个通知, 或是为了得到一个异步操作的值, 我们不得不把原本属于我们自己的逻辑的一部分交到别人手里, 这事情就好像你去奈雪点了份奶茶, 然后你把你的手机交给店员, 告诉他让他在做好了的时候用这个手机联系你另一个手机, 非常可笑. 而实际上我们都知道, 事情不会是这样, 店员会给我们一个通知器, 做好了它会响. 让我们看看这种耦合是如何体现的.

```javascript
function doSth(data, cb) {
    cb('done');
}

function foo(data) {}

function bar(data) {}

doSth(1, foo);
doSth(2, bar);
```

假如我们的 `foo` 和 `bar` 都想知道 `doSth` 何时完成, 我们在使用 `foo` 和 `bar` 的时候就必须知道 `doSth` 有几个参数, 我们的 `foo` 和 `bar` 应该被放在第几个参数, 于是 `foo` `bar` 和 `doSth` 被绑定在了一起.

另一方面, 这里为了让 `foo` 和 `bar` 都得到通知, 我们执行了两次 `doSth`, 但如果我们希望执行一次 `doSth` 而 `foo` `bar` 都得到通知呢? 我们可能会这样写.

```javascript
doSth(function (data) {
    foo(data);
    bar(data);
});
```

通过一个中间的匿名函数来完成, `foo` 和 `bar` 的调用都集中在这里. 如果有更多的函数想要监听 `doSth` 的完成, 每新增一个我们就得往匿名函数中增加一个函数调用.

而如果 `doSth` 是返回一个 Promise 呢?

```javascript
var p = doSth(1);
foo(p);
bar(p);
```

于是我们甚至可以把对 `foo` 和 `bar` 的调用写在不同模块, 这样代码的多个分离部分都被赋予了事件监听的能力, 它们都可以在 `doSth` 完成时被独立地通知.

最终 `foo` 和 `bar` 不必和 `doSth` 的调用绑定在一起, 而 `doSth` 也不必知道 `foo` 和 `bar` 的存在, Promise 充当了一个中立的第三方, 在分离的关注点之间进行交涉. 从这一点上说, 其实回调模式中那个中间的匿名函数也是类似的角色, 但是 Promise 的话, `foo` 和 `bar` 可以在运行时决定是否要监听, 而采用中间的匿名函数则是运行前就注册了监听, 一旦注册了监听就无法在运行时改变了.

如果把回调和 Promise 类比到现时生活种的例子, 可以是这样. 如果我们交给 A 一个任务, 让他完成了通知我们, 于是我们交给 A 一个对讲机(假设对讲机只能成对使用), 他完成了以后便会用我们给他的对讲机通知我们, 这是回调. 但很显然, 我们把对讲机放在 A 那里并不怎么放心, A 可能弄丢我们给他的对讲机于是我们永远得不到通知之类.

那我们换个思维, 让 A 给我们一个对讲机, 他完成了以后会用这个对讲机来通知我们, 这样我们就不用担心我们的对讲机被弄丢而得不到通知的问题了(当然, A 可能会担心他的对讲机被我们弄丢, 但是这不是我们关心的问题), 这个对讲机便是 Promise.

而另一个问题是, 如果除了我, 还有 B, C 也想得到 A 完成以后的通知, 这种时候采用回调方式的话, 意味着我和 B, C 都需要提供一个对讲机给 A, 也就是说我们需要准备三对对讲机. 而如果使用 Promise 的话, 让 A 给我们一个对讲机, 我们把对讲机接入广播系统, 于是我和 B, C 都能够得到通知了, 并且只需要一对对讲机(其实这个例子并不是很好, 因为如果存在广播系统的话, 那回调方式也只需要一对对讲机即可, 但实际上代码中 B, C 可能针对这一完成事件做出不同的操作, 所以 B, C 不可能提供同一个回调函数, 而是提供不同的回调函数).

OK, 其实上面这么一大段已经说明了回调具有哪些问题, 并且也简单说明了 Promise 是如何解决这些问题的, 当然后面还会更加详细地说明.



#### Promise

我们已经知道了回调有许多问题, 让我们来回想一下, 导致这些问题的原因是什么? 对, 没错, 是控制反转. 那我们不控制反转不就不会有这些问题了? 真是机灵, 这样的话回调带来的优点也没了, 我们又不得不把一堆逻辑耦合在一起.

那有没有什么办法既有回调的优点, 又能避免掉回调的缺点? 让我们想想为什么我们需要控制反转? 我们希望别人在完成了某个操作之后能够通知我们, 于是我们把我们的一部分逻辑交给他, 让他在完成之后调用我们的这部分逻辑.

让我们来看看这里面哪些部分是必要的. 第三方在完成了操作的时候调用我们的逻辑, 是可以达到通知我们的目的, 但是通知我们他完成了就一定要让他来调用我们的逻辑吗? 如果第三方调用了我们的回调函数, 则他可以通知我们, 这里第三方调用回调函数只是一个充分不必要条件. 换句话说, 第三方完全可以用某种方式通知我们完成了, 然后我们自己来调用. 所以最终, 我们其实真正想要的是第三方能够通知我们他完成了, 而不必让我们把一部分逻辑交给他调用, 这解决了信任问题.

基于这一想法, 我们希望有这样一种方式, 我们不必将我们程序的一部分交给第三方, 而是第三方返回一个东西让我们可以知道他何时完成, 于是我们反转了控制反转, 对代码的控制权还是在我们这里, 调度是由我们来完成的, 但是它又和同步逻辑不一样.

但是还有个问题, 我们只说了不让第三方去调用我们的回调函数可以解决掉信任问题, 并且第三方返回一个东西可以通知我们完成了, 但是通知这个事情, 难道可以不用回调来完成吗? 不用回调那能用什么来通知呢? 如果还是需要用到回调来通知, 那只不过是把一个第三方换成了另一个第三方, 那又怎么能说是解决了信任问题呢? 这个问题之后讨论.



#### 所有的第三方都不值得信任吗? Promise/A+ 规范

信任, 大概是这个世界秩序的根基了, 我们的网络安全, 我们的货币, 都和信任相关, 如果所有的第三方都不值得我们信任, 那这个世界的秩序也就无从谈起了. 所以我们选择了信任一部分的第三方, 比如我们信任根证书的颁发机构, 我们信任银行不会拿了我们的钱跑路, 我们信任 GOV(雾), 它们充当了一个值得信任的第三方这样的角色.

如果有一个机构/组织提出了一个规范, 大家都信任这个机构/组织并且都愿意遵守这个规范, 那这个社会的运行成本会大大降低, 社会的运行效率也能得到提高. 毕竟当你不信任的一个东西的时候, 你要想方设法去检验它, 而如果你信任它, 则不需要任何思考, 能量不需要浪费在这样的事情上面.

扯远了, 那么现在我们有一个值得信任的组织, 他们制定了一个 Promise/A+ 的规范, 所有按照规范实现的 Promise 都值得我们信任, 因为它们会按照规范指定的行为工作.

接下来我们根据规范来解释下为什么 Promise 可以解决掉前面提到的信任问题, 它如何统一了现在的值和未来的值, 以及如何解除掉耦合问题.

##### 信任问题的解决

规范中有这几点:

* `onFulfilled` 和 `onRejected` 必须在 Promise 状态为终止状态之后被调用, 而不能在终止状态之前被调用, 并且最多被调用一次. 这解决了信任问题中回调函数过早执行, 过晚执行, 不执行, 或多次执行的问题
* `onFulfilled` 和 `onRejected` 必须被作为函数调用(即没有 `this`, 也不是作为构造函数调用). 这确保了我们传入的回调函数不会被错误地调用
* Promise 的状态转移只有两种, pending -> fulfilled, pending -> rejected, 单向不可逆. 这也说明了 Promise 的终止状态只有 fulfilled 和 rejected, 一旦进入终止状态则 value 不可改变, 不可改变是指指向不可变, 而非结构或属性值不可变, 即 `===` 相等性判断为 `true` 就算没有改变. 不可改变有两层意思, 一方面是指 Promise 保证自己内部不会再改变该值, 一方面是 Promise 保证外部也无法修改该值

##### 泛化现在的值和未来的值

规范中有这几点:

* `onFulfilled` 或 `onRejected` 只有在执行上下文([execution context](https://es5.github.io/#x10.3))栈中仅剩平台代码时才会被调用. 这确保了回调函数的执行时机总是异步的, 把它们都统一成了未来的值
* 如果 `onFulfilled` 或 `onRejected` 抛出了一个异常 `e`, `promise2` 必须转移到 rejected 状态, 并且将 `e` 作为 reason. 这也确保了即便是抛出异常, 也只能被异步捕获到, 所以异常也是未来的值

##### 耦合问题

这个其实在前面已经提到了.



其实我们可以看到, 即便是 Promise, 我们为了得到通知还是得使用回调, 也就是说 Promise 还是没有摆脱回调, 那为什么说它可以解决信任问题呢? 首先如同本节开篇所说, 因为它是规范, 而我们信任规范. 其实是换了个思路, 不用回调当然可以解决信任问题, 但是用回调也不一定不能解决信任问题. 回调和信任问题并没有必然的联系, 之前提到的信任问题是回调导致的, 但是通过一个规范, 让回调也可以没有信任问题.

回调之所以有信任问题, 是因为没有统一的规范来约束, 每个第三方的 API 都可以定义自己的回调接口, 并且它们调用回调函数的时机, 次数等等都可能和其他回调 API 不一样, 比如有些 API 的回调是同步执行, 有些却是异步.

但是 Promise 是有规范约束的, 只要大家都使用符合规范的 Promise, 那 Promise 的回调也是可以信任的, 所以我们的最终目的并非是为了消除回调, 而是为了解决信任问题.



#### 规范中的其他细节

简单过一遍规范.

> 一个 Promise 代表了一个异步操作的最终结果

虽然我们总说 Promise 封装了一个异步操作, 仿佛 Promise 的作用就是为了执行异步操作的, 但是这样的理解很容易让人产生误解. 比如一旦陷入这样的理解, 就会纠结为什么 Promise 连个取消异步操作的方式都不提供? 而这里直接定义了 **Promise 是一个未来的值, 而执行异步操作只是它的副作用, 我们关心的是它的值而不是它的副作用**.

> 一个 promise 的当前状态必须是以下三个中的一个: pending, fulfilled, rejected.
>
> 2.1.1. 当处于 pending 状态时, 一个 promise:
>
> ​	2.1.1.1. 可以转移到 fulfilled 或 rejected 状态
>
> 2.1.2. 当处于 fulfilled 状态时, 一个 promise:
>
> ​	2.1.2.1. 不能转移到其他任何状态
>
> ​	2.1.2.2. 必须有一个 value, 并且 value 必须不会(在之后被)改变
>
> 2.1.3. 当处于 rejected 状态时, 一个 promise:
>
> ​	2.1.3.1. 不能转移到其他任何状态
>
> ​	2.1.3.2. 必须有一个 reason, 并且它(value)必须不会(在之后被)改变
>
> 这里, 必须不会改变的定义是 `===` 相等性判定为 `true`, 而非要求对象的属性值及结构都不变, 即只要求指向地址不变.

这也体现了未来的值的三种状态, 等待, 成功获取和失败, 有且只有这三种状态, 并且 fulfilled 和 rejected 是最终状态, 一旦进入最终状态则状态不可改变. 如果 Promise 可以取消的话, 那就需要引入一个新的状态, 但是这个新状态对于未来的值而言有什么意义呢? 我们可以说取消一个操作, 但是却不会说取消一个值, 当把 Promise 理解成一个异步操作时, 大家都会希望能够有个 API 来取消它, 但是 Promise 设计之初关注的始终是值, 异步操作只是副作用.

> 2.2.2. 如果 `onFulfilled` 是一个函数:
>
> ​	2.2.2.1. 则它必须在 `promise` 状态为 fulfilled 之后被调用, 它的第一个参数是 `promise` 的 value
>
> ​	2.2.2.2. 它一定不能在 `promise` 状态为 fulfilled 之前被调用
>
> ​	2.2.2.3. 它最多被调用一次
>
> 2.2.3. 如果 `onRejected` 是一个函数:
>
> ​	2.2.3.1. 则它必须在 `promise` 状态为 rejected 之后被调用, 它的第一个参数是 `promise` 的 reason
>
> ​	2.2.3.2. 它一定不能在 `promise` 状态为 rejected 之前被调用
>
> ​	2.2.3.3. 它最多被调用一次

确保了 `onFulfilled()` 和 `onRejected()` 的调用时机和调用次数.

> `onFulfilled` 或 `onRejected` 只有在执行上下文([execution context](https://es5.github.io/#x10.3))栈中仅剩平台代码时才会被调用

确保了 `onFulfilled()` 和 `onRejected()` 总是被异步调用.

> `onFulfilled` 和 `onRejected` 必须被作为函数调用(即没有 `this`, 也不是作为构造函数调用)

确保了 `onFulfilled()` 和 `onRejected()` 不会以非预期的形式被调用.

> 2.2.6. 同一个 promise 的 `then` 方法可以被调用多次
>
> ​	2.2.6.1. 如果/当 `promise` 的状态是 fulfilled, 其相应的所有 `onFulfilled` 回调函数必须按照它们通过 `then` 注册的顺序依次调用执行
>
> ​	2.2.6.2. 如果/当 `promise` 的状态是 rejected, 其相应的所有 `onRejected` 回调函数必须按照它们通过 `then` 注册的顺序依次调用执行

使得我们可以在不同的地方监听到同一个异步操作的完成, 并且确保了监听是按照注册顺序被通知, 进而确保了多次注册的回调函数之间的执行顺序.

> 2.2.7. `then` 方法必须返回一个 promise

链式调用的基础, 通常是返回一个新的 Promise.

> 2.2.7.1. 如果 `onFulfilled` 或 `onRejected` 返回一个 value `x`, 则运行 Promise 解析处理程序(Promise Resolution Procedure) `[[Resolve]](promise2, x)`

意味着 `onFulfilled()` 和 `onRejected()` 始终会调用 `[[Resolve]]`.

> ​	2.2.7.2. 如果 `onFulfilled` 或 `onRejected` 抛出了一个异常 `e`, `promise2` 必须转移到 rejected 状态, 并且将 `e` 作为 reason
>
> ​	2.2.7.3. 如果 `onFulfilled` 不是一个函数并且 `promise1` 是 fulfilled 状态, 则 `promise2` 必须是 fulfilled 状态, 并且它的 value 和 promise1 一样
>
> ​	2.2.7.4. 如果 `onRejected` 不是一个函数并且 `promise1` 是 rejected 状态, 则 `promise2` 必须是 rejected 状态, 并且它的 reason 和 `promise1` 一样

确定了 `then()` 返回的 Promise 和原 Promise 对象之间的关系.

> 2.3.1. 如果 `promise` 和 `x` 指向同一个对象, 则将 `promise` 置为 rejected, 并用一个 `TypeError` 作为 reason

限制了 `[[Resolve]]` 不能处理自指的 Promise 对象, 否则会导致无限制递归下去.





#### Promise 的类型检测

通常来说, 我们要检测一个对象是否是一个 Promise 是为了确保对象的行为符合我们的预期, 而很少有为了检测类型而检测类型的场景, 所以脱离了场景谈论哪种类型检测的方案更好是没有意义的.

##### instanceof

说到类型检测, 我们很容易想到这样的方法.

```javascript
p instanceof Promise
```

但它并不是那么可靠, 一方面就像 `Array` 那样, 我们可能跨 window 传递一个对象, 另一方面, 由于 js 猴子补丁的特性, Promise 可能被重写了, 而并不是我们想要的 Promise, 又或者 `p` 是一个符合规范的第三方 Promise 库的实例, 这都导致了这个方法并不是很可靠.

但是如果在一个相对可控的项目中, 我们明确知道不会使用第三方的 Promise, 不会跨 window 传递对象, 不会重写 Promise, 我们的接口都是内部使用而不会暴露给用户, 那这几乎是最好的方法了.

##### 鸭子类型检测

由于 js 缺乏语言层面的接口约束, 我们只能判断一个对象是否具有 `then` 方法, 而不能判断这个 `then` 方法是否按照规范实现, 比如参数, 比如返回值, 换句话说, 我们只能判断一个对象是否是 thenable 的.

```javascript
typeof p.then === 'function'
```

严格来说, 这种方法并不能判断一个对象是否是 Promise, 但是它也不是完全没有用. 当我们希望暴露接口给用户使用, 并期望用户传递一个符合规范的 Promise 就行, 而不限制是否是原生 Promise. 对于可能出现的错误, 则完全由用户自己承担责任, 这依赖于用户的自觉. 这种时候, 使用鸭子类型检测会是一个开销较小并且互操作性比较好的方案.

##### 强制类型转换

与上面的方案相反, 如果我们希望无论用户传递什么值进来, 我们都能够很好地处理它, 那么我们最好是把传进来的值都转换成 Promise.

```javascript
Promise.resolve(data)
```

但是这个方法也有一点点小瑕疵, 那就是如果 `data` 已经是一个符合规范的第三方 Promise, 事实上我们直接调用 `data.then` 就好, 而不用再经过一次对 thenable 的 `[[Resolve]]`.

这个方法同样适用于当我们希望把接口暴露给用户使用, 并且接受任意类型的参数都能够保证行为符合预期的场景, 这个方法的互操作性也不错.

最后我们也可以结合这几种方法.

```javascript
function doSth(data) {
    if (data instanceof Promise || tyepof data.then === 'function') {
        data.then(function () {
            // ...
        });
    } else {
        Promise.resolve(data).then(function () {
            // ...
        });
    }
}
```





#### Promise 的异常处理

通常我们有以下几种情况会导致 Promise 变为 rejected 状态.

##### 在构造函数的回调函数中抛出一个异常

```javascript
var rj = new Promise((rs, rj) => {
	throw new Error('test');
});
rj.then(null, e => {
	console.log(e.message);
});
```

##### 在构造函数的回调函数中主动调用 `reject()`

```javascript
var rj = new Promise((rs, rj) => {
	rj('test');
});
rj.then(null, data => {
	console.log(data);
});
```

##### 在 `onFulfilled` 或 `onRejected` 中抛出一个异常

```javascript
var rj = Promise.resolve().then(data => {
	throw new Error('test');
});
rj.catch(e => console.log(e.message));
```

##### 在 `onFulfilled` 或 `onRejected` 中返回一个 rejected 的 Promise

```javascript
var rj = Promise.resolve().then(data => {
	return Promise.reject('test');
});
rj.catch(data => console.log(data));
```

##### 直接通过 `Promise.reject()` 创建一个 rejected 的 Promise

```javascript
var rj = Promise.reject('test');
rj.catch(data => console.log(data));
```

需要注意的是, 构造函数的回调函数中, 只有同步抛出的异常才会使得 Promise 状态为 rejected, 所以下面这种是不行的.

```javascript
var rj = new Promise((rs, rj) => {
	setTimeout(() => {
		throw new Error('test');
	}, 2000);
});
```

只能通过 `window.onerror` 或 `process.on('uncaughtException')` 捕获了.

大家都知道, `catch()` 其实只是 `then()` 的一个语法糖.

```javascript
rj.catch(e => {
	// ...
});
// 等价于
rj.then(null, e => {
	// ...
});
```

所以我们可以在捕获到异常之后继续 Promise 链. 比如

```javascript
var rj = Promise.reject();
rj.catch(e => {
	console.log(1);
}).then(() => {
	console.log(2);
});
```

如果一个 rejected 的 Promise 没有注册 `onRejected()` 处理的话则会抛出一个异常, 之前会导致 crash, 现在不会了. 这意味着**我们总是应当为一个 rejected 的 Promise 注册 `onRejected()` 或使用 `catch()` 来处理.**

但是看了前面的例子, 一个很自然的想法是, 下面这个例子中.

```javascript
var rj = Promise.reject(2);
console.log(1);
rj.catch(data => {
	console.log(data);
});
// 1
// 2
```

显然, 在执行 `console.log(1)` 的时候我们的 Promise 已经是 rejected 状态了, 并且我们还没有为它注册 `onRejected()`, 那为什么不报错?

准确来说, 是**如果一个 Promise 的状态在转换成 rejected 的那一轮事件循环中没有注册 `onRejected()` 处理的话则会抛出一个异常**. 所以上面的例子并不会报错, 因为我们在同一轮事件循环中已经注册了 `onRejected()`. 而下面这样则是肯定会报错的.

```javascript
var rj = Promise.reject(2);
console.log(1);
setTimeout(() => {
	rj.catch(data => {
		console.log(data);
	});
}, 2000);
```

很多时候我们可能不希望每个 Promise 都写上 `catch()` 又或者忘记写 `catch()` 了, 对于这样导致的异常, 我们可以通过 `process.on('unhandledRejection')` 和 `window.onunhandledrejection` 来处理. eg.

```javascript
setTimeout(() => {
	console.log('test');
}, 0);

process.on('unhandledRejection', (reason, promise) => {
	console.log(reason, promise === rj);
});

var rj = Promise.reject(5);
// 5
// true
// test
```

```javascript
setTimeout(() => {
	console.log('test');
}, 0);

window.onunhandledrejection = function (e) {
	console.log(e.type);
	console.log(e.reason);
	console.log(e.promise === rj);
};

var rj = Promise.reject(5);
// 5
// true
// test
```

**`process.on('unhandledRejection')` 和 `window.onunhandledrejection` 执行回调函数的时机是和 Promise 状态变为 rejected 处于同一轮事件循环的.** 从上面的例子中也可以看出这一点.

还有两个与 Promise 异常处理有关的事件, `process.on('rejectionHandled')` 和 `window.onrejectionhandled`, 它们两个的作用比较难以描述, 是在一个状态变为 rejected 却没有在同一轮事件循环中注册 `onRejected()` 的 Promise, 在之后又注册了 `onRejected()` 的时候触发. 还是看 demo.

```javascript
process.on('rejectionHandled', promise => {
	console.log(promise === rj);
});

var rj = Promise.reject(5);
setTimeout(() => {
	rj.catch(data => {
		console.log(data);
	});
}, 2000);
// true
// 5
```

```javascript
window.onrejectionhandled = function (e) {
	console.log(e.promise === rj);
};

var rj = Promise.reject(5);
setTimeout(() => {
	rj.catch(data => {
		console.log(data);
	});
}, 2000);
// 5
// true
```

**这两个事件浏览器和 Node 的实现似乎不太一样, Node 是在注册 `catch()` 之前触发, 浏览器是在注册 `catch()` 之后触发.**

它们的参数相比之前的两个事件少了 `reason`, 这两个事件的应用场景有点迷, 想不到有什么用.

对于 async/await 函数中, 我们还可以这样来捕获一个未注册 `onRejected` 的 rejected 的 Promise 导致的异常.

```javascript
function getData() {
	return Promise.reject(5);
}

async function test() {
	try {
		await getData();
	} catch (e) {
		console.log(e);
	}
}

test();
// 5
```

捕获到的即是 reason. 但是注意, **必须是 `await` 后面的 Promise 才可以被 `try-catch` 捕获到**, 所以下面这样是不行的.

```javascript
function getData() {
	return Promise.reject(5);
}

async function test() {
	try {
		getData();
	} catch (e) {
		console.log(e);
	}
}

test();
// error
```

当然我们也可以继续用比较 Promise 风格的异常处理.

```javascript
function getData() {
	return Promise.reject(5);
}

async function test() {
	await getData().catch(e => console.log(e));
}

test();
// 5
```

从优雅的角度来讲, `try-catch` 显然要优雅一些, 但是不知道 `try-catch` 带来的性能影响大还是 `catch()` 作为一次函数调用的开销大, 个人觉得如果 `try` 中比较短的话就用 `try` 吧, 否则的话, 如果有很多个 `await`, 那意味着每个 Promise 都可能 rejected, 导致 `try` 中内容过多, 这种情况就还是用 `catch()` 吧. 不过最好还是有 benchmark 才比较好确认吧, 另外据说 Node 8.3+ 以后 `try-catch` 的影响可以忽略不计了, 如果是这样那就放心用 `try-catch` 吧.

还可以像 go 一样的风格去处理异常, 需要借助一个简单的工具函数.

```javascript
function to(p) {
	return p.then(data => [null, data]).catch(err => [err, undefined]);
}
function getData() {
	return Promise.reject('test');
}
async function test() {
	const [err, data] = await to(getData());
	if (err) {
		console.log('error');
		return;
	}
	console.log(data);
}

test();
```

最后, **对于构造函数回调参数或 `onFulfilled()` 或 `onRejected()` 中的异步错误, 我们都应当通过 `window.onerror` 和 `process.on('uncaughtException')` 来捕获处理.**











构造函数的回调总是被同步调用的















Promise包装了时间相关的状态——等待当前值的完成或拒绝——从外部看来，Promise本身是时间无关的，如此Promise就可以用可预测的方式组合，而不用关心时间或底层的结果 

回调本身代表着一种 *控制反转*。所以反转回调模式实际上是 *反转的反转*，或者说是一个 *控制非反转*——将控制权归还给我们希望保持它的调用方代码 



你可能会相信这段代码的最后两行应当写做`p.then( .. ).then( .. )`，使用链接，而不是`p.then(..); p.then(..)`。这将会是两种完全不同的行为 

分割（splitting）/分叉（forking） 

一个任务有时会同步完地成，而有时会异步地完成，这将导致竞合状态 

即便是立即完成的Promise（比如 `new Promise(function(resolve){ resolve(42); })`）也不可能被同步地 *监听* 

链接在两个分离的Promise上的回调之间的相对顺序，是不能可靠预测的 

为了回避这样的微妙的噩梦，你绝不应该依靠任何跨Promise的回调顺序/排程。

如果在Promise的创建过程中的任意一点，或者在监听它的解析的过程中，一个JS异常错误发生的话，比如`TypeError`或`ReferenceError`，这个异常将会被捕获，并且强制当前的Promise变为拒绝。 

因为它有效地解决了另一种潜在的Zalgo时刻，也就是错误可能会产生一个同步的反应，而没有错误的部分还是异步的 

为什么它不能调用我们在这里定义的错误处理器呢？表面上看起来是一个符合逻辑的行为。但它会违反Promise一旦被解析就 **不可变** 的基本原则。`p`已经完成为值`42`，所以它不能因为在监听`p`的解析时发生了错误，而在稍后变成一个拒绝。 

Promise根本没有摆脱回调。它们只是改变了回调传递的位置。与将一个回调传入`foo(..)`相反，我们从`foo(..)`那里拿回 *某些东西* （表面上是一个纯粹的Promise），然后我们将回调传入这个 *东西* 

尽管如此，我们可以将这两个版本的`p`传入`Promise.resolve(..)`，而且我们将会得到一个我们期望的泛化，安全的结果 

`Promise.resolve(..)`会接受任何thenable，而且将它展开直至非thenable值。但你会从`Promise.resolve(..)`那里得到一个真正的，纯粹的Promise，**一个你可以信任的东西**。如果你传入的东西已经是一个纯粹的Promise了，那么你会单纯地将它拿回来，所以通过`Promise.resolve(..)`过滤来得到信任没有任何坏处。 

它可以很容易地将函数调用泛化为一个行为规范的异步任务 

Promise是一个用可靠语义来增强回调的模式，所以它的行为更合理更可靠。通过将回调的 *控制倒转* 反置过来，我们将控制交给一个可靠的系统（Promise），它是为了将你的异步处理进行清晰的表达而特意设计的 

前面提到的`reject(..)` **不会** 像`resolve(..)`那样进行展开 

如果你以一种不合法的方式使用Promise API，而且有错误阻止正常的Promise构建，其结果将是一个立即被抛出的异常，**而不是一个拒绝Promise** 

默认情况下，它假定你想让所有的错误都被Promise的状态吞掉，而且如果你忘记监听这个状态，错误就会默默地凋零/死去——通常是绝望的 

你不能仅仅将另一个`catch(..)`贴在链条末尾，因为它也可能失败。Promise链的最后一步，无论它是什么，总有可能，即便这种可能性逐渐减少，悬挂着一个困在未被监听的Promise中的，未被捕获的错误 

技术上讲，被传入`Promise.all([ .. ])`的`array`的值可以包括Promise，thenable，甚至是立即值。这个列表中的每一个值都实质上通过`Promise.resolve(..)`来确保它是一个可以被等待的纯粹的Promise，所以一个立即值将被范化为这个值的一个Promise。如果这个`array`是空的，主Promise将会立即完成 

一个“竞合（race）”需要至少一个“选手”，所以如果你传入一个空的`array`，`race([..])`的主Promise将不会立即解析，反而是永远不会被解析 

Promise不能被取消——而且不应当被取消，因为那会摧毁本章稍后的“Promise不可取消”一节中要讨论的外部不可变性——所以它们只能被无声地忽略 

```
if (!Promise.observe) {
	Promise.observe = function(pr,cb) {
		// 从侧面观察`pr`的解析
		pr.then(
			function fulfilled(msg){
				// 异步安排回调（作为Job）
				Promise.resolve( msg ).then( cb );
			},
			function rejected(err){
				// 异步安排回调（作为Job）
				Promise.resolve( err ).then( cb );
			}
		);

		// 返回原本的promise
		return pr;
	};
}
```

```
Promise.race( [
	Promise.observe(
		foo(),					// 尝试`foo()`
		function cleanup(msg){
			// 在`foo()`之后进行清理，即便它没有及时完成
		}
	),
	timeoutPromise( 3000 )	// 给它3秒钟
] )
```

```
if (!Promise.map) {
	Promise.map = function(vals,cb) {
		// 一个等待所有被映射的promise的新promise
		return Promise.all(
			// 注意：普通的数组`map(..)`，
			// 将值的数组变为promise的数组
			vals.map( function(val){
				// 将`val`替换为一个在`val`
				// 异步映射完成后才解析的新promise
				return new Promise( function(resolve){
					cb( val, resolve );
				} );
			} )
		);
	};
}
```

必须提供一个被同步/立即调用的回调函数 

如果你传入一个纯粹的Promise，`Promise.resolve(..)`不会做任何事情；它仅仅会直接返回这个值 

它等价于`then(null,..)` 

`then(..)`和`catch(..)`也会创建并返回一个新的promise 

如果其中任意一个被拒绝，返回的主promise也会立即被拒绝（丢弃其他所有promise的结果） 

至于拒绝状态，你仅会收到第一个promise拒绝的理由值 

如果一个空的`array`被传入`Promise.all([ .. ])`，它会立即完成，但`Promise.race([ .. ])`却会永远挂起，永远不会解析 

没有外部的方法能够监听可能发生的任何错误 

现在它更易于在未来将`x`与`y`的计算分开 

一旦你创建了一个Promise并给它注册了一个完成和/或拒绝处理器，就没有什么你可以从外部做的事情能停止这个进程，即使是某些其他的事情使这个任务变得毫无意义。 

问题是这将允许Promise的一个消费者/监听器影响某些其他消费者监听同一个Promise的能力。这违反了未来值得可靠性原则（外部不可变） 

没有一个单独的Promise应该是可以取消的，但是一个 *序列* 可以取消是有道理的，因为你不会将一个序列作为一个不可变值传来传去，就像Promise那样 





























关于 `resolve()` 和 `reject()` 是同步还是异步修改了 promise 的状态这个问题, 换句话说, 我们想知道下面这个例子中的输出结果是怎样的.

```javascript
const rsp = new Promise(rs => rs(0));
const rjp = new Promise((rs, rj) => rj(0));
console.log(rsp);
console.log(rjp);
// Promise {resolved}
// Promise {rejected}
```

从输出上来看, 我们应该是可以认为 `resolve()` 和 `rejected()` 都是同步修改 promise 的状态的, 但是熟悉规范的我们知道, `resolve()` 是否修改状态取决于传给它的参数是什么, 如果传给它一个 pending 的 promise, 那毫无疑问它应该是异步将我们这里的 `rsp` 置为 resolved 的. 而另一方面, `console.log()` 也不一定是同步的, 这东西也看具体环境, 又或者我们这里打印的是对象, 在控制台展开的时候才进行了取值, 而并非打印对象的快照, 所以你看到的结果可能欺骗了你.

所以现在我们还是无法确定它们是同步修改 promise 状态还是异步修改状态. 但是我们可以确定的是, 对于 `resolve()` 是有可能异步修改状态的, 基于要么都同步要么都异步的原则, 一开始猜测是 `resolve()` 总是异步修改状态的, 而出于一致性考虑, 作为成对出现的 `reject()` 也应该是异步修改状态的. 但是在 vscode 的 node 环境下, 又可以确定的是, `console.log()` 是同步的, 并且 vscode 的控制台也不需要我展开对象就能看到 promise 的状态, 所以这样看来的话, **`resolve()` 和 `reject()` 对于基本类型的参数, 都是同步修改 promise 状态的, 而 `reject()` 不论什么类型的值, 总是同步修改 promise 的状态的.** 但是这个结论只是一个特定环境下观察得到的结论, 所以也不一定靠谱就是了. 总的来说规范没对此做要求, 从规范的字里行间给人感觉也是 `reject()` 是同步修改状态的(虽然规范没有定义 `reject()` 方法, 但从 Promise Resolution Procedure 中 pending 状态转移到 rejected 状态的过程来看, 这是一个同步的操作, 出于一致性考虑, 那 `reject()` 也应该是个同步操作). 另一方面是, 因为 pending, fulfilled, rejected 其实只是内部状态, 从我们的代码中实际上也无法获取, 能够看见它们也只是调试器的功劳, 实际情况下我们不会有要从外部观察一个 promise 状态这样的需求, 我们也不能拿到它的状态, 这个状态是同步修改还是异步修改也不影响对 `onFulfilled()` 和 `onRejected()` 的调用时机(它们总是异步调用), 所以其实这个问题也不必纠结, 只是纯属个人好奇而已.











Promise.resolve() 并不总是得到一个全新的 promise, 如果给它一个 thenable 它会展开它并返回一个 promise, 如果给它一个 promise 它直接返回这个 promise, 所以如果下面这样是相等的.

```javascript
var p1 = new Promise(rs => {
	rs(5);
});

var p2 = Promise.resolve(p1);

console.log(p1 === p2); // true
```



Promise.resolve() 并不总是得到一个 fulfilled 的 promise, 也可能得到一个 rejected 的 promise, 所以这也是为什么它叫 Promise.resolve() 而不是叫 Promise.fulfill() 的原因. 正如它的名字, 它只是解析一个值, 所以如果这个值是一个 rejected 的 promise, 那它得到的就是一个 rejected 的 promise, 就像这样.

```javascript
var p = new Promise((rs, rj) => rj());
var p1 = Promise.resolve(p);
p1.then(() => console.log('fulfilled'), () => console.log('rejected'));
// rejected
```

而 Promise.reject() 则不会展开 thenable, 它只会把你传给它的值作为一个新 promise 的 reason, 无论这个值是否是 promise 或是 thenable.

```javascript
var p = new Promise((rs, rj) => rj());
var p1 = Promise.reject(p);
console.log(p === p1); // false
p1.then(null, v => console.log(p === v)); // true
```

同样, Promise 构造函数的回调参数的第二个参数 rj 也是如此, 它不会像 rs 那样展开 thenable, 所以这个例子中两个 promise 的情况其实是很不一样的.

```javascript
function sleep(time) {
	return new Promise(rs => setTimeout(rs, time));
}

var p1 = new Promise(rs => {
	rs(sleep(3000));
});
p1.then(v => console.log('fulfilled'));

var p2 = new Promise((rs, rj) => {
	rj(sleep(3000));
});

p2.then(null, v => console.log(v));
// Promise
// fulfilled
```

尽管它们看上去只有细微的差别, 但是由于 rj 并不会展开 thenable, 所以它立即就变成 rejected 了并立即调用了 onRejected, 而 p1 则需要等待 3 秒后才会调用 onFulfilled 并执行输出. 所以是 Promise.reject() 总是得到一个 rejected 的 promise, 也如它的名字真的是 reject, 而 resolve 则不是 fulfill, 所以总是 resolve 和 reject 作为 API 成对出现而不是 fulfill 和 reject 成对出现.

至于 onFuifilled 和 onRejected, 则都会对 thenable 的返回值进行展开, 这点熟悉 Promise/A+ 规范的话应该很清楚了.





技巧, 异步操作超时检测, 如下

race 的意义是取得最先完成的那个 promise 的值, 这等价于取得最先完成的那个异步操作的结果, 但是会执行所有异步操作, 而不是如果有一个异步操作完成, 则终止其他异步操作. 比如如下例子.

```javascript
function sleep(time) {
	return new Promise(rs => setTimeout(rs, time));
}

var p1 = new Promise(rs => {
	setTimeout(() => {
		console.log('test');
		rs();
	}, 5000);
});
var p2 = sleep(3000);

Promise.race([p1, p2]).then(() => {
	console.log('over');
});
// over
// test
```

这两个异步操作是都会被执行的, 所以不要用 `race()` 去做哪些多个异步操作修改同一状态的事, 可能你拿到的值是正确的, 然后过了一段时间又因为其他异步操作而被修改了. 当然, 从本质上讲这不是 race 的问题, 因为 race 本来就是在 Promise 之上的抽象, 它只关心怎么拿到第一个 fulfilled 的 promise 的值, 它不关心是否会执行所有的异步操作. 而执行异步操作是 promise 的副作用, promise 本身只代表了一个未来的结果, 而 promise 的副作用最终也导致了 race 的副作用, 那就是会执行所有的异步操作且无法终止它们. 所以最终如果你觉得 race 的行为不符合你的期望, 那只能是你自己对 race 的理解产生了偏差.





#### 参考资料

* https://promisesaplus.com/
* https://github.com/getify/You-Dont-Know-JS/blob/1ed-zh-CN/async%20%26%20performance/ch2.md
* https://github.com/getify/You-Dont-Know-JS/blob/1ed-zh-CN/async%20%26%20performance/ch3.md
* https://blog.grossman.io/how-to-write-async-await-without-try-catch-blocks-in-javascript/
* https://github.com/scopsy/await-to-js/blob/master/src/await-to-js.ts