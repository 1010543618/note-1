本文主要是整理过去零散的知识点, 以及近期翻了下 Node 官方文档, 补充下盲点, 可能不是很详尽.

### 阻塞和非阻塞

老样子先从定义出发, 在本文中都以 Node 官方对阻塞和非阻塞的定义为准.

> Blocking is when the execution of additional JavaScript in the Node.js process must wait until a non-JavaScript operation completes. This happens because the event loop is unable to continue running JavaScript while a blocking operation is occurring.
>
> In Node.js, JavaScript that exhibits poor performance due to being CPU intensive rather than waiting on a non-JavaScript operation, such as I/O, isn't typically referred to as blocking. Synchronous methods in the Node.js standard library that use libuv are the most commonly used blocking operations. Native modules may also have blocking methods.
>
> All of the I/O methods in the Node.js standard library provide asynchronous versions, which are non-blocking, and accept callback functions. Some methods also have blocking counterparts, which have names that end with Sync.

阻塞是指在 Nodejs 进程中执行其他 JavaScript 代码(相对于当前 JavaScript 代码, 比如异步回调中的 JavaScript 就算其他 JavaScript 代码)必须等待非 JavaScript 部分(比如一些同步 IO 由底层的 C/C++ 完成就属于非 JavaScript 部分)的操作完成(这一情况).

如果是由于 JavaScript 本身对于 CPU 密集型操作的性能表现不佳而不是非 JavaScript 操作导致的等待通常不被称为阻塞. Nodejs 标准库中的同步方法, 底层使用的 libuv, 是常见的阻塞操作. 原生模块(C/C++)也可能有阻塞方法.

Nodejs 标准库中的所有 IO 方法都提供了异步版本, 接受回调函数, 它们都是非阻塞的. 这些方法中的一些也有对应的阻塞方法, 通常以 `Sync` 结尾.

从以上可以看到, **Node 对阻塞的定义仅限于那些非 JavaScript 操作导致其他 JavaScript 代码等待, 也就是同步的 IO, 加密或者同步的 C/C++ 模块等会导致这一定义下的阻塞.** 不过广义上来讲, 我们也把 CPU 密集的 JavaScript 操作视为阻塞, 因为它会使得事件循环长时间停留在某个阶段, 导致后续的任务饥饿.



### 一些基本常识

* JavaScript 是单线程执行的, 但是 Nodejs 是多线程的
* 多线程是 libuv 提供的, V8 只跑一个线程也就是 JS 的执行线程(除非用到 VM 等模块)
* 浏览器的事件循环和 Node 的事件循环是不一样的, 所以一段代码在浏览器上跑出的结果和 Node 不一样是很正常的
* callback 不一定是异步调用, 也可能是同步调用
* 所有的异步 API 的 callback 都会在同步代码执行完之后被执行



### 术语

* **主模块(main module):** 我们把从入口文件开始及其依赖的文件中所有同步代码部分都视为主模块
* **调度(schedules):** 调度这个词其实就是指通过某个异步 API 注册一个 callback, 基本上可以和注册等价替换
* **定时器(Timers):** 本文中主要指 Timers 模块中的异步 API, 即 `setTimeout()` `setInterval()` `setImmediate()`, 不过大部分时候会排除掉 `setImmediate()` 而特指前两个, 本文中理解成前两个即可
* **任务:** 通常是指一些 CPU 密集的任务, 是 C/C++ 层面的事情
* **事件:** 本文中的事件不是指 JS 层面的事件, 而是系统通知 Node 任务完成的事件, 不过事件和 JS 层面的 callback 也是一一对应的就是, 从这个角度来说, 任务 - 事件 - callback 都是对应的
* **队列:**  下面队列一词有时候是指事件的队列, 这通常是 C/C++ 层面的, 有时候是指通过 Node API 注册的 callback 的队列, 不过其实处理了事件的队列就可以理解为执行了 JS callback 的队列

以下内容是简单版.



### Node 的工作流程

Node 启动时会初始化事件循环, 然后执行主模块的代码, 当主模块代码执行完之后就开始处理事件循环, 注意一开始只是初始化而不是处理事件循环. 如果事件循环中没有任务了, Node 进程就停止了. 换句话说, Node 一开始就把所有同步代码的调用栈全部展开执行完了, 然后剩下的全是异步任务, 等这些异步任务也都执行完, Node 进程就停止. 也即 Node 的运行分为两个部分, 一开始的主模块执行, 到后面的事件循环的处理.



