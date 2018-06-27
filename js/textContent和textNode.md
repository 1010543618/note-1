其实这两个 API 都很常用, 这里主要记录下它们的区别.

* 它们都是 `Node` 类的属性, 我们通过 `Node.textContent` 来拿到 `textContent`, 通过 `Node.firstChild` `Node.lastChild` `Node.childNodes` 等来拿到一个 `textNode`

* 对于创建和修改, `textContent` 直接设置字符串就好, eg.

  ```javascript
  // <div id="test"></div>
  var div = document.getElementById('test');
  div.textContent = 'test';
  // <div id="test">test</div>
  div.textContent = 'test1';
  // <div id="test">test1</div>
  ```

  而创建 `textNode` 只能通过 `document.createTextNode()`, eg.

  ```javascript
  // <div id="test"></div>
  var div = document.getElementById('test');
  var text = document.createTextNode('test');
  div.appendChild(text);
  // <div id="test">test</div>
  ```

  而修改 `textNode` 则是通过 `Node.nodeValue`/`Node.data` 或 `Node.textContent` 以及 `textNode.appendData()`/`textNode.deleteData()`/`textNode.insertData()`/`textNode.replaceData()`/`textNode.splitText()`, 其中 `nodeValue` 和 `data` 是等价的, eg.

  ```javascript
  var div = document.getElementById('test');
  var text = document.createTextNode('test');
  div.appendChild(text);
  text.nodeValue = 'test1';
  // <div id="test">test1</div>
  text.textContent = 'test2';
  // <div id="test">test2</div>
  ```

* 它们都不能被用来创建元素, 会经过 HTML 编码, 不像 `innerHTML`, 即

  ```javascript
  // <div id="test"></div>
  var div = document.getElementById('test');
  div.textContent = '<div>test</div>';
  // <div id="test">&lt;div&gt;test&lt;/div&gt;</div>
  
  // 或
  // <div id="test"></div>
  var div = document.getElementById('test');
  var text = document.createTextNode('<div>test</div>');
  div.appendChild(text);
  // <div id="test">&lt;div&gt;test&lt;/div&gt;</div>
  ```

* 每个元素的 `textContent` 只有一个, 而 `textNode` 可以有多个, eg.

  ```javascript
  // <div id="test"></div>
  var div = document.getElementById('test');
  var aaa = document.createTextNode('aaa');
  var bbb = document.createTextNode('bbb');
  var ccc = document.createTextNode('ccc');
  var ddd = document.createTextNode('ddd');
  div.appendChild(aaa);
  div.appendChild(bbb);
  div.appendChild(ccc);
  div.appendChild(ddd);
  // <div id="test">aaabbbcccddd</div>
  
  // <div id="test"></div>
  var div = document.getElementById('test');
  div.textContent = 'aaabbbcccddd';
  // <div id="test">aaabbbcccddd</div>
  ```

  虽然它们看上去是一样的, 然而前者的 `div.childNode.length` 是 4, 后者是 1. 所以并不是说只有文本就只有一个 `textNode`.

* 每种节点都有 `textContent`, 而只有元素和属性节点有 `textNode`, 所以即便是 `textNode` 也会包含一个 `textContent` 属性, 这也是为什么不仅仅可以用 `Node.nodeValue` 来修改 `textNode`, 也可以用 `textContent` 来修改 `textNode` 的原因, 至于其他节点的 `textContent` 能够拿到什么, 比如 CDATA 和 HTML 注释, 它可以返回其中的内容, 具体参考 [MDN](https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent)

* `textContent` 要 IE9 才支持, `textNode` 几乎都支持

* 它们都可以作为 `<script>` `<style>` 的内容, 并且可以生效. eg.

  ```javascript
  var css = document.getElementsByTagName('style')[0];
  var text = document.createTextNode('#test {width: 50px; height: 50px; background: red;}');
  css.appendChild(text);
  
  // 或
  var css = document.getElementsByTagName('style')[0];
  css.textContent = '#test {width: 50px; height: 50px; background: red;}';
  ```

* `textContent` 和 `textNode` 的内容都不会被当作 HTML 处理, 即会被转义, 而 `innerHTML` 的内容则会被当作 HTML, 从而修改 DOM(不过基于安全原因, 脚本例外, 不会被执行)

* 基于以上几点, 我们可以知道的是, 不能指望用 `textContent` 或者 `textNode` 创建一个 `<script>` 并执行它, 但是如果已经有一个创建好的 `<script>` 节点, 可以通过它们设置 `<script>` 的内容, 这样是可以执行的. 另外通过它们修改已有脚本的内容, 也不会触发脚本重新执行. 但是通过它们修改已有的 CSS, 则可以触发重新渲染, 新样式生效. 即

  ```javascript
  var div = document.getElementById('test');
  div.textContent = '<script>console.log("xss")<\/script>';
  // 不执行, 只是完全显示出来
  
  var div = document.getElementById('test');
  var text = document.createTextNode('<script>console.log("xss")<\/script>');
  div.appendChild(text);
  // 不执行, 只是完全显示出来
  ```

* 另一方面是, `innerHTML` 可以拿到完整的 HTML 内容, 而 `textContent` 只能拿到除去标签的文本, 而 `textNode` 只能拿到最多和 `textContent` 一样的文本(如果一个元素中有多个 `textNode` 则只能拿到一个文本节点的文本), 比如

  ```javascript
  //<div id="test">
  //	<div>test</div>
  //	<div>test</div>
  //</div>
  var div = document.getElementById('test');
  console.log(div.innerHTML);
  // <div>test</div>
  // <div>test</div>
  console.log(div.textContent);
  // test
  // test
  console.log(div.firstChild);
  // div 之间的空白符
  ```

* 如果要修改的元素中只有文本内容, 建议用 `textContent`, 简单方便安全, 虽然 `innerHTML` 也可以, 但是它不转义元素, 以及它的内容要经过 HTML parser, 效率低些, 而 `textNode` 比较麻烦, 且容易出错, 如果元素中不止一个 `textNode` 的话.



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent
* https://developer.mozilla.org/en-US/docs/Web/API/Document/createTextNode
* https://developer.mozilla.org/en-US/docs/Web/API/Element/innerHTML