在移动端, 如果我们按住一个 `<a>` 会弹出一个默认菜单, 提供了诸如新标签打开, 复制链接地址等功能. 假如希望禁止弹出这个菜单的话, 可以使用私有属性 `-webkit-touch-callout`.

属性只有一个有用的值, 那就是 `none`, 默认值是 `default`.

eg.

```css
-webkit-touch-callout: none;
-webkit-touch-callout: default;
```

不过这个属性只对 iOS 有用, Android 下还是可以弹出菜单.



#### 参考资料

* https://developer.mozilla.org/en-US/docs/Web/CSS/-webkit-touch-callout
* https://developer.apple.com/library/content/documentation/AppleApplications/Reference/SafariCSSRef/Articles/StandardCSSProperties.html#//apple_ref/doc/uid/TP30001266-_webkit_touch_callout