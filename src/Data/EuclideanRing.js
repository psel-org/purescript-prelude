"use strict";

exports.intDegree = function (x) {
  return Math.min(Math.abs(x), 2147483647);
};

// See the Euclidean definition in
// https://en.m.wikipedia.org/wiki/Modulo_operation.
exports.intDiv = function (x) {
  return function (y) {
    return y > 0 ? Math.floor(x / y) : -Math.floor(x / -y);
  };
};

exports.quot = function (x) {
  return function (y) {
    /* jshint bitwise: false */
    return x / y | 0;
  };
};

exports.intMod = function (x) {
  return function (y) {
    var yy = Math.abs(y);
    return ((x % yy) + yy) % yy;
  };
};

exports.rem = function (x) {
  return function (y) {
    return x % y;
  };
};

exports.numDiv = function (n1) {
  return function (n2) {
    return n1 / n2;
  };
};