### 什么是事件循环

Node 中有两种类型的线程: 一个 Event Loop(事件循环线程, 也叫主线程, 后面都简称事件循环), 以及 Worker Pool(工作线程池)里的 k 个 worker 线程. 事件循环线程负责轮询多个队列中的任务(不过事件循环本身并不维护队列), 并将任务交给 worker 线程执行, 这里的任务是指 C/C++ 执行的操作, 而非 JS 的 callback, 因为对于大部分操作, 比如 IO, 加密等, 都不是 JS 本身来完成的, 而是交给相应的 C/C++ 模块去处理.

事件循环线程则是轮询这些任务看它们是否完成, 当它们被完成之后, 就处理对应的事件并执行事件对应的 JS 层面的 callback.

而 worker 线程则是执行 IO, 加密等高成本的任务, 当事件循环线程把任务交给 woker 线程处理会涉及一些 JS 和 C/C++ 的通信, 自然也会存在一些开销.

从这里可以看出来, 主线程主要就做两件事: 执行 JS 代码和轮询. 反过来, JS 代码都是由主线程执行的(不过现在 Node 有了新的 Worker Thread 模块, 这样说好像也不完全对了).



### 阶段

前面说了有多个队列, 为什么是多个? 只是根据它们的任务共同点划分的而已, 当事件循环处理到某一个队列的任务时(这里说是说事件循环处理到某个队列的任务, 准确说应该是看看这个队列的任务完成没, 任务实际上是由 worker 来处理的), 我们就说事件循环处于某个阶段, 换句话说, 队列和阶段一一对应, 每个阶段有自己的队列.

事件循环处理完一个阶段就跳到下一个阶段, 所有阶段都处理完算一轮事件循环, 然后又从头开始. 处理完是指达到某个特定条件, 而非将该阶段的任务都处理完毕直到没有待处理的任务.

Node 中的阶段我们主要关心以下几个:

```
   ┌───────────────────────────┐
┌─>│           timers          │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
│  │     pending callbacks     │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
│  │       idle, prepare       │
│  └─────────────┬─────────────┘      ┌───────────────┐
│  ┌─────────────┴─────────────┐      │   incoming:   │
│  │           poll            │<─────┤  connections, │
│  └─────────────┬─────────────┘      │   data, etc.  │
│  ┌─────────────┴─────────────┐      └───────────────┘
│  │           check           │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
└──┤      close callbacks      │
   └───────────────────────────┘
```

- **timers**: 这一阶段执行由 `setTimeout()` 和 `setInterval()` 注册的 callback
- **pending callbacks**: 执行延迟到下一轮循环的 IO callback(应该是指本该上一轮完成的 IO callback, 但是因为达到该阶段 callback 限制而被延迟到下一轮的 callback), 以前这里叫 IO callback 阶段, 不过看上去现在改了, 而且功能相差蛮大的
- **idle, prepare**: 仅在 Node 内部使用, 跟 JavaScript 没什么关系
- **poll**: 检索新的 IO 事件(即通过系统调用轮询 IO 是否完成); 执行 IO 相关的 callback; Node 在适当的时候会在这里阻塞
- **check**: `setImmediate()` 的 callback 在这里调用
- **close callback**: 一些关闭回调, 比如 `socket.on('close')`

这里首先要说下 poll 阶段, 也即轮询阶段. 为什么叫轮询阶段? 让我们考虑下, 假如一段代码, 就只调用异步 API 读取了一个大文件, 没有设置定时器, 那 Node 在干什么? 当然是只能干等着, 调用系统 API 轮询这个 IO 操作是否完成. 干等着的这段时间就是 poll 阶段.

那假如有定时器呢? 那 Node 就看看定时器还有多久, 如果还早, 就继续在 poll 阶段等着.

那等多久呢? 文件什么时候会读完 Node 是肯定不知道的, 只能等系统通知, 但是 Node 可以知道定时器还有多久, 以及有没有设置 `setImmediate()`. 所以大概情况就是, Node 先看一下定时器到了没, 没到, 再看看 IO 好了没, 没好, 再看看有没有 `setImmediate()`, 有就执行, 没有继续在 poll 阶段等着看表, 如果定时器快到了 IO 还没好, 就到 timers 阶段去执行定时器, 然后继续.

所以可以看到, Node 大部分时间可能都在 poll 阶段等着.

