从一开始学 HTML 和 CSS 的时候就知道了**块级元素**和**行内/内联元素**这样的概念, 不过重新复习了一遍 HTML 后发现这样的分类已经不适合这个版本了, 故稍作记录.

HTML5 中重新定义了 HTML 元素的分类, 个人理解这样做的目的主要是从两个方面约束了 HTML 元素:

* 浏览器渲染的默认样式, 这点应该还是和以前差不多, 规定了哪些元素是块级元素, 哪些是行内元素
* 元素之间的包含关系, 即一个元素可以包含哪些元素, 以及元素可以被哪些元素包含. 比如带有 `charset` 属性的 `<meta>` 就只能放在 `<head>`中, 而不能放在 `<body>` 中.

关于具体有哪些分类, 已经有很多资料了, 就贴一下参考吧.



### 参考资料

* [HTML5元素分类与内容模型](https://chenhaizhou.github.io/2016/01/19/html-element-class.html)
* https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Content_categories