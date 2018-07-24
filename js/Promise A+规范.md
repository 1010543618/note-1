*注: 本文中 promise, 一个 Promise, 或一个 Promise 对象, 均指一个 Promise 对象, 下面内容中可能随机使用, 但它们都是一个意思, 而 `promise` 则特指前面代码中出现的 promise 对象.*

一个 Promise (对象)代表了一个异步操作的最终结果. 与一个 Promise 对象进行交互的基本方式是通过它(Promise 对象)的 `then` 方法, `then` 方法接受两个回调函数作为参数, 这两个回调函数分别用来接受一个 Promise 对象的最终值(value)或一个 Promise 为什么不能 fulfilled 的原因(reason).

本规范详细定义了 `then` 方法的行为, 为所有符合 Promise/A+ 规范的 Promise 实现提供了一个互操作的基础. 因此, 本规范可以被认为是非常稳定的. 尽管 Promise/A+ 组织可能会因为一些新发现的边界情况对本规范做出一些修订, 但这些改动都是微小且向后兼容的. 如果我们要进行大规模不向后兼容的修改, 我们一定会小心谨慎地考虑, 讨论和测试.

从历史上说, Promise/A+ 规范把之前 Promise/A 规范中的建议明确了, 将一些规范中省略了但是是事实上的行为给明确成了规范, 也删去了一些有问题的内容.

最后, 核心的 Promise/A+ 规范不设计如何创建, fulfill 和 reject 一个 Promise(对象), 即不指导具体实现也不定义/约束这几个部分的内容, 而是专注于提供一个可互操作的 `then` 方法. 其他相关规范(比如 ES6?)中的未来工作可能会涉及这些主题(如何创建, fulfill, reject 一个 Promise).



#### 1. 术语

1.1. "promise" 是一个具有 `then` 方法的对象或函数, 其行为符合本规范.

1.2. "thenable" 是一个定义了 `then` 方法的对象或函数(但行为不一定要符合本规范)

1.3. "value" 是任意合法的 Javascript 值(包括但不限于 `undefined`, 一个 thenable 对象或一个 promise)

1.4. "exception" 是一个使用 `throw` 抛出的值(value)

1.5. "reason" 是一个表明为什么一个 promise 会是 rejected 的值(value)

(其实我们可以看出来, exception 是一个 value, reason 也是一个 value)



#### 2. 要求

##### 2.1. Promise 状态

一个 promise 的当前状态必须是以下三个中的一个: pending, fulfilled, rejected.

2.1.1. 当处于 pending 状态时, 一个 promise:

​	2.1.1.1. 可以转移到 fulfilled 或 rejected 状态

2.1.2. 当处于 fulfilled 状态时, 一个 promise:

​	2.1.2.1. 不能转移到其他任何状态

​	2.1.2.2. 必须有一个 value, 并且 value 必须不会(在之后被)改变

2.1.3. 当处于 rejected 状态时, 一个 promise:

​	2.1.3.1. 不能转移到其他任何状态

​	2.1.3.2. 必须有一个 reason, 并且它(value)必须不会(在之后被)改变

这里, 必须不会改变的定义是 `===` 相等性判定为 `true`, 而非要求对象的属性值及结构都不变, 即只要求指向地址不变.



#### 2.2 `then` 方法

一个 promise 必须提供一个 `then` 方法来访问它当前或最终的 value 或 reason.

一个 promise 的 `then` 方法接受两个参数:

```javascript
promise.then(onFulfilled, onRejected)
```

2.2.1. `onFulfilled` 和 `onRejected` 都是可选的

​	2.2.1.1. 如果 `onFulfilled` 不是一个函数, 则它必须被忽略

​	2.2.1.2. 如果 `onRejected` 不是一个函数, 则它必须被忽略

2.2.2. 如果 `onFulfilled` 是一个函数:

​	2.2.2.1. 则它必须在 `promise` 状态为 fulfilled 之后被调用, 它的第一个参数是 `promise` 的 value

​	2.2.2.2. 它一定不能在 `promise` 状态为 fulfilled 之前被调用

​	2.2.2.3. 它最多被调用一次

2.2.3. 如果 `onRejected` 是一个函数:

​	2.2.3.1. 则它必须在 `promise` 状态为 rejected 之后被调用, 它的第一个参数是 `promise` 的 reason

