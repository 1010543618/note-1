很多时候我们总是希望能够自己定制表单控件的样式, 因为同一个表单控件在不同浏览器上的表现往往不太一样. 但是当你想尽一切可能的属性, 修改 `background` 修改 `border` 修改 `outline` 等等, 却发现有些控件的样式还是有点问题. 这种时候我们可以通过 `-webkit-appearance` `-moz-appearance` 来去除表单控件的默认样式. 这个属性不支持 IE (But who cares).

这个属性有很多值, 不过正常来讲我们只需要知道 `none` 这个值就行, 它可以去除浏览器的默认表单控件的样式.

eg.

```css
-webkit-appearance: none!important;
-moz-appearance: none!important;
```

其实最多的应用场景是移动端, 给 `<button>` `<input>` `textarea` 之类设置该属性, 尤其是 `<button>`, 通常我们既想要保证 HTML 的语义, 又希望能够更好地自定义样式, 这时候我们可以使用该属性. PC 端我个人倾向也可以用, 毕竟写自己的博客不是很 care IE 的情况 - -.

另外就是给 `<select>` 或者 checkbox 设置该属性的话意义不大, 还是很难处理, 在现代化框架的加持下, 个人建议手写一个 checkbox 和 select 组件吧.



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/CSS/-moz-appearance
* https://segmentfault.com/a/1190000005923855