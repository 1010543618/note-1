其实标题不能说认识 pointer-events, 毕竟这东西也用过不少了, 不过复习 CSS 的时候还是有点没注意到的细节.

关于这个属性, MDN 给的说明是:

> 指定一个图形元素是否可以成为鼠标事件的target

首先关键词--图形元素, 即一个可以看见的有实际大小的元素, 然后是鼠标事件, 即 click, blur, mousemove 等和鼠标相关的事件, target, 即实际触发事件的元素.

简单来说, 可以当作是该属性控制一个元素是否可以触发鼠标事件. 但也不完全是这样.

不过我们还是先仔细看下它有哪些值吧:

* `auto` 默认值, 即元素可以成为鼠标事件的 target
* `none` 元素不可以成为鼠标事件的 target
* 其他, 这些都是给 SVG 用的了, 需要的话再查吧, CSS 就上面两个

另外, `pointer-events` **是可以继承的**.



通常, 我们给一个元素设置 `pointer-events: none;` 可以使点击事件等鼠标事件穿透元素, 让这些事件触发在该元素底下的元素上.

现在我们考虑这样一个[例子](https://github.com/ta7sudan/front-end-demo/blob/master/css/point-events/demo0.html), 一个元素设置了 `pointer-events: none;`, 且具有子元素.

```html
<div class="parent">
	<div class="child">child</div>
</div>
<div class="parent">
	<div class="child">child
		<div class="c-child0">test</div>
	</div>
</div>
<div class="parent">
	<div class="child">child
		<div class="c-child1">test</div>
	</div>
</div>
```

```css
.parent {
	width: 200px;
	height: 200px;
	background: green;
	margin-bottom: 20px;
	position: relative;
}

.child {
	width: 100px;
	height: 100px;
	background: red;
	margin: auto;
	position: absolute;
	left: 0;
	right: 0;
	top: 0;
	bottom: 0;

	pointer-events: none;
}

.c-child0 {
	width: 50px;
	height: 50px;
	background: blue;
	margin: auto;
	position: absolute;
	left: 0;
	right: 0;
	top: 0;
	bottom: 0;
}

.c-child1 {
	width: 50px;
	height: 50px;
	background: blue;
	margin: auto;
	position: absolute;
	left: 0;
	right: 0;
	top: 0;
	bottom: 0;

	pointer-events: auto;
}
```

```javascript
window.onload = function () {
	let [parent0, parent1, parent2] = document.getElementsByClassName('parent');
	let child0 = parent0.children[0];
	let child1 = parent1.children[0];
	let child2 = parent2.children[0];
	let cchild0 = child1.children[0];
	let cchild1 = child2.children[0];
	parent0.addEventListener('click', function (e) {
		console.log('parent');
	});
	parent1.addEventListener('click', function (e) {
		console.log('parent');
	});
	parent2.addEventListener('click', function (e) {
		console.log('parent');
	});

	child0.addEventListener('click', function (e) {
		console.log('child0');
	});
	child1.addEventListener('click', function (e) {
		console.log('child1');
	});
	child2.addEventListener('click', function (e) {
		console.log('child2');
	});

	cchild0.addEventListener('click', function (e) {
		console.log('c-child0');
	});
	cchild1.addEventListener('click', function (e) {
		console.log('c-child1');
	});
};
```



在第一个例子中, 设置了 `pointer-events: none;` 的元素没有触发点击事件, 而下面的父元素触发了, 符合预期.

在第二个例子中, 设置了 `pointer-events: none;` 的元素没有触发点击事件, 并且它的子元素也没有触发点击事件, 因为 `pointer-events` 是继承的, 所以也符合预期.

在第三例子中, 设置了 `pointer-events: none;` 的元素的子元素设置了 `pointer-events: auto;`, 点击子元素, 子元素触发了点击事件,  并且冒泡到设置了 `pointer-events: none;` 的元素, 也触发了点击事件. 而点击元素本身, 依然不会触发点击事件.

但是事件的 target 始终都不是 `pointer-events: none;` 的元素, 这也符合该属性的描述. 所以准确来说, 该属性不是不让元素触发鼠标事件, 而是如定义的那样, 不能成为鼠标事件的 target.



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/CSS/pointer-events
* https://juejin.im/post/59bb2ec16fb9a00a5a31deab
* http://www.zhangxinxu.com/wordpress/2011/12/css3-pointer-events-none-javascript/