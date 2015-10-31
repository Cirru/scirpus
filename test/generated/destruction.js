"use strict";

var _slicedToArray = (function () { function sliceIterator(arr, i) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"]) _i["return"](); } finally { if (_d) throw _e; } } return _arr; } return function (arr, i) { if (Array.isArray(arr)) { return arr; } else if (Symbol.iterator in Object(arr)) { return sliceIterator(arr, i); } else { throw new TypeError("Invalid attempt to destructure non-iterable instance"); } }; })();

function _toArray(arr) { return Array.isArray(arr) ? arr : Array.from(arr); }

var _c = c;
var a = _c.a;
var b = _c.b;
var _c2 = c;

var _c3 = _slicedToArray(_c2, 2);

var a = _c3[0];
var b = _c3[1];
var _c4 = c;

var _c5 = _toArray(_c4);

var a = _c5[0];

var b = _c5.slice(1);