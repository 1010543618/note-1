重刷《HTTP 权威指南》发现一个小小的问题. 众所周知(勃式开头), URL 的语法是这样的:

```
<scheme>://<user>:<password>@<host>:<port>/<path>;<params>?<query>#<frag>
```

其中我们注意到有个 params, 形式是 Key-Value 的, 作用是传递参数的, eg.

```
http://xxx.com/aaa;name=bbb&age=13/ccc;sthother=abc?query=123
```

每段 path 部分都可以由一个或多个 params 作为参数. 看上去很有用. 也不禁让人想, 既然这东西是用来传递参数的, 那它和 query string 有什么区别? 为什么现在大家好像都是只用 query string 没见过有人用 params?

为了搞清楚这个问题, 特地查了下 URL 的 [RFC1738](https://tools.ietf.org/html/rfc1738#section-5). 发现其实应该是没有 params 这么个概念的, 当然说有也行, 反正说到底 URL 只是一个普通的字符串, 而字符串每个部分的格式和意义也不过是人为赋予的.

我们还是来看 URL 的 BNF, 其实这个挺长的, 也就不全放出来了. 大致说明下, 各种协议的 URL 并没有一个通用的格式, 因为 RFC 里预定义了几个协议的 URL 格式, 而它们偏偏都不太一样. 具体到细节就是, 可能有些协议有我们提到的 params 部分, 而有些协议没有(比如 gopher). 换句话说, 在 gopher 中 `;param=xxx` 这样的内容是不合法的.

而在我们最关心的 HTTP 中呢? 这里贴部分 HTTP 的 BNF:

```
httpurl        = "http://" hostport [ "/" hpath [ "?" search ]]
hpath          = hsegment *[ "/" hsegment ]
hsegment       = *[ uchar | ";" | ":" | "@" | "&" | "=" ]
search         = *[ uchar | ";" | ":" | "@" | "&" | "=" ]
```

其中 uchar 大体上是字母数字下划线等等(当然还有其他一些). 可以看到, HTTP 的 URL 中, 分号和等号都是合法的, 不过也并没有规定一个有意义的实体部分 params. 所以说, 下面这样的其实也是合法的.

```
http://xxx.com/a;b:=c;&=d/path
```

`a;b:=c;&=d` 和一个普通的 `abcdef` 并没有什么区别, `;&=` 这些符号和普通的字母也没什么区别, 最终它们的整体都只是一个 hsegment 的标识符罢了. RFC 中也并未规定 params 这一实体, 它的 Key-Value 格式和作为参数的意义也不过是人为规定. 所以我们当然可以把某种特定形式如 `;a=b&c=d` 的 hsegment 的一部分解释为 params, 让它具有参数的意义, 但我们也可以不这么做.

而对于 query string 或者说 search, 也是一样的. 它也并不一定是要求 Key-Value 形式, 只不过人们为了方便约定俗成了, 决定就由你来当 GET 请求的参数了. 所以事实上, 下面 这些也是合法的.

```

```

符合 URL 的规范, 但违反了人们的约定, 最终也就失去了意义.

总之, 对于这两个东西, 它们都只不过是符号的序列, 而人们为满足特殊形式的序列赋予了特殊的意义.



#### 参考资料

* https://stackoverflow.com/questions/39266970/what-is-the-difference-between-url-parameters-and-query-strings
* https://tools.ietf.org/html/rfc1738