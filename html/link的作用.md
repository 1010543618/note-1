虽然已经写过这么多 CSS, 按理应该很熟悉这个标签, 不过仔细想想其实自己连 `rel` 到底可以有哪些值都不知道, 所以还是特地抽空查了下.

首先 `link` 标签可以出现的位置基本等同于 `meta`, 并且也支持通用属性([global attributes](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes)). 以下是 link 支持的属性:

* `href` 这个应该是最重要的了, 基本上每个 `link` 标签都会有, 指定链接的资源 URL.

* `rel` 表明 `link` 指向的资源(`href` 所指的资源)和当前页面之间的关系, 可以有多个值, 它们之间用空格分隔, 具体支持的值可以参考 https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types, `a` 标签也支持这个属性, 以下列几个常用的

  * `stylesheet` 表明 `link` 指向的资源是一个样式表, 如果 `link` 没有指定 `type` 属性, 浏览器默认 `text/css`, 如果和 `alternate` 一起用, 则意味着这是一个[可选的样式表[1]](https://developer.mozilla.org/en-US/docs/Web/CSS/Alternative_style_sheets), 这种时候 `title` 属性必须存在且不为空.

    ```HTML
    <link href="test.css" rel="alternate stylesheet" type="text/css" title="test"/>
    ```

  * `alternate` 和 `stylesheet` 配合使用的时候表明资源是一个可选的样式表, 其他情况参考 MDN.

  * `manifest` 表明 `link` 的资源是一个 [manifest 文件](https://developer.mozilla.org/en-US/docs/Web/Manifest)

  * `icon` 指定页面 tab 栏的 icon, 你可以声明多个 rel 为 icon 的 `link` 标签, 但是浏览器通常会将 DOM 树中的最后一个作为 icon, 或者会根据情况(比如屏幕分辨率)选择合适的那个. iOS 不使用 `rel="icon"`, 而是用非标准的 `apple-touch-icon` 和 `apple-touch-startup-image`, eg.

    ```HTML
    <link href="test.png" rel="icon" />
    <link href="test.png" rel="icon" sizes="72x72" />
    <link href="test.png" rel="apple-touch-icon" sizes="72x72" />
    ```

  * `dns-prefetch` 实验性的值, 提示浏览器提前对 `link` 的资源进行 DNS 查找.

  * `prefetch` 建议浏览器提前下载 `link` 的资源, TODO

  * `preload` 告诉浏览器下载 `link` 的资源(和 prefetch 的区别?), TODO

* `type` 指定了资源的 MIME type, 通常就用来指定 CSS 文件的 MIME type, `rel="preload"` 的时候也会用它来确保浏览器只下载它支持的资源.

* `crossorigin` 该属性指定在获取 `link` 的资源的时候是否必须使用 CORS, 不带此属性获取资源的请求不会带有 `Origin` 头部, 带该属性的 `link` 获取资源的时候请求会带 `Origin`. 使用该属性获取图片资源时, 图片可以被复用在 Canvas 中而不会[污染 Canvas](https://developer.mozilla.org/en-US/docs/Web/HTML/CORS_Enabled_Image). 支持以下值:

  * `anonymous` 请求不带凭据(eg. cookie, HTTP basic authentication), 如果服务器没有响应 `Access-Control-Allow-Origin`, 则图片资源会污染 Canvas.
  * `use-credentials` 请求带凭据, 其他同上

* `media` 媒体查询, 通常和 `rel="stylesheet"` 配合使用, 根据设备指定合适的样式表, 具体参考[媒体查询](https://developer.mozilla.org/en-US/docs/Web/CSS/Media_Queries/Using_media_queries)

* `sizes` 只和 `rel="icon"` 配合使用, 值可以是 `any`(当 icon 是 svg 等矢量图的时候), 或者 `sizes="32x32"` 指定具体大小.

* `title` 虽然 title 是一个通用属性, 不过在 `link` 里有特殊意义, 用来定义可选的样式表, 所以在 `link` 中乱用这个属性可能导致样式表失效.

* `hreflang` 指定链接资源的语言, 仅当有 `href` 时有用, 目测没什么卵用.

* `as` ???

* `disabled` 非标准 API, 禁用 `link` 的 `rel`, 没事别用, 要用可以用 js dom 对象的 `disabled` 属性.

* `methods` 非标准 API, ???

* `prefetch` 非标准 API, 看起来和 `rel` 的 `prefetch` 差不多?

* `referrerpolicy` 实验性 API, 指定请求资源的时候应该带有哪些 referrer 相关的头部. 具体参考 MDN.



### 补充说明

1. 可选的样式表, 基本上就是一个给用户换主题的样式, 一些浏览器如 FF 有菜单可以让用户在多个可选样式表中切换, 目测没什么卵用



### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/HTML/Element/link
* https://developer.mozilla.org/en-US/docs/Web/HTML/Link_types
* https://developer.mozilla.org/en-US/docs/Web/HTML/CORS_Enabled_Image
* https://developer.mozilla.org/en-US/docs/Web/HTML/CORS_settings_attributes
* https://developer.mozilla.org/en-US/docs/Web/HTML/Preloading_content
* https://developer.apple.com/library/content/documentation/AppleApplications/Reference/SafariWebContent/ConfiguringWebApplications/ConfiguringWebApplications.html#//apple_ref/doc/uid/TP40002051-CH3-SW4
* https://developer.mozilla.org/en-US/docs/Web/Manifest