这些阶段都有一定的限制, 并不是要把该阶段所有任务都处理完了才进入下一阶段. 比如有些有最大 callback 调用数量的限制, 有些(poll 阶段)有最长停留时间的限制, 那些没被执行的 callback 就被移到下一轮循环的 pending callbacks 阶段执行了, 这样有利于防止一直阻塞在某个阶段导致后面的任务长时间得不到执行.



### 几类异步 API 的区别

前面已经大概知道哪些异步 API 的 callback 会在哪些阶段执行. 这里具体说下.

* `setTimeout()`/`setInterval()`: callback 总是被添加后面某一轮的 timers 阶段, 最少是下一个最近的 timers 阶段, 这意味着递归调用它们不会使 Node 一直阻塞在 timers 阶段, Node 本身是不知道具体该添加到哪一轮循环的 timers 阶段, 但是 Node 知道时间到了以后就把 callback 添加到最近的下一个 timers 阶段
* `setImmediate()`: callback 总是被添加到下一个最近的 check 阶段, 同样, 递归调用它不会使 Node 一直阻塞在 check 阶段
* 异步 IO: callback 可能被添加到当前轮的 poll 阶段, 也可能添加到后面某一轮的 poll 阶段, 因为 IO 什么时候完成是由系统通知的, Node 也不知道, 所以 Node 也不知道具体将 callback 添加到哪一轮的 poll 阶段, 但是 Node 如果在 poll 阶段轮询到 IO 完成了的话就会把它添加到当前 poll 阶段, 所以理论上来说, 递归调用异步 IO 是可以使事件循环阻塞在 poll 阶段的, 但是如果有定时器的话, 这事情实际上也是不会发生的, 而如果没有定时器, 那阻塞在 poll 阶段就是我们想要的
* `process.nextTick()`: callback 总是被添加到当前阶段的最后, 这意味着递归调用 `process.nextTick()` 会使 Node 一直阻塞在某个阶段而无法进入到下一阶段
* `promise.then()`: callback 总是被添加到当前阶段的最后, 但是它的优先级比 `process.nextTick()` 低, 同样地, 递归调用它会使 Node 一直阻塞在某个阶段而无法进入到下一阶段



### 总结

虽然看完了以后我们能够知道这些异步 API 之间的执行顺序, 从而使得多个异步操作的执行顺序可以预测, 但是个人觉得永远不要去依赖这样的预测, 如果真的想确保多个异步操作的执行顺序应当使用 Promise, async/await 或其他异步控制流方案. 这些东西的执行顺序只有当需要写库做些针对性优化才会去考虑.

另外我觉得 Node 里面不应该再区分什么 macrotask 和 microtask 了, 那只是为了和浏览器环境保持兼容的, 相比之下 Node 的事件循环更加复杂一点.





下面是完整的介绍, 翻译自 Node 官方文档, 加上了一些个人理解.

### 什么是事件循环

尽管 JavaScript的执行是单线程的, 但是通过事件循环使得 Nodejs 可以执行非阻塞的 IO 操作, 怎么做到? 通过尽可能地将这些操作交给操作系统内核.

因为大多数现代内核都是多线程的, 他们可以在后台处理多个操作. 当其中一个操作完成时, 内核会通知 Nodejs, 然后 Nodejs 便会将相应的 callback 添加到 poll 队列中, 最终这些 callback 将被执行.



### 事件循环的详细解释

当 Nodejs 启动时, 它初始化事件循环(注意是初始化, 不是启动/处理), 处理提供的输入脚本, 这些脚本(的主模块 main module 部分)可能会进行异步 API 调用, 调用定时器(Timers API), 或调用 `process.nextTick()`, 然后开始处理事件循环.

下图是事件循环的简单概述.

```
   ┌───────────────────────────┐
┌─>│           timers          │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
│  │     pending callbacks     │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
│  │       idle, prepare       │
│  └─────────────┬─────────────┘      ┌───────────────┐
│  ┌─────────────┴─────────────┐      │   incoming:   │
│  │           poll            │<─────┤  connections, │
│  └─────────────┬─────────────┘      │   data, etc.  │
│  ┌─────────────┴─────────────┐      └───────────────┘
│  │           check           │
│  └─────────────┬─────────────┘
│  ┌─────────────┴─────────────┐
└──┤      close callbacks      │
   └───────────────────────────┘
```

