如果你知道 `background-size` 和 `background-position` 的话, 那这里的内容对你来说非常容易理解. 下面简单介绍下相关的属性吧.



#### object-fit

用于指定替换元素(如 `<img>` `video` 等)在它的容器内如何裁剪. 什么叫它的容器呢? 其实就是它的 content-box, 你可以理解为这些替换元素都是被放置在一个类似 `inline-block` 的框里, 这个框的大小就是这些替换元素的 content-box 的大小, 而被裁剪的对象的大小, 则是替换元素(比如图片)本身原始的大小. 类比到 `background` 就是替换元素的 content-box 相当于*背景定位区域*, 原始大小的替换元素相当于 `background-image`.

值得注意的是这个属性是**应用于替换元素的**, 会给人一种感觉是, 裁剪区域是它自己, 被裁剪的对象也是它自己. 也因为这个原因, **如果不给替换元素设置宽高, 或者给替换元素设置宽高和原始大小的比例一样, 那这个属性就意义不大了**.

为什么这么说, 还是直接看 demo.

```html
<div class="main m0">
	<img src="./images/img.jpg" alt="sicp">
</div>
```

```css
.main {
	width: 150px;
	height: 100px;
	margin: 50px;
	border: 10px solid red;
}
.main > img {
	width: 100%;
	height: 100%;
	border: 10px solid #000;
}
```



`object-fit: contain`

![img152](./images/img152.png)





`object-fit: cover`

![img153](C:/codes/note/css/images/img153.png)



`object-fit: fill`

![img154](C:/codes/note/css/images/img154.png)



`object-fit: none`

![img155](C:/codes/note/css/images/img155.png)



`object-fit: scale-down`

![img156](C:/codes/note/css/images/img156.png)

可以看到, 这里我们给了图片一个和原始比例不一样的宽高.

属性一共就这几个值

* `fill` 默认值, 拉伸图片填充满整个 content-box
* `contain` 类似 `background-size: contain`, 使图片尽可能完整地出现在 content-box(图片的长边对 content-box 的短边)
* `cover` 类似 `background-size: cover`, 使图片尽可能填满 content-box(图片的短边对 content-box 的长边)
* `none` 不拉伸图片, 保持原始尺寸
* `scale-down` 图片的大小是 `none` 或 `contain` 中较小的那个的大小

[示例代码](https://github.com/ta7sudan/front-end-demo/blob/master/css/objectfit/demo0.html)



#### object-position

和 `background-position` 一样, 自然也有这样一个属性控制实际内容在 content-box 中的定位. 它的值也和 `background-position` 一样.

eg.

```css
object-position: top left;
object-position: 50px 50px;
object-position: 50% 50%;
```

定位区域自然是 content-box, 百分比单位和 `background-position` 的计算方式是一样的, 即图片的 x% 处与定位区域的 x% 处对齐.

[示例代码](https://github.com/ta7sudan/front-end-demo/blob/master/css/objectfit/demo0.html)



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/CSS/object-position
* https://developer.mozilla.org/en-US/docs/Web/CSS/object-fit