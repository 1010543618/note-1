这个属性和浏览器的渲染机制密切相关. 但是实际使用来说也不复杂.

属性可以作用于所有元素, 属性的作用是用来提示浏览器该元素在页面展示的过程中可能会发生哪些改变(比如 transform 动画), 以便浏览器可以针对性进行优化.

属性有以下值:

* `auto` 默认值, 等于没有任何提示
* `scroll-position` 提示浏览器可能会改变元素的滚动位置
* `contents` 提示浏览器可能会改变元素的内容
* 其他任意属性, 提示浏览器该属性之后可能发生变化

eg.

```css
will-change: transform; /* 提示浏览器之后 transform 的值可能发生改变 */
```

需要注意的几个点:

* 大部分时候, 我们通过该属性来提升合成层, 即 `will-change` 是 `opacity` `transform` `top` `bottom` `left` `right`, 其中 `top` 等必须在有非 `static` 定位的情况下才会创建合成层
* 它也可以为 `fixed` `absolute` 定位的元素创建包含块, 即 `will-change` 的值为 `transform` 或 `perspective` 的元素会创建一个包含块
* 它还可以创建层叠上下文(废话, 都创建合成层了), `will-change` 中指定了任意 CSS 属性的元素(实测并不是, 而是 `transform` `opacity` 等值才会创建)
* 不要没事就用 `will-change` 提升合成层, 创建合成层是由内存开销的, 传输图层也是有时间开销的. 通常仅在动画时提升一下图层就好
* 浏览器进行优化的正常行为是尽快优化再尽快删除优化, 毕竟一直保持优化状态也是有开销的, 所以不建议在 CSS 中直接使用 `will-change`, 而建议通过 JS 在需要优化时动态添加 `will-change` 然后不需要优化时再删除掉
* 不要过早优化, 如果你的页面运行良好就不要用 `will-change`. 我们应当在发现性能问题时去解决它, 而不是用 `will-change` 去预测性能问题可能会发生. 过度使用 `will-change` 会可能导致更差的性能



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/CSS/will-change
* https://www.chromium.org/developers/design-documents/gpu-accelerated-compositing-in-chrome
* http://taobaofed.org/blog/2016/04/25/performance-composite/