每个框都被称为事件循环的 "阶段"(phase).

每个阶段都有一个待执行的 callback 的 FIFO 队列. 虽然每个阶段都有自己的特殊操作(应该是一下非 JavaScript 操作), 但通常, 当事件循环进入到一个给定的阶段时, 它会执行任何处于这一阶段的操作(应该是一些 C/C++ 的调度操作之类), 然后执行这一阶段的 callback 队列中的 callback, 直到队列为空或达到执行 callback 数量的最大限制, 然后事件循环会进入下一个阶段, 以此类推.

由于这些操作中的任何一个都可以调度更多操作(调度更多操作是指调用异步 API, 比如添加定时器或使用 `process.nextTick()` 等), 并且系统内核也可能在 poll 阶段添加新的事件(这里的事件应该是指系统内核来的通知, 而不是 JS 层面的事件, 所以这里添加新的事件应该是指系统通知 Node 有新的 IO 完成了, 但是一个事件还是会对应到 JS 层面的一个 callback 就是了), 比如当一个 IO 事件被处理时(处理包含了 C/C++ 层面的处理, 以及调用事件对应 JS 层面的 callback)可能会有其他 IO 完成产生的新事件在排队等待. 因此长时间运行的 callback 可能导致 poll 阶段运行的时间比定时器设置的阈值时间更长(即导致定时器 callback 的执行时机远超设置的时间). 整个这段话应该是指在执行 poll 阶段的队列中的 callback 的时候, 调用其它异步 API, 比如 `process.nextTick()`, 或 Node 发现某个 IO 完成了, 于是执行对应 callback, 这时候内核又通知有新的 IO 完成了, 如果这些 IO callback 执行时间很长, 都会导致事件循环长时间停留(根据定义来说这也不算是阻塞)在这一阶段, 最终导致其他任务长时间得不到执行.

*注意: Windows 和 Unix/Linux 的实现之间存在细微的差异, 不同平台有不同的阶段, 有些有七八个阶段, 不过这个影响不大.*



### Phases 概述

* **timers**: 这一阶段执行由 `setTimeout()` 和 `setInterval()` 调度(注册)的 callback
* **pending callbacks**: 执行延迟到下一轮循环的 IO callback(应该是指本该上一轮完成的 IO callback, 但是因为达到该阶段 callback 限制而被延迟到下一轮的 callback), 以前这里叫 IO callback 阶段, 不过看上去现在改了, 而且功能相差蛮大的
* **idle, prepare**: 仅在 Node 内部使用, 跟 JavaScript 没什么关系
* **poll**: 检索新的 IO 事件(即通过系统调用轮询 IO 是否完成); 执行 IO 相关的 callback(基本上是因为异常关闭的 callback, 定时器以及 `setImmediate()` 调度的 callback? 不知道为什么说定时器和 `setImmediate()` 调度的 callback 也在这里执行, 建议暂时忽略...); Node 在适当的时候会在这里阻塞
* **check**: `setImmediate()` 的 callback 在这里调用
* **close callback**: 一些关闭回调, 比如 `socket.on('close')`

在每一轮事件循环之间, Nodejs 检查它(事件循环的线程也即主线程)是否在等待任何异步 IO 或定时器, 如果没有的话, Node 进程就会结束.



### Phases 的细节

#### timers

一个定时器指定一个阈值(threshold), 阈值是指一个给定的 callback 可以在阈值时间之后被执行, 而不是人们期望它一定会在准确的时刻被执行, 其实就是 `setTimeout` 的机制. 定时器的 callback 将在指定的阈值时间过去之后尽快被调度执行, 但是操作系统调度或其他正在运行的 callback 可能会延迟它们(timers callback)的执行.

*注意: 技术上讲, poll 阶段控制何时执行 定时器的回调(其实就是说, 定时器的回调受 poll 阶段的时长影响).*

例如, 假设你计划在 100ms 阈值之后执行 `setTimeout()` 的 callback, 然后你的脚本又启动了一个耗时 95ms 的异步读取文件的操作.

```javascript
const fs = require('fs');

function someAsyncOperation(callback) {
  // Assume this takes 95ms to complete
  fs.readFile('/path/to/file', callback);
}

const timeoutScheduled = Date.now();

setTimeout(() => {
  const delay = Date.now() - timeoutScheduled;

  console.log(`${delay}ms have passed since I was scheduled`);
}, 100);


// do someAsyncOperation which takes 95 ms to complete
someAsyncOperation(() => {
  const startCallback = Date.now();

  // do something that will take 10ms...
  while (Date.now() - startCallback < 10) {
    // do nothing
  }
});
```

