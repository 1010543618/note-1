* cookie 的 key 和 value 都应该进行 URL 编码
* cookie 域和同源策略不一样, 不要搞混了, cookie 的域并没有那么严格. cookie 只需要确保域名就好, 而不要求端口号和协议
* 比如 aaa.com 通过 `Set-Cookie` 设置了一个 domain 为 aaa.com 的 cookie, path 为 /, 则 aaa.com:3000 的页面的 js 也能拿到这个 cookie, 并且这个 cookie 也会被发送到 aaa.com:3000 的服务器
* 比如 aaa.com 通过 `Set-Cookie` 设置了一个 domain 为 aaa.com 的 cookie, path 为 /, 则 bbb.aaa.com 的页面的 js 也能拿到这个 cookie, 并且这个 cookie 也会被发送到 bbb.aaa.com 的服务器, 即子域可以拿到上级域的 cookie
* 比如 aaa.com 通过 `Set-Cookie` 设置了一个 domain 为 bbb.aaa.com 的 cookie, path 为 /, 则 bbb.aaa.com 的页面的 js 能够拿到这个 cookie, 并且这个 cookie 也会被发送到 bbb.aaa.com, 但是 aaa.com 的页面的 js 不能拿到这个 cookie, 这个 cookie 也不会被发送到 aaa.com 的服务器, 即上级域可以设置 cookie 为子域, 子域可以拿到上级域设置的 cookie, 但是上级域不能拿到子域的 cookie
* 比如 bbb.aaa.com 通过 `Set-Cookie` 设置了一个 domain 为 aaa.com 的 cookie, path 为 /, 则 aaa.com 的页面的 js 能够拿到这个 cookie, 并且这个 cookie 会被发送到 aaa.com, 同样, bbb.aaa.com 的页面的 js 也能拿到这个 cookie, 并且这个 cookie 也会被发送到 bbb.aaa.com 的服务器, 即子域也可以设置 cookie 为上级域
* 比如 aaa.com 设置了一个 path 为 / 的 cookie, 则 aaa.com 下所有 path 的页面(如 /test, /demo, /test/demo)的 js 都能拿到这个 cookie, 这个 cookie 也会被发送到所有路由
* 比如 aaa.com 设置了一个 path 为 /test 的cookie, 则只有 /test 下所有页面的 js 能拿到这个 cookie, 这个 cookie 只会被发送到 /test 下的子路由, 而 / 的页面的 js 则不能拿到这个 cookie, 这个 cookie 也不会被发送到 /
* 比如 aaa.com 设置了一个 domain 为 bbb.com 的 cookie, 其实是没什么卵用的, bbb.com 的页面的 js 是不能拿到这个 cookie 的, 这个 cookie 也不会被发送到 bbb.com 的服务器, 即只能为本域或者子域设置 cookie, 而给其他域设置 cookie 是无效的
* 虽然说 cookie 本质就是个字符串, 但是 `document.cookie` 并不能拿到完整的 header 中的 cookie 字符串, 只能拿到 key-value 形式的, 并且所有的域和 path 中的 cookie, 只要是能拿到的, 都在这个字符串中, 所以会有这样的情况, 比如有两个 cookie, key 都是 name, 分别在两个 path 下, /test0 和 /test1, 则 `document.cookie` 的值是 `"name=aaa; name=bbb"`
* 设置 `document.cookie` 并不会覆盖掉整个 cookie 字符串, 而是相对于新增一个 cookie, 除非已有同名同 domain 同 path 的 cookie, 才会覆盖那一个 cookie. 即如果原本 `document.cookie` 的值为 `aaa=aaa; bbb=bbb`, 执行 `document.cookie = 'ccc=ccc'` 并不会让它的值变为 `ccc=ccc`, 而是变成 `aaa=aaa; bbb=bbb; ccc=ccc;`
* 虽说通过 `document.cookie` 获取到的只是一个 key-value 的字符串, 没有其他信息(这也意外在浏览器环境下不可能根据其他信息查找到指定 cookie), 但是设置 `document.cookie` 还是可以包含其他信息的, eg. `name=value; expires=Sat, 14 Jul 2018 14:06:50 GMT; path=/test; domain=www.test.com; secure`
* 还有个小细节是 `document.cookie` 总是会把距离当前页面 path 最近的 cookie 放在字符串最前面, Chrome 是这样, 不知道其它浏览器是不是也这样. 即如果当前页面是 /test, 存在着同名 cookie `aaa=aaa` 和 `aaa=bbb` 分别在 / 和 /test 下, 则 `document.cookie` 中会是 `aaa=bbb; aaa=aaa`, 值为 `bbb` 的 cookie 会被放在字符串前面