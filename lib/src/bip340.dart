import 'dart:core';
import 'dart:math';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:pointycastle/ecc/api.dart';
import './helpers.dart';

var secp256k1 = ECDomainParameters("secp256k1");

String sign(String privateKey, String message, String aux) {
  List<int> bmessage = hex.decode(message);
  List<int> baux = hex.decode(aux.padLeft(64, '0'));
  BigInt d0 = BigInt.parse(privateKey, radix: 16);

  if ((d0 < BigInt.one) || (d0 > (secp256k1.n - BigInt.one))) {
    throw new Error();
  }

  ECPoint P = secp256k1.G * d0;

  BigInt d;
  if (P.y.toBigInteger() % BigInt.two == BigInt.zero) {
    // even
    d = d0;
  } else {
    d = secp256k1.n - d0;
  }

  if (baux.length != 32) {
    throw new Error();
  }

  var t = d ^ bigFromBytes(taggedHash("BIP0340/aux", baux));

  BigInt k0 = bigFromBytes(
        taggedHash(
          "BIP0340/nonce",
          bigToBytes(t) + bigToBytes(P.x.toBigInteger()) + bmessage,
        ),
      ) %
      secp256k1.n;

  if (k0.sign == 0) {
    throw new Error();
  }

  var R = secp256k1.G * k0;

  BigInt k;
  if (R.y.toBigInteger() % BigInt.two == BigInt.zero) {
    // is even
    k = k0;
  } else {
    k = secp256k1.n - k0;
  }

  var rX = bigToBytes(R.x.toBigInteger());
  var e = getE(P, rX, bmessage);

  List<int> signature = rX + bigToBytes((k + e * d) % secp256k1.n);

  return hex.encode(signature);
}

BigInt getE(ECPoint P, List<int> rX, List<int> m) {
  return bigFromBytes(
        taggedHash(
          "BIP0340/challenge",
          rX + bigToBytes(P.x.toBigInteger()) + m,
        ),
      ) %
      secp256k1.n;
}
