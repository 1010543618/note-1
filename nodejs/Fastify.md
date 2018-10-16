最近看了下 Fastify, 感觉比 Koa 好用一点, API 稍稍复杂一些, 不过也还行. 简单列下个人觉得比较重要的地方.

* 基本套路和其他框架差不多

  ```javascript
  const Fastify = require('fastify');
  const app = Fastify();
  
  app.get('/', (req, res) => {
  	res.send({
  		hello: 'world'
  	});
  });
  
  app.listen(3000, (err, addr) => {
  	if (err) {
  		console.error(err.message);
  		process.exit(1);
  	}
  	console.log(`server listening on ${addr}`);
  });
  ```

  不过有一点好是支持 Promise, 所以可以这样.

  ```javascript
  const Fastify = require('fastify');
  const app = Fastify();
  
  app.get('/', async (req, res) => ({ hello: 'world' }));
  
  (async () => {
  	try {
  		const addr = await app.listen(3000);
  		console.log(`server listening on ${addr}`);
  	} catch (err) {
  		console.error(err.message);
  		process.exit(1);
  	}
  })();
  ```

* 默认只监听 `127.0.0.1`, `.listen([port[, host[, backlog]]][, callback])`, 和 Node 原生的[这个](https://nodejs.org/dist/latest-v10.x/docs/api/net.html#net_server_listen_port_host_backlog_callback)一样, 只不过在 `callback` 没给的情况下会返回 Promise, 虽然这是个同步方法, 但是地址端口的绑定却是异步的, 因为 `.listen()` 内部会调用 `.ready()`, 最终的绑定是在 `.ready()` 的 `callback` 中完成的, 主要也是为了确保服务器启动之前所有插件加载完, 另外这个 `.listen()` 不像 Koa 那样返回一个原生的 HTTP server 实例(有 `callback` 无返回值, 没有则返回值为字符串 `http://127.0.0.1:3000` 这样的 Promise)

* 官方推荐了下 [make-promise-safe](https://github.com/mcollina/make-promises-safe) 这个库, 不过通常来说自己也会处理吧, 几行的事

* 当调用 `app.listen()` `app.ready()` `app.inject()` 的时候, 插件就会开始加载(插件本质就是个函数, 即此时插件的函数被调用)

* 官方建议的代码组织顺序是这样

  ```javascript
  └── plugins (from the Fastify ecosystem) 第三方库
  └── your plugins (your custom plugins) 你自己的插件
  └── decorators 装饰器
  └── hooks and middlewares
  └── your services
  ```

  即按照这个顺序注册插件, 因为 service 也是插件, 所以整个的应用层级是这个样子的

  ```javascript
  └── plugins (from the Fastify ecosystem)
  └── your plugins (your custom plugins)
  └── decorators
  └── hooks and middlewares
  └── your services
      │
      └──  service A
      │     └── plugins (from the Fastify ecosystem)
      │     └── your plugins (your custom plugins)
      │     └── decorators
      │     └── hooks and middlewares
      │     └── your services
      │
      └──  service B
            └── plugins (from the Fastify ecosystem)
            └── your plugins (your custom plugins)
            └── decorators
            └── hooks and middlewares
            └── your services
  ```

  类比到 Koa 其实就是最上面的是所有路由都加的中间件, service 那里是每个路由自己的中间件

* 给 response 设置 schema 的话有利于 JSON 序列化的性能, 大约 2 - 3 倍

* 路由以及各种 hook 的 handler 内的 `this` 都是当前作用域内的 Fastify 实例, 所以不是所有情况都要用 lambda 的, 另外装饰器如果定义的是函数, 那 `this` 也是当前作用域的 Fastify 实例

* 如果插件是 `async` 函数, 则不需要 `next` 参数, 而如果是普通函数, 则一定要记得调用 `next()`, 这点官方文档没有明确说明, 但是因为内部用了 `avvio`, 所以这点在 `avvio` 的[文档](https://github.com/mcollina/avvio#appusefunc-opts)中有体现

* 生命周期中的各种 hanlder 都支持 `async` 函数, 准确说, 是支持返回 Promise 的函数

* 静态路由总是在参数路由和通配符路由之前进行匹配, 意味着优先级更高

* 用于创建 Fastify 实例的工厂函数支持选项, `const app = require('fastify')(options)`, 选项的属性个人感觉比较有用的有

  * `http2` boolean, 默认 false
  * `https` 对象, 默认 null, 和[这个](https://nodejs.org/dist/latest-v8.x/docs/api/https.html#https_https_createserver_options_requestlistener)的 `options` 一致
  * `maxParamLength` 最大的路径参数(字符)长度, 默认 100 个字符, 即 `/test/:name` 中 name 最多 100 个字符
  * `bodyLimit` body 的最大大小, 单位 bytes, 默认 1MB, 这个大概对处理文件上传时需要注意, 路由定义时的 options 中的 `bodyLimit` 可以覆盖这个值
  * `logger`
  * `serverFactory` 自定义 http server
  * `requestIdHeader` 需要自定义每个请求 id 的标识时有用
  * `trustProxy` 在处理涉及代理时有用
  * `pluginTimeout` 设置单个插件加载的最长时间, 单位 ms, 通常还是用不到的

* Fastify 实例的注册类的方法都是支持链式调用的, 比如注册事件注册插件注册中间件等. 比较有用但是不常用的 API 有

  * `server` 暴露的 HTTP server 实例, 对处理 WebSocket 等有帮助
  * `after(fn)` 单个插件及其子插件注册完成的事件, 在 `ready()` 之前触发, 如果有错误, `fn` 会收到一个 `err` 参数
  * `ready([fn])` 所有插件注册完成的事件, 如果不给 `fn` 则返回 Promise, 如果有错误, `fn` 会收到一个 `err` 参数
  * `route()` 添加路由
  * `close()` 关闭服务器, 触发 `onClose`
  * `basepath`
  * `log` 日志实例
  * `addSchema()` 添加共用的 schame
  * `setNotFoundHandler(fn)` 添加 404 的处理, 也可以用来给某一级下面的路由添加 404 而不是在全局添加 404
  * `setErrorHandler(fn)` 添加全局的错误处理, 也可以放在某一级插件中, 支持 `async` 函数

* TODO

