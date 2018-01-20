首先来看一下与表格相关的标签

* `<table>`
* `<caption>`
* `<thead>`
* `<tbody>`
* `<tfoot>`
* `<colgroup>`
* `<col>`
* `<tr>`
* `<td>`
* `<th>`



#### table

关于 `<table>` 需要关注的只有它里面可以放些什么:

* 0 - 1 个 `<caption>`
* 0 - n 个 `<colgroup>`
* 0 - 1 个 `<thead>`
* 0 - 1 个 `<tfoot>`
* 1 - n 个 `<tr>` 或者 0 - n 个 `<tbody>`

至于 `<table>` 可以用的属性目前都已经过时了.



#### caption

用作表格的标题, 需要注意的是, `<caption>` 总是应该放在 `<table>` 的后面, 即作为第一个子元素. 另外如果 `<table>` 在 `<figure>` 中的话, 应该使用 `<figcaption>` 而不是 `<caption>`, `<figcaption>` 作为 `<figure>` 的直接子元素.

没有什么重要的属性.



#### thead

`<thead>` 里面只能放 `<tr>`. 它必须在 `<caption>` 或者 `<colgroup>` 的后面, 并且在 `<tbody>` `<tfoot>` 前面.

没有什么重要属性.



#### tbody

`<tbody>` 里面只能放 `<tr>`.  它必须**紧贴**在 `<thead>` 和 `<tfoot>` 之间(如果有这两个的话). 如果 `<table>` 有 `<tr>` 作为子元素, 则 `<tbody>` 不能出现, 反之也一样, `<tr>` 和 `<tbody>` 是互斥的.



#### tfoot

`<tfoot>` 里面只能放 `<tr>`. 它必须在 `<caption>` `<colgroup>` `<thead>` `<tbody>` `<tr>` 之后. 

没有什么重要的属性.



#### colgroup

用来给表格已有的列进行分组, 通常配合 CSS 使用.

如果 `<colgroup>` 设置了 `span` 属性, 则它是一个空元素, 里面不能放任何元素. 否则里面可以放 `<col>`. 它必须被放在 `<caption>` 之后以及 `<thead>` `<tbody>` `<tfoot>` `<tr>` 之前.

具有一个属性 `span`, 用来表示该 `<colgroup>` 代表 n 列, eg.

```html
...
<colgroup></colgroup>
<colgroup class="grp2" span="2"></colgroup>
<tr>
  <td>aaa</td>
  <td>aaa</td>
  <td>aaa</td>
  <td>aaa</td>
</tr>
```

则第一个 `<colgroup>` 代表了第一列, 第二个 `<colgroup>` 代表了二三列, 给 `colgroup.grp2` 设置样式即代表给第二三列设置样式.



#### col

配合 `<colgroup>` 使用, 也有一个属性 `span`, 用来表示该 `<col>` 代表 n 列, eg.

```html
...
<colgroup span="2"></colgroup>
<colgroup>
  <col>
  <col span="2">
</colgroup>
<colgroup></colgroup>
<tr>
  <td>aaa</td>
  <td>aaa</td>
  <td>aaa</td>
  <td>aaa</td>
  <td>aaa</td>
  <td>aaa</td>
  <td>aaa</td>
  <td>aaa</td>
</tr>
```

第一个 `<colgroup>` 代表头两列, 第二个 `<colgroup>` 代表三四五列, 其中第二个 `<col>` 代表四五列, 第三个 `<colgroup>` 代表第六列.



#### tr

`<tr>` 里面可以放 `<td>` `<th>` `<script>` `<template>`. 它必须放在 `<caption>` `<thead>` 之后, 以及不能和 `<tbody>` 出现在同一级.

没有什么重要的属性.



#### td

具有以下属性:

* `rowspan` 合并后面垂直方向的 `<td>`
* `colspan` 合并后面水平方向的 `<td>`
* `headers` 把一个 `<td>` 和一个 `<th>` 关联起来, 它的值是某个 `<th>` 的 id, 可以关联多个, 用空格分隔. 不会对视觉效果产生什么影响.



#### th

基本上和 `<td>` 差不多, 只不过语义上应该是作为一个头部的单元格.

具有以下属性:

* `rowspan` 同 `<td>`
* `colspan` 同 `<td>`
* `headers` 同 `<td>`
* `scope` ???





### 参考资料

* https://developer.mozilla.org/en-US/docs/Learn/HTML/Tables/Basics
* https://developer.mozilla.org/en-US/docs/Learn/HTML/Tables/Advanced