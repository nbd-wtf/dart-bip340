import 'dart:core';
import 'dart:convert';
import 'package:bip340/src/hex.dart';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/ecc/api.dart';

List<int> taggedHash(String tag, List<int> msg) {
  var tagHash = sha256.convert(utf8.encode(tag)).bytes;
  return sha256.convert(tagHash + tagHash + msg).bytes;
}

List<int> bigToBytes(BigInt integer) {
  return hex.decode(integer.toRadixString(16).padLeft(64, "0"), 0, 64);
}

BigInt bigFromBytes(List<int> bytes) {
  return BigInt.parse(hex.encode(bytes), radix: 16);
}

var secp256k1 = ECDomainParameters("secp256k1");
var curveP = BigInt.parse(
    'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
    radix: 16);

// helper methods:
// liftX returns Y for this X
BigInt liftX(BigInt x) {
  if (x >= curveP) {
    throw new Error();
  }
  var ySq = (x.modPow(BigInt.from(3), curveP) + BigInt.from(7)) % curveP;
  var y = ySq.modPow((curveP + BigInt.one) ~/ BigInt.from(4), curveP);
  if (y.modPow(BigInt.two, curveP) != ySq) {
    throw new Error();
  }
  return y % BigInt.two == BigInt.zero /* even */ ? y : curveP - y;
}

// this one I don't know what it means
BigInt getE(ECPoint P, List<int> rX, List<int> m) {
  return bigFromBytes(
        taggedHash(
          "BIP0340/challenge",
          rX + bigToBytes(P.x!.toBigInteger()!) + m,
        ),
      ) %
      secp256k1.n;
}

ECPoint publicKeyToPoint(String publicKey) {
  // turn public key into a point (we only get y, but we find out the y)
  BigInt x = BigInt.parse(publicKey, radix: 16);
  BigInt y = liftX(x);
  return secp256k1.curve.createPoint(x, y);
}
