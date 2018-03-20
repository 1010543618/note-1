用于给可滚动的元素(通常是 `overflow: scroll` 的元素)设置是否具有滚动回弹的效果, 有两个值:

* `auto` 默认值, 没有滚动回弹, 即当手指从屏幕移开时, 内容会立即停止滚动
* `touch` 滚动回弹, 基于动量的滚动, 当滚动手势完成(手指移开屏幕后), 内容还会继续滚动一段时间, 持续滚动的速度和持续滚动的时间与滚动手势的力度成正比. 并且**还会创建一个新的层叠上下文**.

eg.

```css
-webkit-overflow-scrolling: touch;
```



浏览器特性检测

```javascript
if ('webkitOverflowScrolling' in document.body.style) {
    // ...
}
```



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/CSS/-webkit-overflow-scrolling