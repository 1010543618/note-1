在移动端, 经常会有自定义按钮的需求. 当你写好一个按钮, 突然产品告诉你说, "怎么点击按钮的时候一不小心就选中了按钮的文字? 赶紧解决一下." So, 要解决这个问题, 就需要用到 `user-select` 这个属性了.

属性有以下值:

* `auto` 默认值, 通常来说也是可以选中
* `none` 元素内及其子元素的文字不能被选中
* `text` 可以选中文字
* `all` 如果子元素中的内容被双击, 则选中具有 `user-select: all` 的最顶层的祖先元素
* `contain` 
* `element` 
* `-moz-none` 

属性主要给移动端用, 不过 PC 端也 OK. 其中就 `none` `text` 比较有用. 通常我们用 `none` 禁止选中文字. eg.

```css
user-select: none;
```



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/CSS/user-select