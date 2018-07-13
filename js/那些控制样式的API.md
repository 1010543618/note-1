有很多 API 都能控制样式, 这里统一整理下比较常用的, 可以根据场景选择.

* `elem.style`
* `CSSStyleSheet`
* `CSSRule`
* `getComputedStyle()`



#### elem.style

大概是最常用的了, 优点是简单方便兼容性好, 缺点是它只能获取内联样式的值, 而不能获取到属性的计算值和 `<style>` `<link>` 中的值, 并且设置它会覆盖掉内联样式中原有的样式, 以及多次用它设置样式可能导致多次重绘/重排, 所以读取它得到的并不一定是最终的样式, 而设置它也不一定是最终的样式, 不过大部分时候应该是最终样式. 最常用的也是用它来设置样式而不是读取样式.

`style` 对象是一个 `CSSStyleDeclaration` 接口的实例, `style` 对象除了设置 CSS 属性以外, 还有其他一些属性

* `cssText`
* `setProperty()`
* `getPropertyPriority()`
* `removeProperty()`
* 其他

对于需要设置很多样式的场景, 可以考虑使用 `cssText`.

```javascript
// <p style="color: blue"></p>
p.style.cssText = 'color: red;background:green';
// <p style="color: red;background:green"></p>
```

而另一方面, 指望通过一般的 CSS 属性设置优先级是不行的, 只能通过 `setProperty()` 或 `cssText`

```javascript
p.style.background = 'green!important'; // 无效
p.style.setProperty('background', 'green', 'important'); // OK
p.style.cssText = 'background: green!important'; // OK
```

当然我们也可以通过 `getPropertyPriority()` 来获取某个内联样式的优先级, 好过自己手动解析 `style` 属性中的字符串, 另外它不一定要与 `style` 属性中的属性名完全一致, 属性简写或者更具体的属性都可以.

```javascript
// <p style="background: green!important"></p>
p.style.getPropertyPriority('background') // "important"
p.style.getPropertyPriority('background-color') // "important"
```

同样, `removeProperty()` 也让我们可以比较方便地删除一个属性, 而不是将他设置为空, 或者手动从 `cssText` 中删除字符串, 它也不要求与 `style` 属性中的属性名完全一致.

```javascript
// <p style="background: green"></p>
p.style.removeProperty('background');
// <p></p>
p.style.removeProperty('background-color');
// <p></p>
```

也可以通过 `elem.setAttribute()` 来设置样式, 不过这个比较麻烦, 就不说了.



#### CSSStyleSheet

准确来说, 这是一个接口, 继承自 `StyleSheet` 接口. 该接口可以简单理解为一个该接口的实例对应着一个 `<style>` 或者 `<link rel="stylesheet">`. 通常有两种方式获取该接口的实例. 一种是通过 `document.styleSheets`, 另一种是通过 `<style>` `<link>` 的 DOM 元素的 `sheet` 或 `styleSheet` 属性(`styleSheet` 是 IE 特有).

`document.styleSheets` 是一个 Array-Like 对象, 表示页面中所有的 `<style>` 和 `<link rel="stylesheet">`

```javascript
var style0 = document.styleSheets[0];
var link0 = document.styleSheets[1];

// 或
var style0 = document.getElementsByTagName('style')[0].sheet || document.getElementsByTagName('style')[0].styleSheet;
```

`CSSStyleSheet` 接口常用的属性有以下:

* `cssRules`/`rules` 取得该样式表(比如一个 `<style>`)中的所有 CSS 规则, `rules` 是 IE 特有
* `disabled` 布尔值, 设置它可以禁用掉整个样式表, 相当于该样式表不存在
* `deleteRule()`/`removeRule()` 在该样式表指定位置删除一条规则, `removeRule()` 是 IE 特有
* `insertRule()`/`addRule()` 在该样式表指定位置插入一个规则, `addRule()` 是 IE 特有

个人觉得这个接口比较有用的属性就是 `cssRules` 了, 用到这个接口也只是为了拿 `cssRules`

