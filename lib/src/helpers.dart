import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:elliptic/elliptic.dart';

List<int> taggedHash(String tag, List<int> msg) {
  tagHash = sha256.convert(utf8.encode(tag)).bytes();
  return sha256.convert(tagHash + tagHash + msg).bytes();
}

List<int> bigToBytes(BigInt integer) {
  return hex.decode(integer.toRadixString(16));
}

BigInt bigFromBytes(List<int> bytes) {
  return BigInt.parse(hex.encode(bytes), 16);
}
