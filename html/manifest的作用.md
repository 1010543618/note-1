manifest 是一个 json 文件, 提供了 Web App 的一些信息(如 icon, 描述, 作者等). manifest 是 [PWA](https://developer.mozilla.org/en-US/Apps/Progressive) 的一部分.



### 部署

引入一个 manifest 文件只需要 `link` 标签

```HTML
<link rel="manifest" href="manifest.json" />
```



### 示例

```json
{
  "name": "HackerWeb",
  "short_name": "HackerWeb",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#fff",
  "description": "A simply readable Hacker News app.",
  "icons": [{
    "src": "images/touch/homescreen48.png",
    "sizes": "48x48",
    "type": "image/png"
  }, {
    "src": "images/touch/homescreen72.png",
    "sizes": "72x72",
    "type": "image/png"
  }, {
    "src": "images/touch/homescreen96.png",
    "sizes": "96x96",
    "type": "image/png"
  }, {
    "src": "images/touch/homescreen144.png",
    "sizes": "144x144",
    "type": "image/png"
  }, {
    "src": "images/touch/homescreen168.png",
    "sizes": "168x168",
    "type": "image/png"
  }, {
    "src": "images/touch/homescreen192.png",
    "sizes": "192x192",
    "type": "image/png"
  }],
  "related_applications": [{
    "platform": "web"
  }, {
    "platform": "play",
    "url": "https://play.google.com/store/apps/details?id=cheeaun.hackerweb"
  }]
}
```



### 字段

* `background_color` **String**, 声明应用的背景色, 在应用启动之前使用(比如启动页), CSS 中也能定义应用的背景色, 但是是在应用启动之后被使用. 简单说就是下载 manifest 比较快, 进入启动页先用该属性定义的颜色, 等所有资源下载好, 背景色就由 CSS 来决定. 这样可以提供更好的体验
* `description` **String**, 应用的描述
* `dir ` **String**, 指定应用名/应用描述的文本方向, 类似 CSS 的 `direction` 属性
* `display` **String**, 应用的显示模式, 如全屏, 具体参考 MDN
* `icons` **Array(Object)**, 指定应用的图标, 具体参考 MDN
* `lang` **String**, 指定 `name` 和 `short_name` 值的语言, 具体参考 MDN
* `name` **String**, 应用名
* `orientation` **String**, 应用的显示方向, 横屏/竖屏等, 具体参考 MDN
* `prefer_related_applications` **Boolean**, 具体参考 MDN
* `related_applications` **Array(Object)**, 具体参考 MDN
* `scope` **String**, 具体参考 MDN
* `short_name` **String**, 应用的短名称, 在长度不够显示 `name` 时有用
* `start_url`  **String**, 具体参考 MDN
* `theme_color` **String**, 主题颜色, 具体参考 MDN



### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/Manifest