当事件循环进入 poll 阶段时, 如果 poll 队列暂时还是空的(`fs.readFile()` 尚未完成), 因此它将等待一段时间(根据一些情况计算出来的)直到最近快到的定时器阈值. 当它等待了 95ms 后, `fs.readFile()` 完成了读取文件, 于是它的 callback 被添加到 poll 的队列中并花费 10ms 执行该 callback. 当该 callback 结束时, poll 队列中没有 callback, 于是事件循环回到下一个 timers 阶段执行 `setTimeout()` 的 callback, 于是从 `setTimeout()` 开始调度, 到它的 callback 被执行之间间隔了 105ms.

*注意, 为了防止 poll 阶段使得事件循环出现饥饿现象, libuv 在达到最大停留时间的限制(取决于系统)后会停止 poll 阶段.*

从上面可以看出来, 向 poll 队列添加 callback 这一操作是由系统的事件来触发的, 即系统通知 Node 某个 IO 完成了, 于是 Node 才把 callback 添加到 poll 队列, 而不是 JS 调用 IO 的 API 就会把 callback 添加到 poll 队列. 其实也好理解, 因为 Node 本身是不能知道一个 IO 完成需要多长时间的, 那怎么确定将 callback 添加到当前这轮事件循环的 poll 队列, 还是下一轮或是后面好几轮呢, 只能是刚好处于 poll 阶段, 并且系统通知 IO 完成了, 才将 callback 添加到 poll 队列并执行. 这也意味着, 调用一个异步 IO 的 API, 注册的 callback, 可能在当前轮的 poll 阶段被执行, 也可能在后面某一轮的 poll 阶段被执行.

同样的道理, 其实定时器也是类似的, 假如一段代码, 既调用了异步 IO 的 API, 又调用了定时器的 API, 即便定时器的 callback 在 IO callback 之前被注册, 但是 Node 也不能确定到底是 IO 会先完成, 还是定时器会先到达, 这样的话, 考虑定时器设置的时间很长, 而 IO 耗时很短的情况, 虽然在一轮事件循环当中, poll 阶段在 timers 阶段的后面, 但是 Node 不可能按照注册 callback 的先后顺序就把 IO callback 排在定时器完成的那一轮的 poll 阶段, 也没法确定应该排在哪一轮 poll 阶段, 而是在 poll 阶段等着, 看 IO 和定时器谁先来就先执行谁.

所以不要觉得 IO 的 callback 总是应当在定时器 callback 之后执行, 这只是站在一轮的角度, 而实际上在无限轮时间尺度看来, 并没有哪个阶段在前哪个阶段在后一说. 另一方面, 定时器的 callback 调用和 IO callback 的调用还是有一些区别, IO callback 可能在当前轮 poll 阶段被调用, 也可能在后面某几轮的 poll 阶段被调用, 而定时器最快也是在最近的下一个 timers 阶段被调用, 也可能在后面某几轮的 timers 阶段被调用.

定时器好理解, 根据实际现象就可以推断出来, 如果说当前是 timers 阶段并且允许定时器的 callback 在当前 timers 阶段被调用, 就会导致递归调用定时器阻塞掉事件循环, 然而事实不是这样, 所以通过定时器注册一个 callback 最快也要下一个 timers 阶段才能被执行.

那为什么 IO callback 可以在当前 poll 阶段被执行, 也可以在后面某轮的 poll 阶段被执行? 主要是因为 poll 阶段的特殊性, 考虑如果事件循环中没有其它待处理的异步操作, 只有异步 IO, 那事件循环会一直停留在 poll 阶段. 为什么? 因为这种时候 Node 没别的事情可做啊, 只能轮询看看 IO 好了没, 这时候如果递归地调用异步 IO 的 API, 多次异步 IO 也都是在同一个 poll 阶段. 那如果有其他待处理的异步操作呢? 个人觉得应该取决于这些异步操作的类型吧, 比如如果一个定时器设定的时间很长, 则 poll 阶段停留的时间也会很长, 那递归调几次 IO, 可能它们的 callback 还是在同一个 poll 阶段.

 

#### pending callbacks

