先看一下跟 background 相关的有哪些属性吧

* `background-attachment`
* `background-blend-mode`
* `background-clip`
* `background-color`
* `background-image`
* `background-origin`
* `background-position`
* `background-repeat`
* `background-size`



#### background-attachement

当 `background-image` 存在时, 控制背景跟随视口滚动还是跟随背景所在元素本身滚动, 这么讲有点抽象, 可以直接看 [demo](https://github.com/ta7sudan/front-end-demo/blob/master/css/background/demo0.html), 该属性有三个值:

* `scroll` 默认值, 背景图片跟随视口滚动, 但是不跟随元素本身滚动
* `local` 背景图片既跟随视口滚动, 也跟随元素本身滚动
* `fixed` 背景图片既不跟随视口滚动, 也不跟随元素本身滚动



#### background-blend-mode

当一个元素有多个背景/背景图片的时候, 控制这些背景之间如何混合. 这个属性不怎么常用...还是算了吧...



#### background-clip

控制背景的绘制区域/裁剪区域, 即背景最多只能出现在这块区域内. 有四个值:

* `border-box` 默认值, 背景绘制区域<=border-box
* `padding-box` 背景绘制区域<=padding-box
* `content-box` 背景绘制区域<=content-box
* `text` 背景绘制区域<=文字内容, 即根据文字内容裁剪背景

具体效果看 [demo](https://github.com/ta7sudan/front-end-demo/blob/master/css/background/demo1.html), 需要注意的是, `text` 的值目前还需要加浏览器前缀, 以及最好把文字设置成 `color: transparent`, 不然文字颜色会和背景色混合.



#### background-color

没什么好说的, 记住两个值就好

* `transparent` 透明色
* `currentcolor` 颜色同当前元素的 `color` 一样



#### background-image

可以有多个背景图片, 用逗号分隔, 从左往右的图片对应的图层顺序是从上往下

##### 线性渐变

`linear-gradient(角度? 颜色0, 颜色1, ...)` 

角度默认 180deg, 可以省略. 注意角度是以元素背景定位区域的中心为原点, 射线方向向上为 0deg, 顺时针方向为正. 渐变的方向就是角度射线的方向. 关于这个角度的坐标系为什么这么智障, 为什么和之前坐标系的认知都不一样, 参考 https://developer.mozilla.org/en-US/docs/Web/CSS/angle

渐变方向按照颜色列表从左往右. 颜色的值可以是 `#000` 也可以是 `#000 40%`, 百分比表示颜色断点的位置.

eg.

```css
background-image: linear-gradient(90deg, #000 20%, #fff 20%, #000, #fff);
```

意思是从 0% 到 20% 是 #000, 从 20% 开始是 #fff, 然后均匀渐变到 #000 再到 #fff.

具体参考 https://developer.mozilla.org/en-US/docs/Web/CSS/linear-gradient



##### 径向渐变

`radial-gradient(形状?大小?对称中心位置?颜色0 0%, 颜色1 50%, ...颜色n 100%)` 

形状可以有两个值 `circle` `ellipse`, 即圆和椭圆, 描述圆锥曲线的形状. 

大小可以是常用的长度单位, 如 px, em, 写作 `rpx` 或者 `xpx ypx`. 对于圆, 只有一个值, 即半径, 对于椭圆, 两个值, x 半轴的长度和 y 半轴的长度, 注意这里没区分半长轴和半短轴, 而是通过 x y 的方向来确定椭圆的方向, 比如 y 的值大于 x, 则椭圆方向垂直.

对称中心位置相对于以 `background-origin` 为原点的坐标系, 写作 `at xpx ypx`.

颜色列表从左往右对应颜色渐变是从对称中心向外. 以对称中心到半长轴端点的距离为 100% 的话, 颜色的百分比即为颜色的断点.

eg.

```css
background-image: radial-gradient(ellipse 80px 40px at 20px 30px, #fff 0%, #000 50%, #fff 100%);
```

以上即圆锥曲线为椭圆, x 半轴为  80px, y 半轴为 40px, 对称中心相对于 `background-origin` 的坐标是 20px 30px. 渐变从 #fff -> #000 -> #fff.

具体参考 https://developer.mozilla.org/en-US/docs/Web/CSS/radial-gradient

该属性的 [demo](https://github.com/ta7sudan/front-end-demo/blob/master/css/background/demo2.html).



#### background-origin

控制绘制背景的起始点的位置, 更准确地说是控制**背景定位区域(background positioning area)**有以下值:

* `border-box` 从 border 框的左上角开始绘制
* `padding-box` 默认值, 从 padding 框的左上角开始绘制
* `content-box` 从 content 框(内容区)的左上角开始绘制

注意它和 `background-clip` 的区别, clip 限制了背景出现的区域, 即区域外是看不到背景的, origin 是指定背景开始绘制的起始点, 即在有 `background-repeat` 的情况下, 背景图片还是会出现在 `border-box` 中, 只不过第一张图片(即 `background-repeat: no-repeat` 时的那张图片)是从指定的 box 的左上角开始绘制

注意如果 `background-attachment` 的值为 `fixed` 的话, 该属性会被忽略.

该属性的 [demo](https://github.com/ta7sudan/front-end-demo/blob/master/css/background/demo3.html).



#### background-position

指定背景图片相对于背景定位区域(即 `background-origin` 确定的区域)的位置, 有以下值:

* `top`
* `bottom`
* `left`
* `right`
* `center`
* `xunit yunit` 单位可以是任意常见单位如 px, %

关键字之间可以自由组合, 如 `top left` `top left 30px`(左上角, 距左边偏移 30px), `top 30px left 30px`(左上角, 距上面和左边各偏移 30px)

需要注意的是, 百分比单位的定位是指, 图片左上角位于*背景定位区域的大小减去图片大小的差的百分比*, 说人话就是图片的 x% 处与背景定位区域的 x% 处对齐. 举个例子: 设图片大小 100x100, 背景定位区域(border-box) 大小 400x400, 有如下属性

```css
background-origin: border-box;
background-position: 20% 50%;
```

则图片左上角的 x = (400 - 100) * 20% = 60, y = (400 - 100) * 50% = 150, (x, y) 相对于 border-box 左上角.

该属性的 [demo](https://github.com/ta7sudan/front-end-demo/blob/master/css/background/demo4.html).



#### background-repeat

已经很熟悉了, 没太多好说的, 注意 `space` `round` 这两个值就好

* `repeat` 默认值
* `no-repeat`
* `repeat-x`
* `repeat-y`
* `space` x y 方向都会重复, 但是会尽可能使图片顶部贴裁剪区域顶部, 左边贴裁剪区域左边, 以此类推, 剩余空间均匀分配到所有图片之间
* `round` 以尽可能少的图片铺满裁剪区域, 使得使图片顶部贴裁剪区域顶部等等, 会导致图片拉伸/压缩.





#### background-size

设置背景图片的大小, 有以下值:

* `contain` 简单讲就是, 使图片尽可能完整地出现在裁剪区域(图片的长边对裁剪区域的短边), `no-repeat` 时可能会留出空白
* `cover` 简单讲就是, 使图片尽可能填满裁剪区域(图片的短边对裁剪区域的长边), `no-repeat` 时也不会留出空白
* `xunit yunit` 单位可以是任意常见单位如 px, %

注意百分比单位是相对于背景定位区域的大小, 如果 `background-attachment: fixed` 的话, 百分比单位相对整个视口(viewport).

该属性的 [demo](https://github.com/ta7sudan/front-end-demo/blob/master/css/background/demo5.html).



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Learn/CSS/Styling_boxes/Backgrounds
* https://developer.mozilla.org/en-US/docs/Web/CSS/background-attachment
* https://developer.mozilla.org/en-US/docs/Web/CSS/background-clip
* https://developer.mozilla.org/en-US/docs/Web/CSS/background-color
* https://developer.mozilla.org/en-US/docs/Web/CSS/background-image
* https://developer.mozilla.org/en-US/docs/Web/CSS/background-origin
* https://developer.mozilla.org/en-US/docs/Web/CSS/background-position
* https://developer.mozilla.org/en-US/docs/Web/CSS/background-repeat
* https://developer.mozilla.org/en-US/docs/Web/CSS/background-size
* https://developer.mozilla.org/en-US/docs/Web/CSS/linear-gradient
* https://developer.mozilla.org/en-US/docs/Web/CSS/radial-gradient
* https://developer.mozilla.org/en-US/docs/Web/CSS/angle
* https://juejin.im/post/5a5f72e36fb9a01c9d31e70d