```javascript
var rule0 = document.styleSheets[0].cssRules[0];
```





#### CSSRule

`CSSRule` 接口代表了一条 CSS 规则, 即 `#test {color: red}` 这样的. 前面的 `cssRules` 就是一个 `CSSRule` 实例的集合.

`CSSRule` 接口的常用属性有:

* `cssText` 返回整条规则的字符串, IE 不支持
* `selectorText` 返回该规则的选择器的字符串
* `style` 一个 `CSSStyleDeclaration` 实例, 同 `elem.style` 一样, 可以通过它设置/读取该条规则中的某个具体的属性

```javascript
//<style>
//	.test {
//		width: 2000px;
//		height: 3000px;
//		background: red;
//		transform: translate3d(0, 0, 0);
//	}
//</style>

var testRule = document.styleSheets[0].cssRules[0];
testRule.cssText; // .test { width: 2000px; height: 3000px; background: red; transform: translate3d(0px, 0px, 0px); }
testRule.style.cssText; // width: 2000px; height: 3000px; background: red; transform: translate3d(0px, 0px, 0px);
testRule.selectorText; // .test
```

其实这东西吧, 个人感觉也没什么用, 它不能取得属性的计算值, 也不能取得内联样式的值, 默认优先级还不够高, 简单的样式操作, `elem.style` 设置一下就完了, 复杂的, 不如用 DOM 创建 `<style>` 一次加上去.

接下来说下应用吧.



#### 获取元素的宽高位置等信息

这个内容其实比较多, 具体参考另一篇 [浏览器中的各种宽高位置](./浏览器中的各种宽高位置.md), 这里就不细说了.



#### 获取和修改伪元素的样式

先来可靠怎么获取伪元素的样式.

##### 获取样式

因为并没有什么 API 能够获取到伪元素的 DOM 对象, 所以事实上没什么太多方法来获取和操作伪元素的样式, `getComputedStyle()` 应该是唯一一个可以获取伪元素样式的方法了.

```javascript
var style = getComputedStyle(elem, '::before');
```

不过 `getComputedStyle()` 只支持 IE9+, 但话又说回来, IE8 不支持伪元素, 所以也没什么影响.

##### 修改伪元素 content

修改 content 主要有两种方式, 第一种是通过 `attr()` 和 `data-*`.

```html
<div data-name="test" data-age="23"></div>
```

```css
div::before {
    content: 'content0' attr(data-name) 'content1' attr(data-age);
}
```

```javascript
var div = document.getElementsByTagName('div')[0];
div.dataset.name = 'new';
```

通过指定 content 为 `data-*` 的内容, 然后我们通过 DOM API 修改 `data-*` 的内容, 来间接实现修改 content 的内容. 这也是最常用的方法.

第二种方式就比较暴力了, 主要思路是直接覆盖原有样式, 新增 class 也好, 利用层叠关系也好, 或者直接通过前面的 API 修改样式表, 总的来说不推荐这样的方式, 麻烦, 且一些字符串解析拼接操作容易出错.

##### 修改伪元素样式

如果说修改 content 还有相对优雅的方式, 那修改样式基本上就是只能从暴力手段里选一个了. 个人倾向于用多个 class 切换, 如果需要运行时根据一些用户输入来改变的话, 那只能是动态插入高优先级样式来覆盖或者修改原有样式表了.



#### The end

以上的 API 大多会引起重绘重排, 使用时需要注意带来的性能开销, 总的原则是尽量获取一次快照做缓存, 在缓存基础上做计算好过多次获取, 批量修改好过多次修改, 修改离线 DOM 元素好过修改 connected 的 DOM 元素.



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/API/CSS_Object_Model
* https://developer.mozilla.org/en-US/docs/Web/API/CSSStyleDeclaration
* https://developer.mozilla.org/en-US/docs/Web/API/CSSStyleSheet
* https://developer.mozilla.org/en-US/docs/Web/API/CSSRule
* https://segmentfault.com/a/1190000003711146