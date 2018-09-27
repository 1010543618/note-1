* 事件名一般小驼峰命名, 当然其他也是可以的
* 触发事件时, 将按照注册顺序同步调用该事件的所有 handler, handler 的任何返回值都会被丢弃
* handler 的 `this` 默认是 `EventEmitter` 的实例, 如果用 lambda 则是和 lambda 的 `this` 绑定规则一样
* 如果希望事件只触发一次, 请用 `once()` 注册
* `'error'` s事件比较特殊, 如果一个 `EventEmmiter` 实例没有注册 `'error'` 事件, 而当一个 `'error'` 事件被触发时, 则默认抛出一个异常, 如果不捕获的话, 则 Node 进程退出, 所以建议都注册一个 `'error'`
* 默认地, 每个事件最多可以注册 10 个 handler, 这个值可以通过 `EventEmitter.defaultMaxListeners` 获取到, 注意这是一个静态属性, 修改它可以改变这个默认值, 但是会影响所有实例, 如果只是想修改单个实例的限制值, 使用 `emitter.getMaxListeners()` 和 `emitter.setMaxListeners(n)` 来获取和设置, 它会覆盖掉 `EventEmitter.defaultMaxListeners`
* `addListener()` 的事件名也可以是一个 `Symbol`
* `emitter.eventNames()` 可以获取所有的事件名, 包括 `Symbol` 类型的
* `emitter.listenerCount(eventName)` 虽然大部分时候用不到, 不过有时也还是有点用的
* `emitter.listeners(eventName)` 获取一个事件的所有 handler 的数组, 也是不常用但必要时又有点用的东西, 还有个类似的 `emitter.rawListeners(eventName)`, 具体看 API 文档, 注意它们返回的都是一个副本