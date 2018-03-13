虽然 CSS3 的伸缩平移变换已经用过很多了, 但是对它的坐标系也一直是模模糊糊的感觉. 你要问我 `transform: translate(-50%, -50%);` 的 -50% 相对于什么, 那我大概也只能说相对于元素本身. 但是"本身"是什么? 是元素的 content-box? padding-box? or border-box?

今天还是把这个细节彻底撸清楚. 现在我们可以说, 是相对于**本地坐标系(local coordinate system)**.



#### 本地坐标系(local coordinate system)

其实很简单, 本地坐标系就是以元素的某个区域建立的坐标系. 这个区域由 `transform-box` 指定, 该属性有以下值:

* `border-box` 默认值
* `fill-box` 给 SVG 用的
* `view-box` 给 SVG 用的

有点像 `background-origin` 的作用, 不过按理来说这东西应该叫 `transform-origin` 才是, 可能是因为 `transform-origin` 已经被用掉了吧.

所以实际上对于我们平时就是有且只有 border-box 可用. 所以可以准确地说, 现在和 transform 相关的那些定位的百分比, 都是相对于 border-box 而言的.



#### 参考资料

* https://drafts.csswg.org/css-transforms-1/#local-coordinate-system
* https://drafts.csswg.org/css-transforms-1/#transform-box
* https://developer.mozilla.org/en-US/docs/Web/CSS/transform-box