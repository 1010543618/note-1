在做一个需要把页面保存为 PDF 的功能时, 发现在 Chrome 上保存 PDF 时, 页面的各个元素的背景色在 PDF 上丢失, 查了下, 主要需要注意两点.

* 使用媒体查询 `@media print`
* 使用 `-webkit-print-color-adjust: exact`

那这个 `-webkit-print-color-adjust` 又是什么鬼?



#### -webkit-print-color-adjust

既然 webkit 开头, 自然是 webkit 浏览器支持的了. 目测可以作用于任何支持 `background-color` `background-image` 的元素. 可以用来强制浏览器打印背景色和背景图片(当然也适用于保存为 PDF). 属性有两个值:

* `economy` 默认值, 除非用户显式允许, 否则不打印背景色和背景图片, 表现也就是保存为 PDF 时丢失背景了
* `exact` 总是打印背景色和背景图片, 也是我们需要的

另外就是属性可以继承. 总的来说比较简单, 没什么好多说的. 主要就是这两点. 套路化一点就是

```css
@media print, screen {
    body {
        -webkit-print-color-adjust: exact;
    }
}
```



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/CSS/-webkit-print-color-adjust