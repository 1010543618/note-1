#### 选择器

最简单的三类选择器

##### 元素选择器

```css
p {
  color: #fff;
}
```

选择所有 `<p>`

##### 类选择器

```css
.cls0 {
  color: #fff;
}
```

选择有一个 class 为 cls0 的所有元素

##### id 选择器

```css
#id0 {
  color: #fff;
}
```

选择 id 为 id0 的元素

##### 属性选择器

* `[attr]`
* `[attr=val]`
* `[attr~=val]`
* `[attr^=val]`
* `[attr$=val]`
* `[attr*=val]`
* `[attr|=val]`

```css
[data-v] {
  color: #fff;
}
```

选择带有 `data-v` 属性的所有元素, 或者说选择集合 A={e | 元素 e 带有属性 data-v}



```css
[data-v="test"] {
  color: #fff;
}
```

选择带有 `data-v` 属性且值为 test 的所有元素, 或者说选择集合 A={e | 元素 e 带有属性 data-v 且 data-v 的值为 test}



```css
[data-v~="test"] {
  color: #fff;
}
```

选择带有 `data-v` 属性且有一个值为 test 的所有元素, 即类似 `data-v="a b test"`, 或者说选择集合 A={e | 元素 e 带有属性 data-v 且 data-v 的一个值为 test}

注意: 必须以空格分隔的才算一个值



```css
[data-v^="test"] {
  color: #fff;
}
```

选择带有 `data-v` 属性且值以 test 开头的所有元素, 或者说选择集合 A={e | 元素 e 带有属性 data-v 且 data-v 的值以 test 开头}



```css
[data-v$="test"] {
  color: #fff;
}
```

选择带有 `data-v` 属性且值以 test 结尾的所有元素, 或者说选择集合 A={e | 元素 e 带有属性 data-v 且 data-v 的值以 test 结尾}



```css
[data-v*="test"] {
  color: #fff;
}
```

选择带有 `data-v` 属性且值中包含 test 子串的所有元素, 即类似 `data-v="atestb"`, 或者说选择集合 A={e | 元素 e 带有属性 data-v 且 data-v 的值包含子串 test}

注意: 它和 `[attr|=val]` 的区别是前者要求以空格分隔



```css
[data-v|="test"] {
  color: #fff;
}
```

选择带有 `data-v` 属性且值以 test 或 test- 开头的所有元素, 或者说选择集合 A={e | 元素 e 带有属性 data-v 且 data-v 的值以 test 或 test- 开头}



属性选择器可以组合多个

```css
input[type="password"][value$="a"] {
  background-image: url("http://localhost:3000/a");
}
```

选择类型为 password 且最后一个字母为 a 的 `<input>`.



#### 运算符

右结合, 即从右往左计算, 优先级越大的结合性越高

##### , 优先级 1

```css
div, p {
  color: #fff;
}
```

选择所有的 `<div>` 和所有的 `<p>`, 或者说选择集合 A={e | e 是 `<div>` 或者 e 是 `<p>`}

##### 空格 优先级 2

```css
div p {
  color: #fff;
}
```

选择 `<div>` 下的所有 `<p>`, `<p>` 不一定是 `<div>` 的直接子元素, 或者说选择集合 A={p | p 是 div 的子孙元素}

##### > 优先级 3

```css
div > p {
  color: #fff;
}
```

选择作为 `<div>` 的直接子元素的所有 `<p>`, 或者说选择集合 A={p | p 是 div 的直接子元素}

##### + 优先级 5

```css
h1+p {
  color: #fff;
}
```

选择 `<h1>` 后面同级的第一个 `<p>`, 或者说选择集合 A={p | p 前面的相邻元素是 h1}

##### ~ 优先级 4

```css
h1~p {
  color: #fff;
}
```

选择 `<h1>` 后面同级的所有 `<p>`, 或者说选择集合 A={p | p 的同级元素中有 h1 且 h1 在 p 之前}



#### 伪类 优先级6

设伪类修饰的是 `<p>`, DOM 顺序中的计数从 1 开始.

* `:link` 表示一个元素(通常是 `<a>`)还没有被访问的状态
* `:visited` 表示一个元素(通常是 `<a>`)被访问过后的状态
* `:hover` 表示鼠标停留在一个元素上的状态
* `:active` 表示鼠标按住在一个元素上的状态
* `:first-child` 选择 A = {e | e 是 `<p>` 且是某个元素的第一个子元素}
* `:last-child `选择 A = {e | e 是 `<p>` 且是某个元素的最后一个子元素}
* `:first-of-type` 选择 A = {e | e 是 `<p>` 且是同级的所有 `<p>` 中第一个 `<p>` }
* `:last-of-type` 选择 A = {e | e 是 `<p>` 且是同级的所有 `<p>` 中最后一个 `<p>` }
* `:nth-child()` 选择 A = {e | e 是 `<p>` 且是某个元素的第满足*表达式*个元素, 表达式可以是 odd, even, An+B,  表达式>=1, n>=0}
* `:nth-last-child()` 选择 A = {e | e 是 `<p>` 且是某个元素从后往前的第满足*表达式*个元素, 表达式可以是 odd, even, An+B,  表达式>=1, n>=0}
* `:nth-of-type()` 选择 A = {e | e 是 `<p>` 且是同级的所有 `<p>` 的第满足*表达式*个元素, 表达式可以是 odd, even, An+B,  表达式>=1, n>=0}
* `:nth-last-of-type()` 选择 A = {e | e 是 `<p>` 且是同级的所有 `<p>` 中从后往前的第满足*表达式*个元素, 表达式可以是 odd, even, An+B,  表达式>=1, n>=0}
* `:checked` 适用于 radio, checkbox, option(select)
* `:disabled` 通常用于表单元素
* `:enabled` 与 `:disabled` 相反
* `:required` 通常用于表单元素
* `:read-only` 通常用于表单元素
* `:focus` 通常用于表单元素
* `:not()` 常见用法, eg.`p:not(:last-child)`

其他的参考 https://developer.mozilla.org/en-US/docs/Web/CSS/Pseudo-classes



#### 伪元素 优先级6

* `::before` 
* `::after`
* `::first-letter`
* `::first-line`
* `::selection` 表示被选中的内容, 总感觉这应该要是个伪类
* `::placeholder` 用于 `<input>` `<textarea>`, 虽然不是标准的, 不过也比较常用

其他的参考 https://developer.mozilla.org/en-US/docs/Web/CSS/Pseudo-elements

规范上来讲, 伪元素应该用双冒号, 不过浏览器也接受单个冒号的伪元素, `::selection` 等新的伪元素都必须要用双冒号.



#### 单位

* em 相对当前元素的 `font-size`, 需要注意 `font-size` 的值可能继承自父元素
* rem 相对于根元素(html? body?)的 `font-size`
* 百分比 
* vw 1/100 的 viewport 宽度
* vh 1/100 的 viewport 高度





#### 几个特殊值

* `inherit` 设置属性值继承自父元素
* `initial` 设置属性值为浏览器默认样式, 如果浏览器没有默认样式, 则等同于 `inherit`
* `unset` 设置属性值为未做任何设置的状态, 即如果该属性没有设置值的时候是继承, 那就继承(`inherit`), 如果该属性没有设置值的时候是浏览器默认样式, 那就默认样式(`initial`)