经常会有这样的需求, 是调整表单元素的 placeholder 的样式, 或者统一各个浏览器中 placeholder 的样式. 实现起来也很简单, 通过 `::placeholder` 伪元素来实现.

eg.

```css
input::-webkit-input-placeholder {
    color: red;
}
input::-moz-placeholder {
    color: red;
    opacity: 1;
}
input:-ms-input-placeholder {
    color: red;
}
input::placeholder {
    color: red;
}
```

这里面有些是伪类, 有些是伪元素, 注意区分. 另外, FF 的 placeholder 默认还会有透明度, 所以需要加上 `opacity: 1`. 这里的基本上能够兼容所有浏览器了, 不过对于 FF 的低版本, 应该使用伪类 `:-moz-placeholder` 而不是伪元素.

既然这些都差不多, 那为什么不写在一个选择器里而要分开写呢? 比如这样

```css
input::-webkit-input-placeholder,
input::-moz-placeholder,
input:-ms-input-placeholder,
input::placeholder {
	color: red;
}
```

因为一旦一个不能被识别, 其他的都跟着失效, 所以不能这样写.



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/CSS/::placeholder
* https://developer.mozilla.org/en-US/docs/Web/CSS/::-webkit-input-placeholder
* https://developer.mozilla.org/en-US/docs/Web/CSS/:-ms-input-placeholder
* https://developer.mozilla.org/en-US/docs/Web/CSS/::-moz-placeholder
* https://segmentfault.com/q/1010000000397925