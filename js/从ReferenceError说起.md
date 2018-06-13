很多时候, 我们常常这样来判断一个变量是否存在.

```javascript
if (a) {
    // do sth
}
```

但不得不说, 这不是一个好的实践. 有人会说, 我知道, a 可能是 0, 而 0 不意味着不存在. 的确, 不过还有另一方面原因, 很多时候直接这样判断会出现 ReferenceError 的错误.

不是说好未定义的变量都是 undefined 的吗? 为什么会报错呢? 简而言之, 规范如此, 当然事实上应该不叫未定义, 我们应当区分未声明和未初始化. 当环境记录(Environment Record)中找不到这个变量时, 就会抛出这个错误. 当然, 还有其他情况也会报这个错误.

所以好的做法是用 `typeof`.

```javascript
if (typeof a === 'undefined') {
    // do sth
}
```

那为什么 `typeof` 不会报错呢? 答案还是规范如此...

不过如果自己确信变量被声明了, 并且变量不会是数字, 那前面的做法也是可以的, 但是这无疑增加自己心智负担. 另外, 对于非数值类型的对象属性, 这样判断倒也 OK.

```javascript
if (a.b) {
    // do sth
}
```

但是 ES6 多了 `let` `const`, 对于通过 `let` `const` 声明的变量, 在声明之前使用 `typeof` 还是会报 ReferenceError. eg.

```javascript
typeof a; // ReferenceError
let a = 2;
```





#### 参考资料

* https://tc39.github.io/ecma262/#sec-getvalue
* https://tc39.github.io/ecma262/#sec-declarative-environment-records-getbindingvalue-n-s
* https://tc39.github.io/ecma262/#sec-typeof-operator