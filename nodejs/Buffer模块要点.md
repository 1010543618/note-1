* `Buffer` 实现了 `Uint8Array` 一样的 API(但是还是有些细微区别), 但不是基于 `Uint8Array` 实现的, 注意区别. 单位是字节. 可以理解为 `Buffer` 和 `TypedArray` 是一个层面的东西

* `Buffer` 分配的内存不在 V8 的堆内存上(`Uint8Array` 的内存分配在 V8 堆内存上?), 所以不受 1.4G(64bit) 或 732MB(32bit) 的限制

* `Buffer` 默认是在 `global` 的, 不需要手动引入

* 出于安全性考虑, 不建议使用 `Buffer` 构造函数来创建 `buffer`, 尽管在 8.0 以后通过构造函数创建的 `buffer` 也已经是默认填充 0 了

* 安全性是指如果是分配的未初始化(填充)的内存的话, 内存中可能包含旧的敏感数据, 可能导致安全问题, 但是未初始化的方式分配内存效率比较高, 必要的时候可以用下

* 建议使用 `Buffer.from()` `Buffer.alloc()` `Buffer.allocUnsafe()` 这几个静态方法创建实例

* `Buffer.from(array)` 数组元素必须是 integer, 并且必须是 1 字节的无符号 integer, 即 0 - 255, 超出范围的高位被截断, 或者说是被 256 取模, 返回这些数字对应的字节的副本

* `Buffer.from(arrayBuffer[, byteOffset[, length]])` 返回的 `buffer` 和给定的 `ArrayBuffer` 实例共享同一块内存, 注意是当参数类型是 `ArrayBuffer` 或 `SharedArrayBuffer` 的时候才是共享内存, 但是参数也可以是 `TypedArray`, 此时是内存的一个副本, 即

  ```javascript
  const arr = new Uint16Array(2);
  
  // 不共享内存
  const buf1 = Buffer.from(arr);
  // 共享内存
  const buf2 = Buffer.from(arr.buffer)
  ```

* `Buffer.from(buffer)` 返回给定 `buffer` 的一个副本, 不共享内存

* `Buffer.from(string[, encoding])` 返回的 `buffer` 是字符串指定编码的二进制表示

* `Buffer.alloc(size[, fill[, encoding]])` 创建一个指定大小(字节数)的 `buffer`, `fill` 可以是数字, 字符串, `Buffer`, 默认 0 填充, `encoding` 配合字符串的 `fill` 使用, 指定 `fill` 的编码, 默认 `utf8`

* `Buffer.allocUnsafe(size)` 返回一个指定大小但是未被填充的 `buffer`

* 当使用 `Buffer.allocUnsafe()` 创建实例的时候, 如果 `size` 小于等于 `Buffer.poolSize`/2 的话, 则从共享内存池中分配, `Buffer.poolSize` 默认是 8KB, 8192bytes. 也就是小于等于 4K 的 `Buffer` 都会从共享内存池中分配. 所谓共享内存池, 其实就是一块预先分配好的 8K 内存, 也叫 slab, 如果一个 slab 就创建新的 slab 继续作为小 `Buffer` 的共享内存池. 所以有几点需要注意:

  * 在达到某个阈值时创建的 `Buffer` 实例, 即便很小, 也会导致分配 8K 的内存, 比如第一个创建的小 `Buffer`, 并且这个操作比直接在共享内存池上分配开销来得大, 毕竟要新申请一块 8K 内存
  * 这也说明一个 slab 可能会给多个 `Buffer` 实例使用, 意味着必须等这些实例都被回收后, 这个 slab 才能被回收
  * 因为 `Buffer` 不是分配在 V8 堆内存上, 所以 JS 层面的 `Buffer` 实例可以看作是一个指针, V8 回收这个指针变量, 但不负责回收 `buffer` 实际指向的内存

  如果创建的 `buffer` 大于 4K, 则不从共享内存池分配, 从哪里分配也不知道, 以前是分配一个 `SlowBuffer` 现在不知道还是不是, 不过反正得新申请内存就是了

* 共享内存池主要是为了减少碎片提高分配内存的效率

* `Buffer.alloc()` 和 `Buffer.allocUnsafe()` 的区别不仅仅是初始化时是否进行填充, 还有 `Buffer.alloc()` 永远不会使用共享内存池

* `Buffer.alloc()` 和 `Buffer.allocUnsafeSlow()` 的区别好像就仅仅是是否填充? 这点有待确认

* 单个 `buffer` 的大小有最大限制, 前面这些创建 `Buffer` 的方法都不能超过这个限制, 这个值是 `buffer.constants.MAX_LENGTH` 或者是 `buffer.kMaxLength`, 它们是一样的. 32bit 系统上大约 1GB, 64bit 大约 2GB

* `buffer.toString([encoding])` 和 `buffer.from(string[, encoding])` 都支持指定编码, 前者是指 `buffer` 中的二进制数据应该被解释成哪种编码的字符串, 后者是指字符串应当以何种编码存储为二进制, 目前支持以下编码

  * `ascii`
  * `utf8`
  * `utf16le` 即 UTF-16
  * `ucs2` 同 `utf16le`
  * `base64`
  * `latin1`
  * `binary` 同 `latin1`
  * `hex`

* `Buffer` 的实例也是 `Uint8Array` 的实例, 前面说了 `Buffer` 实现了 `Uint8Array` 一样的 API, 但是存在一些细微的不兼容的区别. 比如使用 `ArrayBuffer#slice()` 的时候是创建该切片内存的复制, 而 `buffer.slice()` 则是创建一个 `buffer` 和切片共享同一块内存, 所以 `buffer.slice()` 的效率更高, 但是是共享内存的. 还有一些区别是 `buffer.from()` 和 `typedArray.from()` 的函数签名是不一样的

* 通过 `Buffer` 创建 `TypedArray` 遵循两个原则:

  * `TypedArray` 的实例是 `Buffer` 实例的内存的复制, 而不是共享同一块内存
  * `Buffer` 实例的内存被解释成不同元素的数组, 而不是作为某一类型的字节数组, 即 `new Uint32Array(Buffer.from([1, 2, 3, 4]))` 创建的是一个 `[1, 2, 3, 4]` 而不是具有单个元素的数组 `[0x1020304]`

* 而从 `TypedArray` 创建 `Buffer` 也是复制内存而不是共享内存, 如果希望共享内存, 应该通过 `TypedArray` 的 `ArrayBuffer` 来创建, 即前面提到的, `const buf1 = Buffer.from(arr.buffer)`, 这样得到的 `buffer` 则是和 `TypedArray` 实例共享同一块内存的

* `Buffer` 实例及其一些方法都实现了迭代器接口

* 如果想要得到多个 `buffer` 合并在一起之后的字符串, 用 `+` 是最快的, 不过记得确认下字符串编码, 免得出现潜在的问题

* 没事多翻翻 API 文档, 在自己动手撸方法之前先看看有没有现成的 API, 里面蛮多有点用但是又不常用的方法