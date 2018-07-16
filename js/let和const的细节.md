* `let` `const` 声明的变量都只存在于最近的块级作用域

* `let` `const` 都存在着临时死区的概念

* 不严谨地定义临时死区为 `let` `const` 声明的位置到最近的块级作用域顶部, 即如下

  ```javascript
  function test() {
      // ...
      let a = 1;
  }
  ```

  则从 `test` 的那一行到 `let a = 1` 那一行(包括)之间都可以看作是临时死区, 在临时死区中试图访问 `let` `const` 声明的变量会抛出异常.

  ```javascript
  console.log(a); // error
  let a = 1;
  // or
  var a = 1;
  if (true) {
      let a = a + 1; // error, 因为存在着局部作用域的遮蔽, 这里 a + 1 的 a 不会是外部的 a, 所以还是相当于在临时死区中访问 let 声明的 a
      // 其实相当于 let a 还是存在于整个块级作用域, 只是在声明之前你不能访问, 而不是在还未声明的时候就使用外部的 a
  }
  // or
  var o = {};
  for (let o of o.a) { // error, 原因和上面一样
      //...
  }
  // or
  typeof a === 'undefined'; // error, 即使是 typeof 也不行
  let a = 1;
  // or
  console.log(a); // ok, 临时死区只存在于下面的块级作用域中, 这里不是临时死区
  {
      let a = 1;
  }
  ```

* 禁止在同一块级作用域中使用 `let` `const` 重声明

  ```javascript
  var a = 1;
  var a = 2; // ok
  
  let b = 1;
  let b = 2; // error
  ```

* 全局作用域中 `let` `const` 声明的变量不会为全局对象创建属性.

  ```javascript
  var a = 1;
  window.a; // 1
  let b = 2;
  window.b; // undefined
  ```

* `const` 声明的变量相当于指针常量 `int * const a` 而不是常量指针 `const int * a`

* `const` 在 `for...in` `for...of` 中的行为和 `let` 一致, 在 `for` 中只要你不去改它也没什么问题