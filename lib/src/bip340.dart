import 'dart:core';
import 'dart:math';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:elliptic/elliptic.dart';
import './helpers.dart';

var secp256k1 = EllipticCurve.fromHexes(
  "secp256k1",
  'fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f',
  'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141',
  '0000000000000000000000000000000000000000000000000000000000000007',
  '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798',
  '483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8',
  256,
);

String sign(String privateKey, String message, String aux) {
  var bmessage = utf8.encode(message);
  var baux = hex.decode(aux.padLeft(64, '0'));
  var s = BigInt.parse(privateKey, radix: 16);

  if ((s < one) || (s > (secp256k1.N - one))) {
    throw new Error();
  }

  AffinePoint P =
      secp256k1.scalarBaseMul(hex.decode(privateKey.padLeft(64, '0')));

  BigInt d;
  if (P.Y & one == zero) {
    d = s;
  } else {
    d = secp256k1.N - s;
  }

  if (baux.length != 32) {
    throw new Error();
  }

  var t = d ^ bigFromBytes(taggedHash("BIP0340/aux", baux));

  BigInt k0 = bigFromBytes(
        taggedHash(
          "BIP0340/nonce",
          bigToBytes(t) + bigToBytes(P.X) + bmessage,
        ),
      ) %
      secp256k1.N;

  if (k0.sign == 0) {
    throw new Error();
  }

  AffinePoint R = secp256k1.scalarBaseMul(bigToBytes(k0));

  BigInt k;
  if (R.Y & one == 0) {
    // is even
    k = k0;
  } else {
    k = secp256k1.N - k0;
  }

  var rX = bigToBytes(R.X);

  List<int> signature =
      rX + bigToBytes((k + getE(P, rX, bmessage) + d) % secp256k1.N);

  return hex.encode(signature);
}

BigInt getE(AffinePoint P, List<int> rX, List<int> m) {
  return bigFromBytes(
        taggedHash(
          "BIP0340/challenge",
          rX + bigToBytes(P.X) + m,
        ),
      ) %
      secp256k1.N;
}
