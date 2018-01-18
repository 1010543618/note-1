通常我们给页面的标签栏加上 icon 都是用这样的方式:

```HTML
<link rel="shortcut icon" href="test.png" />
```

不过仔细读了下 `link` 相关的资料发现还是有些细节需要注意

首先 `shortcut` 这个值不是标准的 `rel` 支持的值, 所以不应该再继续使用了(**不过 IE8 还是需要这个值**), 另外我们可以给图标指定一个大小 `sizes`

```HTML
<link rel="icon" sizes="32x32" href="test.png" />
```

并且可以有多个这样的 `link` 标签, 这样浏览器会根据 `link` 的 `media`, `type`, `size` 属性来选择一个合适的图标, 如果有多个符合条件的图标, 浏览器会选择 DOM 树中最后一个. 所以正确的写法是

```html
<link rel="icon" sizes="32x32" href="test.png" />
```



那对于 icon 的`link`, 我们需要指定 `type` 属性吗? 其实是可以有的, 不过浏览器也只是作为参考, 所以也可以不加, 对于 .ico 的文件, MIME type 是 image/x-icon, 对于 .png 图片, 则是 image/png.

```html
<link rel="icon" sizes="32x32" type="image/x-icon" href="test.ico" />
<link rel="icon" sizes="32x32" type="image/png" href="test.png" />
```

IE9 和 IE10 要求必须要加 `type` 属性.



但是这就完了吗?

坑爹的水果告诉它不支持 `rel="icon"` 这样的写法, 而是由它自己的非标准的值 `apple-touch-icon`, 所以在水果机上应该这么写

```html
<link rel="apple-touch-icon" href="test.png" />
```

当然它也支持 `sizes` 属性, 水果家给出了一份针对不同设备的 icon 尺寸

```html
<link rel="apple-touch-icon" href="touch-icon-iphone.png">
<link rel="apple-touch-icon" sizes="152x152" href="touch-icon-ipad.png">
<link rel="apple-touch-icon" sizes="180x180" href="touch-icon-iphone-retina.png">
<link rel="apple-touch-icon" sizes="167x167" href="touch-icon-ipad-retina.png">
```

如果 `link` 给出的 icon 不匹配设备的推荐尺寸, 那么浏览器会选择最接近推荐尺寸但是比推荐尺寸稍大的 icon. 如果没有比推荐尺寸大的 icon, 则选择最大的那个 icon.

如果没有用 `link` 指定 icon, 浏览器会从网站根目录寻找 **apple-touch-icon...** 开头的图标, 比如根目录下有 `apple-touch-icon-80x80.png`, `apple-touch-icon.png`, 设备推荐尺寸是 58x58, 则会按照下面的优先级使用图标:

1. apple-touch-icon-80x80.png
2. apple-touch-icon.png





所以总结一下, 在不需要支持 IE11 以下的 PC 端, 我们只需要这样的就行

```html
<link rel="icon" sizes="32x32" href="test.png" />
```

如果需要支持 IE11 以下

```html
<link rel="shortcut icon" sizes="32x32" type="image/png" href="test.png" />
```

在移动端, 则是

```html
<link rel="icon" sizes="32x32" href="test.png" />
<link rel="apple-touch-icon" href="touch-icon-iphone.png">
<link rel="apple-touch-icon" sizes="152x152" href="touch-icon-ipad.png">
<link rel="apple-touch-icon" sizes="180x180" href="touch-icon-iphone-retina.png">
<link rel="apple-touch-icon" sizes="167x167" href="touch-icon-ipad-retina.png">
```



### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link
* https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types
* https://bitsofco.de/all-about-favicons-and-touch-icons/
* https://github.com/audreyr/favicon-cheat-sheet
* http://blog.csdn.net/freshlover/article/details/9310437
* https://developer.apple.com/library/content/documentation/AppleApplications/Reference/SafariWebContent/ConfiguringWebApplications/ConfiguringWebApplications.html#//apple_ref/doc/uid/TP40002051-CH3-SW4
* https://developer.apple.com/ios/human-interface-guidelines/icons-and-images/app-icon/