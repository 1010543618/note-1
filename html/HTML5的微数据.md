在用搜索引擎搜索资料的时候可能我们都见过这样的

![img1](./images/img1.png)

或者这样的

![img2](./images/img2.png)



那怎么让你的页面在搜索引擎中呈现这样的结果? 这就是通过**微数据**实现的. 那什么是微数据?



#### 结构化数据(Structured-data)

要了解微数据, 先要了解结构化数据. 微数据是一种数据交换的格式, 也是结构化数据的一种实现. 我们常用的 XML 或者 JSON 都可以算作一种结构化数据, 同理, 微数据也是一种结构化数据. 所以微数据和 JSON 处于同一类的东西, 都是结构化数据的一种实现. 就像 UTF-8 和 UTF-16 都是 Unicode 的一种实现一样.

Google 等搜索引擎会提取页面上的结构化数据, 并作为搜索结果展示, 就像上面那样. Google 主要支持三种结构化数据, [JSON-LD](http://json-ld.org/), [微数据(Microdata)](https://www.w3.org/TR/microdata/), [RDFa](https://rdfa.info/). Google 比较推荐用 JSON-LD, 不过我们这里主要讨论的是微数据, 就不去管其他的了.



#### 微数据(Microdata)

我们已经知道微数据是什么, 那微数据具体的格式是什么样的? 简单来讲, 微数据和 JSON 的形式其实是一样的, 都是 key-value 结构的, 只不过微数据复用了 DOM, 给 DOM 上已有的数据附加了额外的语义. 什么意思呢?

首先, 微数据主要通过 `itemtype`, `itemscope`, `itemprop` 这几个 HTML 属性来实现. 当然, 还有两个不常用的是 `itemid`, `itemref`. 这些属性都是通用属性, 可以放到任意 HTML 标签.

那么看一个具体的例子:

```html
<div id="person">
  <p id="name">Someone</p>
  <p id="children">
    <p id="childrenname">Anotherone</p>
  </p>
  <img src="https://xxx.com/img.jpg">
  <a href="https://xxx.com">Colleague</a>
</div>
```

这只是一个普通的 HTML 片段, 现在我们给它加一点其他的语义

```html
<div id="person" itemscope itemtype="http://schema.org/Person">
  <p id="name" itemprop="name">Someone</p>
  <p id="children" itemprop="children" itemscope itemtype="http://schema.org/Person">
    <p id="childrenname" itemprop="name">Anotherone</p>
  </p>
  <img src="https://xxx.com/img.jpg" itemprop="image">
  <a href="https://xxx.com" itemprop="colleague">Colleague</a>
</div>
```

与之类似(不等价, 等价的 JSON 要用 JSON-LD)的 JSON 是:

```json
{
  "name": "Someone",
  "children": {
    "name": "Anotherone"
  },
  "image": "https://xxx.com/img.jpg",
  "colleague": "https://xxx.com"
}
```

显然, `itemtype` 引入了一个 URL 定义了一个 schema, 我们把它叫做**词汇表**, 其实也就是个命名空间, 类似 XML 的 dtd. `itemscope` 限制了这个 schema 的作用范围是 `div#person`, `itemprop` 则根据 schema 定义了一个属性名(key), DOM 的内容作为值(value). 同时, 它也可以有嵌套的关系, 就像上面的 children 那样.

值得注意的是, 微数据格式不都是将 DOM 的文本内容作为 value 的, 像上面的 `<img>` 就是用 `src` 属性的内容作为 value, 那到底哪些是用文本内容哪些是用 HTML 属性? 可以参考下表

| Elements   | Value         |
| ---------- | ------------- |
| `<meta>`   | `content` 属性  |
| `<audio>`  | `src` 属性      |
| `<embed>`  |               |
| `<iframe>` |               |
| `<img>`    |               |
| `<source>` |               |
| `<video>`  |               |
| `<a>`      | `href` 属性     |
| `<area>`   |               |
| `<link>`   |               |
| `<object>` | `data` 属性     |
| `<time>`   | `datetime` 属性 |
| 其他         | 文本内容          |



#### 参考资料

* http://diveintohtml5.info/extensibility.html
* https://developer.mozilla.org/en-US/docs/Web/HTML/Microdata
* https://developers.google.com/search/docs/guides/intro-structured-data
* [HTML5扩展之微数据与丰富网页摘要](http://www.zhangxinxu.com/wordpress/2011/12/html5%E6%89%A9%E5%B1%95-%E5%BE%AE%E6%95%B0%E6%8D%AE-%E4%B8%B0%E5%AF%8C%E7%BD%91%E9%A1%B5%E6%91%98%E8%A6%81/)