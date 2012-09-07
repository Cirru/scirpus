a = 1;
a += 2;
a *= 3;
a *= 4;
a *= 5;
a + 6;
b = a + 7;
a < b;
1 < a && a < b && b < 100;
list = [
  1,
  2,
  3,
  4,
  5
];
len = list['length'];
str = list['join'](',')['split']();
str2 = list.join(',');
({
  a: 1,
  b: 2,
  c: {
    a: 5
  },
  d: {
    a: 1,
    b: [
      1,
      2,
      3,
      4
    ]
  }
});
f1 = function () {
  1;
};
f2 = function (x) {
  x;
};
f3 = function (x) {
  return x;
};
f4 = function (x, y) {
  return x + y;
};
4 > 2 && 5 > 4 && 4 > 6;
if (4 > 3 && 2 < 3) {
  show('right');
}
if (4 > 3 && 2 < 3) {
  show('right');
} else {
  show('wrong');
}
x = 'a " b c / d / \' e';
x = 'a \' b c / d / " e';
x = /a \' b c \/ d \/ \" e/;
show(typeof show);
undefined;
true;
show(null);
f5 = function (x) {
  show(x);
  show(x + 1);
  show(x);
  return x;
};
show(true);
a = 'bug of js show(true)(function...)';
(function (x) {
  return x;
}['call']());
a = 3;
while (a < 100) {
  show(a);
  show('line');
}
try {
  show('try');
} catch (err) {
  show(xx);
}
switch (1 + 2) {
case 1:
  'one';
  break;
case 2:
  'two';
  break;
case 3:
  'three';
  break;
default:
  'else';
}
for (key in obj) {
  value = obj[key];
  show(key, value);
}
for (index in list) {
  value = list[index];
  show(index, value);
}
for (xx in oo) {
  show(xx);
}
obj[method]()[attr][func](para);
obj['log'];
list.slice(start, end);