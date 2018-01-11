首先 meta 元素主要有以下几类:

* 带有 `name` 属性的, 这种是**文档级 metadata(document-level metadata)**, 会被应用到整个页面
* 带有 `http-equiv` 属性的, 它的内容通常由服务端给出
* 带有 `charset` 属性的, 告诉浏览器以哪种编码解释页面内容
* 带有 `itemprop` 属性的, 用户定义(特定?)的 metadata, 这个内容对用户代理(UA)是透明的, 因为 metadata 是用户特定的

这四个属性是**互斥**的, 其中 charset 和 http-equiv 类型的 meta 需要放在 `head` 标签中, meta 标签支持所有的通用属性([global attributes](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes)).

### name 属性

`name` 通常和 `content` 属性一起用:

* `name` 通常指定了 meta 元素的类型, 即它包含了哪种类型的信息
* `content` 指定了 meta 元素的内容

name 类型的 `<meta>` 就是一个 key-value 结构, name 是 key, content 是 value, 并且 `name` 不和 `http-equiv`, `itemprop`, `charset` 同时使用, 注意 name 是一个通用属性, 只不过在 meta 中还有特殊意义.

meta 中的 name 可以有以下值:

* `application-name` 定义了整个页面的应用名, 浏览器可能通过这个字段标识 web 应用, 简单的页面也可以没有这个属性
* `author` 页面的 author
* `description` 关于页面内容的简单描述, 一些浏览器会用它作为页面书签中的默认描述
* `generator` 表明页面是由什么工具生成的, 好像没什么卵用
* `keywords` 包含了页面相关的关键词, 对应的 `content` 属性中用逗号分隔关键词
* `referrer` 基本类似 HTTP 的 referrer 头, 控制着从当前页面发出的请求是否应该带 referrer 头, **动态插入的该属性 meta 标签会使得 referrer 的行为不可预料**. 支持的值具体参考 [MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta)
* `robots` 作用同 [robots.txt](https://zh.wikipedia.org/wiki/Robots.txt),  控制搜索引擎的行为, 但是搜索引擎爬虫还是会爬这个页面, 如果要避免消耗带宽, 还是要用 robots.txt(这东西比起页面来说还是小很多), 对应的 `content` 属性中用逗号分隔. 不知道它和 robots.txt 的优先级是什么样(待测试), 支持的值具体参考 [MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta)
* `viewport`, 给移动端用的, 具体作用看浏览器适配相关的内容, 对应的 `content` 属性支持的值参考 [MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta)
* `creator`, 定义页面所属的组织机构, 好像没什么卵用
* `publisher`, 定义页面的发布者, 听起来和 author 差不多
* `googlebot`, 同 `robots`, 只是针对 Google 爬虫的
* `slurp`, 同 `robots`, 只是针对 Yahoo 爬虫的



### http-equiv 属性

该属性(的 content)可以包含一个 HTTP 头的名称, 作用也同对应的 HTTP 头, 不知道它和 HTTP 头的优先级是什么样(待测试), 和 `content` 配合使用, 支持以下值:

* `content-security-policy`, CSP 相关的配置, 具体内容去了解 [CSP](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)
* `refresh`, 用来刷新页面, 对应 `content` 的值可以是一个数字, 表明几秒后刷新页面, 也可以是 `3;url=https://www.google.com` 这样的, 表面 3s 后跳转到对应 URL

重要的好像就这两个, 其他的基本都过时了, 关于该属性更多内容可以参考 [MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta)

**注意:**

该类型的 meta 必须放在 `head` 中



### charset 属性

charset 的值必需符合 [标准的 IANA MIME 命名](https://www.iana.org/assignments/character-sets/character-sets.xhtml)

**注意:** 

它声明的编码必须和保存页面时用的编码一致, 比如 index.html 保存时是 UTF-8, 则 charset 的值也应该是 UTF-8, 否则可能出现乱码以及导致安全问题.

charset 的 `meta` 标签必须放在 `head` 中, 以及必须出现在 HTML 页面的前 1024 字节, 因为一些浏览器只会根据这些字节的内容来决定页面采用何种编码.

建议每个页面显式指定 charset 的 `meta` 标签, 否则可能导致一些安全问题.

HTTP 的 `Content-Type` 的优先级比 charset meta 标签高.



### content 属性

配合 name 和 http-equiv 使用



### itemprop 属性

该属性目前是实验性, 暂时没找到相关资料



### 总结

几种类型的 meta 中, 主要就 charset 比较重要, name 的 meta 在 SEO 的时候比较有用, http-equiv 在配置 CSP 的时候比较有用



### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta
* https://developer.mozilla.org/en-US/docs/Learn/HTML/Introduction_to_HTML/The_head_metadata_in_HTML

