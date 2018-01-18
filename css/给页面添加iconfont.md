首先, 给页面引入字体文件

```css
@font-face {
  font-family: 'myfont';
  src: url('fonts/cicle_fina-webfont.eot');
  src: url('fonts/cicle_fina-webfont.eot?#iefix') format('embedded-opentype'),
         url('fonts/cicle_fina-webfont.woff2') format('woff2'),
         url('fonts/cicle_fina-webfont.woff') format('woff'),
         url('fonts/cicle_fina-webfont.ttf') format('truetype'),
         url('fonts/cicle_fina-webfont.svg#myfont') format('svg');
  font-weight: normal;
  font-style: normal;
}
```



然后主要有两种使用形式



#### HTML 文本内容形式

定义一个 class

```css
.icon {
  font-family: 'myfont';
  font-style: normal;
  font-weight: normal;
}
```

使用方式

```html
<i class="icon">&#xf048;</i>
```



#### i 标签伪元素形式

定义一下 `<i>` 的默认样式

```css
i {
  /* use !important to prevent issues with browser extensions that change fonts */
  font-family: 'myfont' !important;
  speak: none;
  font-style: normal;
  font-weight: normal;
  font-variant: normal;
  text-transform: none;
  line-height: 1;

  /* Better Font Rendering =========== */
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.icon-wechat:before {
  content: "\e900";
}
```

使用方式

```html
<i class="icon-wechat"></i>
```



