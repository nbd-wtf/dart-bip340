import 'dart:core';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';

List<int> taggedHash(String tag, List<int> msg) {
  var tagHash = sha256.convert(utf8.encode(tag)).bytes;
  return sha256.convert(tagHash + tagHash + msg).bytes;
}

List<int> bigToBytes(BigInt integer) {
  var hexNum = integer.toRadixString(16);
  if (hexNum.length % 2 == 1) {
    hexNum = '0' + hexNum;
  }
  return hex.decode(hexNum);
}

BigInt bigFromBytes(List<int> bytes) {
  return BigInt.parse(hex.encode(bytes), radix: 16);
}
