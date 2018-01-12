`<figure>` 通常用来给图片提供一个容器, 辅以图片相应的描述. 它可以包含 [flow元素](https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Content_categories#Flow_content), 支持[通用属性](https://developer.mozilla.org/en-US/docs/HTML/Global_attributes).



示例:

```html
<firgure>
	<img src="./demo.jpg" alt="demo">
	<figcaption>A demo</figcaption>
</firgure>
```

![img0](./images/img0.png)

当然我也可以这么写

```html
<div class="figure">
	<img src="./demo0.jpg" alt="demo">
	<p>A demo</p>
</div>
```

不过显然用 `<figure>` 更符合语义一点.

另外 `<figure>` 中也不要求一定是一张图片, 也可以是多张图片, 或者代码片段, 或者视频音频内容, 或者表格等.



而 `<figcaption>` 则只能放在 `<figure>` 中, 并且要么作为第一个子元素, 要么作为最后一个子元素.



### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/HTML/Element/figure
* https://developer.mozilla.org/en-US/docs/Web/HTML/Element/figcaption