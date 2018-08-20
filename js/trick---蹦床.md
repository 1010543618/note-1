我们都知道, 当递归层级过深时, 会导致堆栈溢出(不是栈溢出). 以简单的阶乘为例实现一个递归的函数.

```javascript
function factorial(n) {
	if (n < 2) {
		return 1;
	} else {
		return n * factorial(n - 1);
	}
}
```

对于支持尾递归优化的语言, 我们也可以改写原有函数, 使其变成尾递归形式.

```javascript
var factorial = function () {
	function _factorial(n, m) {
		if (n < 2) {
			return m;
		} else {
			return _factorial(n - 1, m * n);
		}
	}

	return function (n) {
		return _factorial(n, 1);
	}
}();
```

通过引入一个新参数 `m` 累加器来存储我们的中间结果, 减少了递归之外的操作, 使其变成尾递归形式. 但是上面这样能够优化的前提是语言提供了编译器层面的优化, 否则写成尾递归也没什么卵用.

但是我们还可以有另一种技巧, 蹦床, 来实现对尾递归函数的优化, 从而也不会导致堆栈溢出.

```javascript
var factorial = function () {
	function trampoline(res) {
		while (typeof res === 'function') {
			res = res();
		}
		return res;
	}

	function _factorial(n, m) {
		if (n < 2) {
			return m;
		} else {
			return function partial() {
				return _factorial(n - 1, m * n);
			};
		}
	}

	return function (n) {
		return trampoline(_factorial(n, 1));
	}
}();
```

主要细节是三点, 第一点是原函数还是得是尾递归函数. 第二点是我们需要将原函数稍作改造, 使其在递归终止时返回结果值, 其他时候都返回函数, 并且返回的函数执行的结果是原函数原本应当返回的结果, 也即原函数递归的结果. 我们知道返回函数调用的话就会立即执行函数进行计算, 而返回函数则可以做到延迟计算, 而我们需要的正是延迟计算. 第三点是我们需要一个工具函数 `trampoline`, 它接受一个函数, 对函数结果不停地展开直到结果不再是函数而是一个具体值.



#### TODO



#### 参考资料

* https://github.com/getify/You-Dont-Know-JS/blob/1ed-zh-CN/es6%20%26%20beyond/ch7.md
* https://www.cnblogs.com/JeffreyZhao/archive/2009/03/26/tail-recursion-and-continuation.html
* https://www.cnblogs.com/JeffreyZhao/archive/2009/04/01/tail-recursion-explanation.html
* https://zhuanlan.zhihu.com/p/36587160
* https://zhuanlan.zhihu.com/p/20713184
* https://hcoona.github.io/Functional-Programming/tail-recursion-cps-and-recursion-to-loop/
* https://www.zhihu.com/question/20259086
* https://www.zhihu.com/question/27581940
* https://zhuanlan.zhihu.com/p/22721931
* https://segmentfault.com/a/1190000008489245
* https://hcyue.me/2016/02/21/CPS%E5%8F%98%E6%8D%A2%E4%B8%8EJavaScript%E6%B5%81%E7%A8%8B%E6%8E%A7%E5%88%B6/
* https://thzt.github.io/2015/05/23/role-of-cps/
* https://www.zhihu.com/question/28458981
* https://www.zhihu.com/question/24453254