关于这方面内容也没什么好讲, 已经很熟悉了, 就贴个模板吧, 至于为什么模板要这么写, 那他妈都是历史原因了, 终有一天你不需要知道这些原因甚至不需要这个模板了

```css
@font-face {
  font-family: 'myfont';
  font-weight: normal;
  font-style: normal;
  src: url('fonts/cicle_fina-webfont.eot');
  src: url('fonts/cicle_fina-webfont.eot?#iefix') format('embedded-opentype'),
         url('fonts/cicle_fina-webfont.woff2') format('woff2'),
         url('fonts/cicle_fina-webfont.woff') format('woff'),
         url('fonts/cicle_fina-webfont.ttf') format('truetype'),
         url('fonts/cicle_fina-webfont.svg#myfont') format('svg');
}
```

不过后端记得给所有字体文件设置 CORS, 因为有些浏览器会要求字体遵循同源策略, 否则字体无法加载.



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Learn/CSS/Styling_text/Web_fonts
* https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face
* https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/webfont-optimization
* https://drafts.csswg.org/css-fonts/#font-fetching-requirements
* https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy
* https://bugzilla.mozilla.org/show_bug.cgi?id=604421