​	2.2.3.2. 它一定不能在 `promise` 状态为 rejected 之前被调用

​	2.2.3.3. 它最多被调用一次

2.2.4. `onFulfilled` 或 `onRejected` 只有在执行上下文([execution context](https://es5.github.io/#x10.3))栈中仅剩平台代码时才会被调用[3.1]

2.2.5. `onFulfilled` 和 `onRejected` 必须被作为函数调用(即没有 `this`, 也不是作为构造函数调用)[3.2]

2.2.6. 同一个 promise 的 `then` 方法可以被调用多次

​	2.2.6.1. 如果/当 `promise` 的状态是 fulfilled, 其相应的所有 `onFulfilled` 回调函数必须按照它们通过 `then` 注册的顺序依次调用执行

​	2.2.6.2. 如果/当 `promise` 的状态是 rejected, 其相应的所有 `onRejected` 回调函数必须按照它们通过 `then` 注册的顺序依次调用执行

2.2.7. `then` 方法必须返回一个 promise [3.3]

```javascript
promise2 - promise1.then(onFulfilled, onRejected);
```

​	2.2.7.1. 如果 `onFulfilled` 或 `onRejected` 返回一个 value `x`, 则运行 Promise 解析处理程序(Promise Resolution Procedure) `[[Resolve]](promise2, x)`

​	2.2.7.2. 如果 `onFulfilled` 或 `onRejected` 抛出了一个异常 `e`, `promise2` 必须转移到 rejected 状态, 并且将 `e` 作为 reason

​	2.2.7.3. 如果 `onFulfilled` 不是一个函数并且 `promise1` 是 fulfilled 状态, 则 `promise2` 必须是 fulfilled 状态, 并且它的 value 和 promise1 一样

​	2.2.7.4. 如果 `onRejected` 不是一个函数并且 `promise1` 是 rejected 状态, 则 `promise2` 必须是 rejected 状态, 并且它的 reason 和 `promise1` 一样



#### 2.3 Promise Resolution Procedure

**Promise Resolution Procedure** 是一个抽象操作(就当它是一个函数), 它接受一个 promise 对象和一个 value 作为输入(参数), 我们将其表示为 `[[Resolve]](promise, x)`, 即 `[[Resolve]]` 是一个内部方法, `x` 是一个 value. 如果 `x` 是一个 thenable 对象, 它(指代 Promise Resolution Procedure 或 `[[Resolve]]` 方法)尝试让 promise 的状态和 `x` 的状态保持一致, 即它假设 `x` 的行为至少有一些类似一个 promise. 否则(`x` 不是一个 thenable 对象)它将 promise 的状态设置为 fulfilled, 并使 `promise` 的 value 为 `x`.

这种处理 thenable 对象的方式允许 Promise 的实现具有互操作性, 只要它们(thenable 对象们)暴露一个 Promise/A+ 规范兼容的 `then` 方法即可. 它还允许 Promise/A+ 的实现使用合理的方式去同化那些(与 Promise/A+)不一样的 `then` 方法实现.

运行 `[[Resolve]](promise, x)`, 会执行以下步骤:

2.3.1. 如果 `promise` 和 `x` 指向同一个对象, 则将 `promise` 置为 rejected, 并用一个 `TypeError` 作为 reason

2.3.2. 如果 `x` 是一个 promise, 则 `promise` 采用 `x` 的状态(与 `x` 状态一致) [3.4]

​	2.3.2.1. 如果 `x` 是 pending 状态, 则 `promise` 必须保持 pending 状态直到 `x` 变为 fulfilled 或 rejected (之后 `promise` 的状态也跟着变为相应状态).

​	2.3.2.2. 如果/当 `x` 是 fulfilled 状态, 则将 `promise` 置为 fulfilled 状态, 并具有和 `x` 一样的 value.

​	2.3.2.3. 如果/当 `x` 是 rejected 状态, 则将 `promise` 置为 rejected 状态, 并具有和 `x` 一样的 reason.

2.3.3. 否则, 如果 `x` 是一个对象或函数

​	2.3.3.1. 令 `then` 为 `x.then`, 即将 `x.then` 赋值给一个临时变量 `then` [3.5]

​	2.3.3.2. 如果取 `x.then` 时抛出了一个异常 `e`, 则将 `promise` 置为 rejected, 并用 `e` 作为它的 reason

​	2.3.3.3. 如果 `then` 是一个函数, 则调用它并用 `x` 作为它的 `this`, 给它传递两个回调函数作为参数, 第一个参数是 `resolvePromise`, 第二个参数是 `rejectPromise`, 它们:

​		2.3.3.3.1. 如果/当 `resolvePromise` 被传入参数 `y` 调用时, 则执行 `[[Resolve]](promise, y)`

​		2.3.3.3.2. 如果/当 `rejectPromise` 被传入参数 `r` 调用时, `r` 是一个 reason, 则将 `promise` 置为 rejected, 并用 `r` 作为它的 reason

​		2.3.3.3.3. 如果 `resolvePromise` 和 `rejectPromise` 都被调用了, 或多次以相同的参数调用了, 则采用第一次被调用的那个函数(采用应该是指只对第一次的调用按照上面两步的操作执行), 之后的调用都被忽略

​		2.3.3.3.4. 如果调用 `then` 抛出了一个异常 `e`.

​			2.3.3.3.4.1. 如果 `resolvePromise` 或 `rejectPromise` 已经被调用过了, 则忽略它(它应该是指 `e`)

​			2.3.3.3.4.2. 否则将 `promise` 置为 rejected, 并用 `e` 作为其 reason

​	2.3.3.4. 如果 `then` 不是一个函数, 则将 `promise` 置为 fulfilled, 并用 `x` 作为其 value

2.3.4. 如果 `x` 不是一个对象或函数, 则将 `promise` 置为 fulfilled, 并用 `x` 作为其 value

如果一个 promise resolve 了一个 thenable 对象, 并且这个 thenable 对象具有一个循环的 thenable 链(比如一个对象的 `then` 返回了它自身), 这样的话, 由于 `[[Resolve]](promise, thenable)` 的递归性, 最终会导致 `[[Resolve]](promise, thenable)` 再一次被调用, 导致无限循环. 规范鼓励实现去检测这样的递归, 并最终用一个 `TypeError` 作为 reason 将 `promise` 置为 rejected, 但也不强制要求这一点. [3.6]



#### 3. 注

3.1. 这里平台代码指的是引擎, 运行环境和 promise 的实现代码. 在实践中, 要求确保 `onFulfilled` 和 `onRejected` 被异步执行, 且在 `then` 被调用的那一轮事件循环之后执行, 且具有一个干净的栈(应该是指一轮事件循环只包含 `onFulfilled` 或 `onRejected` 的任务了). 这可以通过 macro-task 机制实现, 就像 `setTimeout` 或 `setImmediate` 那样. 也可以使用 micro-task 机制实现, 就像 `MutationObserver` 或 `process.nextTick` 那样. 因为 promise 的实现自身也被视为平台代码, 所以可能在调用 `onFulfilled` 或 `onRejected` 的时候已经包含了任务调度队列或 trampoline(什么卵?). (总的来说就是要确保 `onFulfilled` 和 `onRejected` 被异步执行, 至于是 macro-task 还是 micro-task 都无所谓, 不过貌似现有的实现都是 micro-task)

3.2. 严格模式下 `this` 是 `undefined`, 非严格模式下 `this` 是全局对象

3.3. 对于具体的实现, 可以允许 `promise2 === promise1`, 只要实现满足了所有的要求. 每种实现都应当在文档注明释放允许 `promise2 === promise1` 以及什么情况下会出现这种情况

3.4. 通常来说, 只有当 `x` 是符合当前规范的实现时, 才会被视为一个真正的 promise. 这一规则允许符合规范的 promise 接受那些特殊实现的 promise 的状态

3.5. 这步过程先是暂存了 `x.then` 的引用, 然后测试该引用, 然后调用该引用, 避免了多次访问 `x.then` 属性. 这些预防措施对于确保该属性的一致性来说非常重要, 因为属性的值可能在多次查找(左值查询)之间被改变

3.6. 实现不应该限制 thenable 链的深度, 也不应该假设(深度)超过某一限度就视为无限递归的. 只有真正的循环才会导致 `TypeError`, 如果一个无限长的 thenable 链上每一个 thenable 做的事情都不同, 那无限递归就(反而)是正确的行为



#### 参考资料

* https://promisesaplus.com/