这一阶段执行一些系统操作的 callback(比如 TCP 错误). 例如, 如果 TCP socket 在尝试建立连接时收到 `ECONNREFUSED`, 一些 *nix 系统希望等待这些错误被报告. 如果 JS 层面对相关的异常事件注册了 callback 的话, 这些 callback 将被放到 pending callback 阶段的队列中被执行.

另外应该还包括前面提到的, 执行一些本该上一轮执行却因为某些原因被延迟的 IO callback.

#### poll

poll 阶段主要有两个功能:

1. 计算它应当阻塞多久以及轮询 IO(决定是否要执行 IO 的 callback), 比如如果有个 5s 后的定时器, 那可能 Node 就决定在这里停留 4.9s, 如果没有定时器, 那就决定一直停留在这里. 然后
2. 如果轮询到有完成了的 IO 的话, 则处理 poll 队列中的事件

当事件循环进入到 poll 阶段并且没有等待执行的 timers 的 callback, 将发生下面两种情况之一:

* 如果 poll 队列(指收到系统通知 IO 完成的事件的队列, 而不是 JS API 的 callback)不为空, 则事件循环将遍历该 callback 队列并同步执行它们(callback), 直到队列为空或达到最大停留时长限制
* 如果 poll 队列为空, 会发生以下两种情况之一:
  * 如果之前有通过 `setImmediate()` 注册了 callback, 则结束 poll 阶段进入到 check 阶段去执行这些 `setImmediate()` 的 callback
  * 如果之前也没有通过 `setImmediate()` 注册 callback, 则事件循环会继续停留在这一阶段等待新的 IO 完成事件被添加到 poll 队列, 并立即处理它(处理事件意味着也会执行 JS 层面的 callback)

一旦 poll 队列为空, 事件循环将检查定时器, 看哪个的阈值已经达到. 如果一个或多个定时器都到达阈值, 事件循环将会到下一轮的 timers 阶段来执行这些定时器的 callback.

#### check

这一阶段允许在 poll 阶段完成后立即执行一些 callback(通过 `setImmediate()` 注册的). 如果 poll 阶段空闲并且有 callback 已经通过 `setImmediate()` 注册, 则事件循环可以进入 check 阶段执行对应 callback 而不是一直在 poll 阶段等待.

`setImmediate()` 实际上是一个特殊的定时器, 它的 callback 运行在事件循环的一个单独的阶段. 它使用 libuv 的 API 来调度 callback 在 poll 阶段之后执行.

通常, 当执行代码时, 事件循环最终将进入 poll 阶段, 在那里它(Node)将等待到来的连接, 请求等等. 然而如果已经通过 `setImmediate()` 注册了 callback, 并且 poll 阶段空闲, 则事件循环将会结束掉 poll 阶段进入到 check 阶段, 而不是一直在 poll 阶段等待.

#### close callbacks

如果 socket 或者 handle 突然关闭, 例如 `socket.destory()` 则 `'close'` 事件将在此阶段触发. 否则它通过 `process.nextTick()` 发出.



### `setImmediate()` 和 `setTimeout()`

`setImmediate()` 和 `setTimeout()` 很相似, 但根据它们被调用的时机以不同的方式表现.

* `setImmediate()` 被设计为一旦当前(本轮事件循环) poll 阶段完成就立即执行 callback
* `setTimeout()` 则是调度 callback 在经过大于等于阈值时间之后执行 callback

执行 timer 的顺序根据调用它们的上下文不同而不同. 如果它们都是从主模块中被调用, 则 callback 执行的时机将受到进程性能的限制(比如可能受计算机上其他应用程序的影响).

什么叫受到性能的影响呢? 这里补充一下, 因为 `setTimeout()` 实际上是不能做到设置阈值为 0ms 的, 最小值为 1ms, 对于小于 1ms 的阈值, Node 都会设置成 1ms. 那么对于下面这个例子.

例如, 如果我们运行以下不在 IO 周期(即主模块)中的代码, 则两个 timer 的执行顺序是不确定的, 因为它受到进程性能的约束.

```javascript
// timeout_vs_immediate.js
setTimeout(() => {
  console.log('timeout');
}, 0);

setImmediate(() => {
  console.log('immediate');
});
$ node timeout_vs_immediate.js
timeout
immediate

$ node timeout_vs_immediate.js
immediate
timeout
```

