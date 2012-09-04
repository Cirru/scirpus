
### Scirpus: small Lisp-like language that compiles to JS but with less brackets

#### Introduction

I hate brakets(which start but end in another line or looks like `))))`).
Indentations feels better while writing coding.
So I had a look a `LispyScript`'s code and had a try:
https://github.com/santoshrajan/lispyscript/blob/master/lib/ls.js
Some old trial could be found under the `Cirru` tag:
https://github.com/jiyinyiyong/cirru-editor/tree/47409b6ff88fcde53d2409eafe2c5d19cf1ae9fc/compile
You may browser examples in `source/` directory.
It's not completed, code will be printed after command `node-dev index.coffee`.
By now it's only a demo. I will improve it as I learn nice skills.

#### 说明

现在很多语言括号用滥, 反而缩进语法被排斥, 当然原因是有的,
可想想技术界的大神们能去关心各种问题, 恐怕很少会花费在打磨语法上边.
于是我们这些苛求于美观的菜鸟必须学会自己去打磨了.
就像设计网页的不能接受 HTML/CSS 一些难受的语法和布局方式这样.

原本我打算在 Cirru 的编辑器里把代码完成, 这样就不用解析了,
可是从现在的技术我恐怕真做不到, 至少在 HTML 上尝试我碰到难题了.
或者如果 Sublime 的插件写得好得话我能做出更好的效果..
随它啦, 因为突然学会了简单的文本解析, 特殊字符转义的难题就克服了, 于是有了这个

`Scirpus` 的名字是@日青网 微博里翻植物看到的, 我当时想低调.
这个词总让我想起 `Cirru` 和 `Script` 两个词, 所以不错吧

现在的代码只能做个 demo, 因为 JS 比较无聊的 `;` 和 `()` 难以安全
我转译的代码当中遇到过这类问题, 让我无法安心写下去
如果能用 Mozilla 文档里的 Parser API 做个好点的就好了
现在一切对我来说都很生疏, 希望一切会好起来吧
