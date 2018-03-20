`clip-path` 的基本语法

```
CLIP_PATH ::= <URL> | <AREA> | "none"
AREA ::= <BASIC_SHAPE> | <GEOMETRY_BOX>
GEOMETRY_BOX ::= "content-box" | "border-box" | "padding-box" | "margin-box" | "fill-box" | "stroke-box" | "view-box"
BASIC_SHAPE ::= "inset()" | "circle()" | "ellipse()" | "polygon()"
```

`url()` 可以引入 SVG 中的 `<clipPath>` 元素.

几个盒子关键字中只有 `content-box` `border-box` `padding-box` `margin-box` 是对 HTML 适用的, 其他的是对 SVG 用的.

所有函数的定位坐标都是相对于本地坐标系, 以下是几个函数的具体说明:

* `inset()` 矩形区域裁剪, `inset(<length>{1,4} [round <border-radius>])`, length 的四个值依次是相对本地坐标系的盒子(reference box 也即 border-box) top, right, bottom, left 的偏移量, 同时也可以指定一个可选的圆角 border-radius, 语法和 `border-radius` 属性一样. eg. `inset(110px 110px 110px 110px round 25px 20px 15px 10px/10px 8px 6px 4px)`
* `circle()` 圆形区域裁剪, `circle([radius] [at <position>])`, radius 半径, 百分比值相对于本地坐标系的盒子的 $O$ 来计算. $O$ 是盒子宽和高的均方根, 即 $$O=\sqrt{\frac{width^{2}+height^{2}}{2}}$$. position 也是以本地坐标系来定位. eg. 一个 border-box 500x300 的元素,  `clip-path: circle(10% at 50% 50%)`, 意味着圆的直径为 $$\sqrt{\frac{500^{2}+300^{2}}{2}}\div10\times2=82.46$$, 位于 border-box 的 (50%, 50%) 处
* `ellipse()` 椭圆区域裁剪, `ellipse([x y] [at <position>])`, x y 分别是 x 方向半轴长度和 y 方向半轴长度, x 的百分比相对于本地坐标系的盒子 x 方向的大小, y 的百分比相对于本地坐标系的盒子 y 方向的大小. eg. `clip-path: ellipse(20% 10% at 50% 50%)`
* `polygon()` 多边形裁剪, `polygon([fill-rule] {,} {x y}{, x y})`, fill-rule 填充规则有两个值 `nonzero` `evenodd`, 即非零环绕规则和奇偶规则. 具体用法见 [W3C](https://www.w3.org/TR/SVG/painting.html#FillRuleProperty). x y 是每个点的坐标. x y 的百分比单位同 `ellipse()`. eg. `clip-path: polygon(60% 20%, 30% 40%, 50% 60%)`

[示例代码]()



#### 需要注意的点

默认情况下, 鼠标事件不能在剪切区域以外触发(By default, pointer-events must not be dispatched on the clipped-out (non-visible) regions of a shape).

`clip-path` 不影响元素的固有几何形状(It does not affect the element’s inherent geometry), 即不会改变元素的盒子大小, 元素依然像没有 `clip-path` 那样占据同样的大小.

配合 CSS3 动画食用味道更佳.

需要兼容性的话, `clip` 这个过时属性了解一下.



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/CSS/clip-path
* https://developer.mozilla.org/en-US/docs/Web/CSS/clip
* https://drafts.fxtf.org/css-masking-1/#the-clip-path
* http://blog.csdn.net/freshforiphone/article/details/8273023