这段代码在主模块中, 意味着如果机器性能好, 或者当前 CPU 负载比较低, 主模块在 1ms 内就执行完了, 然后开始几轮事件循环才到 1ms, 那 `setImmediate()` 的 callback 毫无疑问会先被执行. 而如果机器性能差, 或者当前 CPU 负载高, 导致主模块在 1ms 之后才被执行完, 那么根据前面的图, 在一轮事件循环中, timers 阶段比 check 阶段更早, 而这里是第一轮事件循环, 所以 `setTimeout()` 的 callback 会比 `setImmediate()` 先执行, 所以在主模块中调用了 `setTimeout()` 和 `setImmediate()` 的话, 是没办法确定两者 callback 的先后执行顺序的.

然而如果在一个 IO 周期中(poll 阶段)调用两者, 则 `setImmediate()` 的 callback 总是先执行.

```javascript
// timeout_vs_immediate.js
const fs = require('fs');

fs.readFile(__filename, () => {
  setTimeout(() => {
    console.log('timeout');
  }, 0);
  setImmediate(() => {
    console.log('immediate');
  });
});
$ node timeout_vs_immediate.js
immediate
timeout

$ node timeout_vs_immediate.js
immediate
timeout
```

使用 `setImmediate()` 而不是 `setTimeout()` 的主要优势是, 在一个 IO 周期中调用的话, `setImmediate()` 总是在其它 timer 之前被执行, 无论当前有多少个 timer.



### `Process.nextTick()`

#### 理解 `process.nextTick()`

你可能注意到, `process.nextTick()` 尽管它是异步 API 的一部分, 却没有在前面的图中显示. 这是因为从技术上讲 `process.nextTick()` 不是事件循环的一部分. 相反, `nextTickQueue` 中的 callback 总是会在当前操作(阶段)完成后处理, 而不管现在是事件循环的哪个阶段. 一部分原因是 `nextTickQueue` 不是 libuv 提供的, 而是 Node 中实现的, 而事件循环是由 libuv 驱动的.

回顾一下前面的图, 无论什么时候在哪个阶段调用 `process.nextTick()`, 所有通过 `process.nextTick()` 注册的 callback 都会在事件循环继续之前被执行(阻止事件循环进入下一个阶段). 这可能会产生一些不好的情况, 比如它允许你通过递归调用 `process.nextTick()` 来饿死 IO, 从而阻止事件循环到达 poll 阶段.

#### 为什么会允许这种情况?

为什么这样的东西会被包含在 Nodejs 中? 部分原因是设计理念, 一个 API 的 callback 应当始终是异步调用, 即使这么做不是很有必要. 看下面的例子.

```javascript
function apiCall(arg, callback) {
  if (typeof arg !== 'string')
    return process.nextTick(callback,
                            new TypeError('argument should be string'));
}
```

这段代码做了参数类型检查, 如果不正确, 它会将异常传递给 callback. 最近更新的 API 支持向 callback 传递参数, 因此不用再使用高阶函数.

我们做的事情是, 将错误传给用户, 但是是在其余的用户代码执行之后传递错误. 通过使用 `process.nextTick()`, 我们确保了 `apiCall()` 总是在其他用户代码执行完之后以及事件循环继续之前调用 callback. 其实这和 Promise 的思想一样, 异步 API 总是异步返回结果, 而异常作为另一种形式的结果, 也应当被异步地传递. 这也使得可以通过 `process.nextTick()` 被递归调用而不会导致堆栈溢出.

这一理念也会导致一些潜在的问题. 比如.

```javascript
let bar;

// this has an asynchronous signature, but calls callback synchronously
function someAsyncApiCall(callback) { callback(); }

// the callback is called before `someAsyncApiCall` completes.
someAsyncApiCall(() => {
  // since someAsyncApiCall has completed, bar hasn't been assigned any value
  console.log('bar', bar); // undefined
});

bar = 1;
```

尽管这是个 callback, 但它是同步调用的, 所以执行结果可能偏离预期.

通过将 callback 放入 `process.nextTick()` 中, 脚本能够正常运行, 允许在调用 callback 之前初始化变量, 函数等. 它还具有阻塞事件循环的优点. 在允许事件循环之前, 能够向用户发出警告有时候是有用的.

```javascript
let bar;

function someAsyncApiCall(callback) {
  process.nextTick(callback);
}

someAsyncApiCall(() => {
  console.log('bar', bar); // 1
});

bar = 1;
```

另一个实际的例子.

