在 iOS/Android/微信下, 点击 `<a>` 时可以看到有一个灰色的背景色(事实上任意可点击元素都有这个背景色, 如 `button`), 并且无论是给 `<a>` 或是 `:hover` `:active` 设置 `background:transparent;` 都不管用. 那要怎么去掉这个背景色呢? 答案是需要用到一个 Webkit 的私有属性 `-webkit-tap-highlight-color`.

eg.

```css
-webkit-tap-highlight-color: rgba(0, 0, 0, 0);
-webkit-tap-highlight-color: transparent;
```



属性支持任意颜色值, 可继承, 就像 `color` `background-color` 那样.



#### 参考资料

* https://developer.apple.com/library/content/documentation/AppleApplications/Reference/SafariWebContent/AdjustingtheTextSize/AdjustingtheTextSize.html#//apple_ref/doc/uid/TP40006510-SW5
* https://developer.mozilla.org/en-US/docs/Web/CSS/-webkit-tap-highlight-color