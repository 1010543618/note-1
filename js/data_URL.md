在使用 base64 图片的时候已经看过很多 data URL 了, 这里记录下 data URL 的具体细节. 语法比较简单, BNF 如下:

```
dataurl    := "data:" [ mediatype ] [ ";base64" ] "," data
mediatype  := [ type "/" subtype ] *( ";" parameter )
data       := *urlchar
parameter  := attribute "=" value
```

`urlchar` 即 URL 编码允许的字符.

如果指定 `;base64`, 则 data 部分采用 base64 编码, 如果没有指定 `;base64`, 则 data 使用 ASCII 表示安全 URL 字符范围内的字符, 超出范围的使用 %27 这样的十六进制表示, 即和 URL 编码一样.

如果省略 MIME type, 则 MIME type 默认是 `text/plain;charset=US-ASCII`.

`<a>` 中使用 data URL 有 1024 个字符的限制.

通常来说, 现代浏览器对 data URL 的长度没什么限制, 当然还是要注意可能存在一些应用有长度限制.

data URL 不支持查询字符串(谁会这么用呢...)

FF 59 开始因为安全问题禁止在顶层窗口(top)使用 data URL, 如 `window.open()` `window.location` `a[href]` 以及 302 跳转和 `<meta>` 的刷新等场景.



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/Data_URIs
* https://tools.ietf.org/html/rfc2397
* https://blog.mozilla.org/security/2017/11/27/blocking-top-level-navigations-data-urls-firefox-59/