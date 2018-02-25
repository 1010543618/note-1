#### 几个术语

首先我们来了解几个术语.

* **网格容器(grid container)**, `display: grid;` 或 `display: inline-grid;` 的元素(的 content-box?), 即整个网格系统都在该元素内部, 而网格容器对外(其他元素)依然是块级元素或者行内元素. 这个元素的所有正常流中的直系子元素都将成为**网格项目(grid item)**.
* **网格轨道(grid track)**, 任意两条网格线(还是相邻两条?)之间的空间, 即一行或者一列, 之后简称轨道.
* **显式网格(explicit grid)和隐式网格(implicit grid)**, 通过 `grid-template-columns` 和 `grid-template-rows` 创建出来的轨道, 我们称它们属于显示网格. 但是这些轨道不一定能容纳所有的 grid item, 浏览器根据 grid item 的数量计算出来需要更多的轨道, 就会自动生成新的轨道, 这些自动生成的轨道我们称它们属于隐式网格.
* **网格线(grid line)**, 
* **网格单元(grid cell)**
* **网格区域(grid area)**
* **网格间距(gutter)**



#### 几个函数

* `repeat()`
* `minmax()`
* `fit-content()`

##### repeat()

`repeat()` 可以被用于 `grid-template-columns` 和 `grid-template-rows` 属性.



`display: grid` 会创建一个 BFC

`float` 和 `clear` 对 grid item 是无效的, 即 grid item 不会表现得像浮动元素一样, 但是 `float` 会影响 grid item 的 `display` 的计算值(具体参考 [复习float](./复习float.md)), 比如原本 grid item 是 `display: inline;`, 加了 `float` 后尽管不会有浮动的表现, 但是 `display` 的计算值会变成 block.

`vertical-align` 对 grid item 是无效的.

伪元素 `::first-line` 和 `::first-letter` 不能用于 grid 容器.

`grid-template-columns` 定义的是轨道的宽度而不是元素的宽度, 元素的 margin-box 在轨道之中

什么时候自动创建隐式的列?

网格线可以被命名

多个 grid item 可以占据同一个网格单元

grid item 并不是网格单元, 而是一个元素, 可能占据多个网格单元

absolute 的 grid item 不参与网格布局的大小调整

#### 参考资料

* https://drafts.csswg.org/css-grid/#grid-containers
* https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Grid_Layout
* https://developer.mozilla.org/en-US/docs/Web/CSS/repeat