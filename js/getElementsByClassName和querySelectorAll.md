记得很久以前, 我还在用着 `getElementsByClassName()` 来获取一组元素时, 被人教育说, 现在已经 7102 年了还用这做啥, 各大浏览器都已经支持 `querySelectorAll()`, 仿佛 `getElementsByClassName()` 已经被扫入历史的垃圾堆了. 当然, 我也知道浏览器普遍已经支持新的 API 了, 不过出于直觉上认为 `querySelectorAll()` 解析 CSS 选择器应当要比直接通过类名获取来得慢些, 所以也就一直习惯用着 `getElementsByXXX` 这类 API 了. 另一方面是后者也并没有让我少敲几个字符并不见得方便到哪里去.

不过直觉终归是直觉, 自我感觉这种事情终究不是很靠谱, 毕竟我的感觉往往是错的, 所以这里还是认真探讨下这两者之间的区别.

以下我们讨论的其实是两类 API, 一类是 `getElementById()` `getElementsByTagName()` `getElementsByClassName()` 等, 一类是 `querySelector()` `querySelectorAll()`. 在此之前也顺便提一些细节:

* `getElementsById()` 只能通过 `document` 对象调用, 而不能通过其他元素调用, 因为 id 在文档中是唯一的, 没必要再让其他元素继承这一方法
* `getElementsByTagName()` 不能用来获取驼峰命名的 SVG 元素(但是可以用来获取非驼峰命名的 SVG 元素, 比如 `<circle>`), 这种时候最好用 `getElementsByTagNameNS()`
* `getElementsByTagName()` 根据规范应当返回 `HTMLCollection` 对象, 不过 Webikit 浏览器返回的是 NodeList 对象, 实测 Chrome 是返回 `HTMLCollection` 符合规范, 可能 Safari 不符合规范吧
* `getElementsByTagName()` `getElementsByClassName()` 都可以通过其他元素而非 `document` 对象调用, 通常来说这样快一点, 缩小了搜索范围
* `querySelector()` `querySelectorAll()` 不能用来获取伪元素
* `querySelector()` `querySelectorAll()` 可以通过非 `document` 对象的其他元素调用



再简单说下 `HTMLCollection` 和 `NodeList` 对象的区别. 

显然, 它们暴露的 API 不一样(废话). `HTMLCollection` 和 `NodeList` 都是 arrya-like 的对象, 即都有 length 属性但都不是数组. 主要的两个区别是, `HTMLCollection` 的内容都是元素, 而 `NodeList` 的内容可以是元素节点, 也可以是属性节点, 文本节点等. 另一方面是, `HTMLCollection` 都是实时的(live), 即内容会随着 DOM 的变化动态更新, 而 `NodeList` 可能是实时的, 也可能不是, 实时的例子, `childNodes` 是实时的.

*注: 后文只讨论返回集合的方法, 如 `getElementsByTagName()` `getElementsByClassName()` `querySelectorAll()`, 方便起见只写 `getElementsByClassName()` 和 `querySelectorAll()` 的差异, 对于 `getElementsByTagName()` 来说也是一样*



OK, 现在让我们来看看 `getElementsByClassName()` 和 `querySelectorAll()` 的一些区别.

毫无疑问, `querySelectorAll()` 支持 CSS 选择器, 而 `getElementsByClassName()` 不支持. 不过即使只考虑普通的类名, 两者也还是有些区别. `getElementsByClassName()` 返回的是一个 `HTMLCollection`, 而 `querySelectorAll()` 返回的是一个**非实时的** `NodeList`, 这意味着 `querySelectorAll()` 得到的只是调用时刻的一个快照. 不过这也不是很全面. 事实上, 调用 `getElementsByClassName()`, 或者说拿到 `HTMLCollection` 对象, 并没有去查找 DOM, 而是在使用 `HTMLCollection` 中的内容时才会去查找 DOM.

```javascript
var divs = document.getElementsByClassName('test'); // 没有查找 DOM
var a = divs[0]; // 查找了 DOM
console.log(divs.length); // 查找了 DOM
```

实际上这类似一个延迟绑定的过程, 而 `querySelectorAll()` 则是调用时就遍历 DOM, 这也导致调用 `getElementsByClassName()` 会比调用 `querySelectorAll()` 来得快一些. 另一个问题是, 因为 `HTMLCollection` 是实时的, 在上面的例子中, 使用了两次 `HTMLCollection` 的内容, 是否会导致遍历两次 DOM? 猜测应该是会的, 实时的话浏览器应该不知道下次获取时是否有过变化, 也就没法做缓存. 如果是这样的话, 那遍历 `HTMLCollection` 的开销可能会比遍历非实时的 `NodeList` 来得大. 不过也可能浏览器有什么我想不到的优化姿势也说不定吧.

所以 `getElementsByClassName()` 还是有它的用途的, 并非用 `querySelectorAll()` 就是好的, 根据合适的场景选择合适的方案才是对的, 简单来说, 如果确定所有元素会被立即用到, 那使用 `querySelectorAll()`, 否则使用 `getElementsByClassName()`.



这里顺便提下另一个关于 `querySelector()` `querySelectorAll()` 的细节, 那就是它们和 jQuery 的工作方式并不一样. 考虑下面例子.

```html
	<div class="outer">
		<div class="select">
			<div class="inner"></div>
		</div>
	</div>
```

```javascript
var select = document.querySelector('.select');
var inner = select.querySelectorAll('.outer .inner');
console.log(inner.length);
// 1
var select = $('.select');
var inner = select.find('.outer .inner');
console.log(inner.length);
// 0
```

对于 jQuery 来说, 我们的查找过程其实是查找匹配 `.select .outer .inner` 的元素, 对于 `querySelectorAll()` 来说, 始终都只是查找匹配 `.outer .inner` 的元素, 而 `.select` 的意义只是缩小查找范围, 而不会用 `.select` 进一步约束后面的选择器.



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/API/Document/getElementById
* https://developer.mozilla.org/en-US/docs/Web/API/Document/getElementsByTagName
* https://developer.mozilla.org/en-US/docs/Web/API/Document/getElementsByClassName
* https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector
* https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelectorAll
* https://developer.mozilla.org/en-US/docs/Web/API/HTMLCollection
* https://developer.mozilla.org/en-US/docs/Web/API/NodeList
* http://blog.lxjwlt.com/front-end/2015/09/01/u-dont-know-queryselector.html
* https://zhuanlan.zhihu.com/p/24911872
* https://dreamapple.me/2017/04/07/%E4%B8%BA%E4%BB%80%E4%B9%88getelementsbytagname%E6%AF%94queryselectorall%E6%96%B9%E6%B3%95%E5%BF%AB/