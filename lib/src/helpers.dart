import 'dart:core';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:elliptic/elliptic.dart';

var zero = BigInt.from(0);
var one = BigInt.from(1);
var two = BigInt.from(2);
var three = BigInt.from(3);
var four = BigInt.from(4);
var five = BigInt.from(5);
var six = BigInt.from(6);
var seven = BigInt.from(7);

List<int> taggedHash(String tag, List<int> msg) {
  var tagHash = sha256.convert(utf8.encode(tag)).bytes;
  return sha256.convert(tagHash + tagHash + msg).bytes;
}

List<int> bigToBytes(BigInt integer) {
  return hex.decode(integer.toRadixString(16));
}

BigInt bigFromBytes(List<int> bytes) {
  return BigInt.parse(hex.encode(bytes), radix: 16);
}
