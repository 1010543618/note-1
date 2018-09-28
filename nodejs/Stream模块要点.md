* `Stream` 是一个抽象接口, 通常来说很少要直接使用 `Stream` 模块, 大部分时候都是使用其他实现了该接口的对象, 所以作为使用者大部分时候只需要了解 `Stream` 接口的 API 即可. 直接使用 `Stream` 模块通常是需要构造自己的流

* 一个 `Stream` 对象可以是可读的, 或可写的, 或既可读又可写. 所有的 `stream` 也都是 `EventEmitter` 的实例, 换句话说 `Stream` 继承自 `Events`

* 有四种基本的流类型, 对应四个 Class:

  * `Writable` 可写入数据的流
  * `Readable` 可从中读取数据的流
  * `Duplex` 既可读又可写的流
  * `Transform` 可以在写入和读取数据时对数据进行修改和转换的流, 也是可读可写的

* 默认情况下, Node 中的流都只对字符串和 `Buffer` 进行操作, 但也可以实现操作其他 JS 数据类型的流(除了 `null`). 即默认情况下, 流都是字节流或字符流, 但也可以创建自己的对象流. 如果是自己实现的对象流, 则被认为是工作在"对象模式"("object mode", 一共就两种模式, 对象模式和非对象模式). 当一个流的实例被创建的时候, 可以通过给构造函数的选项中使用 `objectMode` 来指定流的工作模式. 但是将一个已存在的流的工作模式改变的行为是 UB 的, 不安全.

* `Writeable` 和 `Readable` 流(实例)都有一个自己的内部缓冲区(一块 `Buffer`), 可以通过 `writable.writableBuffer` 或 `readable.readableBuffer` 获取到(是有这么个属性的, 不过不知道为什么 API 文档上没有关于这个属性的详细说明). 这个缓冲区的大小可以在创建 `stream` 的时候通过构造函数选项中的 `highWaterMark` 来设置, 默认是 16KB, 对于文件流, 默认是 64KB. 如果文件较大, 适当调高这个值有利于提升读写效率

* 对于 `Readable`, 通过 `readable.push(chunk)` 向内部缓冲区中写入数据, 如果 `readable` 的使用者没有调用 `readable.read()` 来消费数据, 则数据将一直位于内部缓冲区中, 直到消费掉为止. 一旦内部缓冲区满了(达到 `highWaterMark` 设置的值), 则 `readable` 停止从数据源获取数据. 其实 `Readable` 流的工作流程就是, `Readable` 实例作为一个抽象数据结构, 提供了一系列方法, 用于从它身上读取数据, 它是文件, socket 等各种可读实体的抽象. 文件/socket 等作为数据源, `readable` 通过内部方法 `readable._read()` 从数据源获取数据, 然后通过 `readable.push(chunk)` 将这些数据填入到自己的内部缓冲区, 而另一边, 作为 `readable` 的使用者, 通过 `readable.read()` 消费内部缓冲区中的数据. 如果内部缓冲区满了, 则 `readable` 停止调用 `readable._read()` 从数据源获取数据. 所以这里有三个方法, `readable.read()` 是作为流的使用者用的, 而 `readable._read()` 和 `readable.push(chunk)` 则是作为流的实现者在内部调用的. 这也说明如果流实现有问题的话也是可能丢失数据的, 比如内部缓冲区中的数据没有被消费, 不管缓冲区是否满了, 流却还不停地从数据源读数据并 `push()` 到缓冲区, 多出的数据从数据源读取了却没有被放在缓冲区, 等到消费的时候就发现少了部分数据

* `readable._read()` 和 `readable.push()` 的关系是, `_read()` 会周期性地自动被 Node 调用, 周期是多少不知道, 不过可以确定一个 microtask 阶段只调用一次. 而 `push()` 是流的实现者决定何时调用, 通常是在 `_read()` 中调用. 如果 `push()` 返回了 `false` 或  `push(null)` 被调用, 则停止自动调用 `_read()`, `push(null)` 说明数据源的所有内容已经读完, `null` 是一个 `EOF` 的信号. 并且如果 `_read()` 被调用一次之后, 没有调用 `push()`, 则也不会继续自动调用 `_read()`, 即 `_read()` 和 `push()` 总是应当交替地被调用. 另一方面是, 只有在外部的消费者(流的使用者)开始消费时, `_read()` 才会开始被调用

* 对于 `Writable`, 则和 `Readable` 相反, 流的使用者通过 `writable.write(chunk)` 向内部缓冲区中写入数据, 如果内部缓冲区没满, 则调用 `writable.write(chunk)` 写入成功返回 `true`, 否则返回 `false` 并且不会往内部缓冲区中写入数据. 而在内部, 则由 Node 周期性地调用内部方法 `_write()` 从缓冲区读取数据并写入到实际的目标中

* `_write(chunk, encoding, callback)` 的签名是这样的, 这个 `callback` 是最关键的, 其实它和 Koa 里 `next()` 是一个性质的, 即告诉 Node 是否可以继续向目标写入数据, 传入 `null` 表示成功, 传入一个 `Error` 表示失败. `_write()` 和 `write()` 的关系并不是调用一次 `write()` 就会导致 `_write()` 被调用, `_write()` 始终是由 Node 来调用而不由用户调用直接或间接触发, 所以在一次 `_write()` 调用到它的 `next()` 被调用的时间之间(`next()` 可能被异步调用), 可能存在多次 `write()` 调用, 并且 `write()` 写入的数据都会存在缓冲区. 同样地, `_write()` 和 `next()` 的关系类似于 `_read()` 和 `push()`, 当自动调用了一次 `_write()` 之后, 如果 `next()` 没被调用, 则不会继续调用 `_write()`. 而另一方面, `write()` 返回 `false` 只是表示暂时不能向缓冲区中写入了, 但不代表目标源不能被写入, 所以如果想要知道目标源是否能够写入, 只能是监听 `'error'` 事件

* 在实现 `Readable` 流的时候, `_read(size)` 有个 `size` 参数, 是建议你一次可以从数据源获取多少字节数据的, 你也可以不用它, 其实它的值就是 `highWaterMark` 的值, 即通常建议你一次获取缓冲区大小的数据

* 在调用 `push()` 和 `write()` 方法的时候, 务必注意下对应 API 创建的流的缓冲区大小, 避免一次写入的数据就超出了整个缓冲区大小, 以及对它们的返回值检查是否是 `false` 总是好习惯

* 在实现流的时候, `push()` 和 `next()` 的调用可以考虑安排为异步调用, 虽然像 `on('data')` 这样的是事件, 但是如果速率高的话, 会导致事件循环一直阻塞在 poll 阶段(速率低的话则不会), 所以通过将 `push()` 或 `next()` 安排为异步调用, 可以主动让出事件循环, 避免流的读写阻塞事件循环

* `Duplex` 和 `Transform` 流内部都维护着两个缓冲区

* `Stream`, 特别是 `stream.pipe()`, 设计的主要目标是限制载入内存的数据在一个可接受的范围内, 而不至于撑爆内存, 并且平衡两端的处理速度. 补充一个相关链接 https://www.zhihu.com/question/26190832

* 新的异步迭代器很好用

  ```javascript
  const fs = require('fs');
  
  async function print(readable) {
    readable.setEncoding('utf8');
    let data = '';
    for await (const k of readable) {
      data += k;
    }
    console.log(data);
  }
  
  print(fs.createReadStream('file')).catch(console.log);
  ```

* TODO, 内容有点多, 有空再写