```javascript
const server = net.createServer(() => {}).listen(8080);

server.on('listening', () => {});
```

想象中调用 `listen()` 时会立即监听端口并发出 `'listening'` 事件, 后面的 `'listening'` 事件还没有注册导致无法监听到. 但其实 `'listening'` 事件是在 `nextTick()` 中被发出的, 这让我们可以先监听端口, 后绑定事件也不会有什么问题.



### `process.nextTick()` 和 `setImmediate()`

对于用户而言, 我们有两个类似的函数, 但它们的名字令人困惑:

* `process.nextTick()` 在同一个阶段中立即发出(callback 在阶段最后被执行)
* `setImmediate()` 在当前这轮事件循环的后续迭代中或下一轮事件循环中立即执行 callback

实际上它们的名字应该交换一下. `process.nextTick()` 比 `setImmediate()` 更加"立即"执行, 但是这是历史遗留问题, 不太可能改变.

*我们建议开发者们在任何情况下都使用 `setImmediate()`, 因为它的执行顺序更容易预测, 也能更好地与其他环境兼容, 比如浏览器.*



### 什么时候使用 `process.nextTick()`?

主要有两种情况:

1. 允许用户处理错误, 清除不需要的资源, 或者在事件循环继续(进入到下一阶段)之前再次尝试请求
2. 有时候需要允许用户可以先执行操作再监听事件(在调用栈完全展开之后但是在事件循环继续之前执行)

考虑下面代码.

```javascript
const server = net.createServer();
server.on('connection', (conn) => { });

server.listen(8080);
server.on('listening', () => { });
```

假设 `listen()` 是在事件循环的开头被调用, 但是事件处理的实现中 listening callback 被放在一个 `setImmediate()` 调用而不是在 `process.nextTick()` 中被调用. 而 `connection` 事件的 callback 一定是在 poll 阶段被执行, 这意味着有概率出现先执行 `connection` 的 callback 再执行 `listening` 的 callback.

另一个例子是执行一个函数的构造函数, 假如继承了 `EventEmitter` 并且在构造函数中触发一个事件.

```javascript
const EventEmitter = require('events');
const util = require('util');

function MyEmitter() {
  EventEmitter.call(this);
  this.emit('event');
}
util.inherits(MyEmitter, EventEmitter);

const myEmitter = new MyEmitter();
myEmitter.on('event', () => {
  console.log('an event occurred!');
});
```

这里监听的事件 callback 是不会被执行的, 因为这里是一个先触发再监听的过程, 而 Events 模块的实现中并没有使用 `process.nextTick()` 来调用 callback, 也没有实现允许先触发事件再订阅事件, 所以为了得到预期结果, 我们需要自己使用 `process.nextTick()`

```javascript
const EventEmitter = require('events');
const util = require('util');

function MyEmitter() {
  EventEmitter.call(this);

  // use nextTick to emit the event once a handler is assigned
  process.nextTick(() => {
    this.emit('event');
  });
}
util.inherits(MyEmitter, EventEmitter);

const myEmitter = new MyEmitter();
myEmitter.on('event', () => {
  console.log('an event occurred!');
});
```



#### 参考资料

* https://nodejs.org/en/docs/guides/blocking-vs-non-blocking/
* https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick/
* https://zhuanlan.zhihu.com/p/34924059
* https://www.zhihu.com/question/24780826
* https://zhuanlan.zhihu.com/p/25973650
* https://www.zhihu.com/question/67751355/answer/258061544
* https://www.zhihu.com/question/25532384/answer/81152571
* https://www.zhihu.com/question/23028843/answer/153383080
* https://zhuanlan.zhihu.com/p/26023420
* https://www.zhihu.com/question/55557148
* https://zhuanlan.zhihu.com/p/38395184
* https://jsblog.insiderattack.net/timers-immediates-and-process-nexttick-nodejs-event-loop-part-2-2c53fd511bb3
* https://jsblog.insiderattack.net/promises-next-ticks-and-immediates-nodejs-event-loop-part-3-9226cbe7a6aa
* https://jsblog.insiderattack.net/handling-io-nodejs-event-loop-part-4-418062f917d1
* https://jsblog.insiderattack.net/event-loop-best-practices-nodejs-event-loop-part-5-e29b2b50bfe2
* https://zhuanlan.zhihu.com/p/44439782
* https://cnodejs.org/topic/5a9108d78d6e16e56bb80882