import 'dart:math';
import 'package:convert/convert.dart';
import 'package:elliptic/elliptic.dart';
import './secp256k1.dart';
import './helpers.dart';

String sign(BigInt privateKey, String message, String aux) {
  bmessage = hex.decode(message);
  baux = hex.decode(aux);

  if ((privateKey < 1) || (privateKey > (secp256k1.n - one))) {
    throw new Error("the private key must be an integer in the range 1..n-1");
  }

  P = secp256k1.scalarBaseMul(bigToBytes(privateKey));

  BigInt d;
  if (P.Y & one == zero) {
    d = privateKey;
  } else {
    d = secp256k1.n - privateKey;
  }

  BigInt k0;
  if (baux.length != 32) {
    throw new Error("aux must be 32 bytes!");
  }

  t = d ^ taggedHash("BIP0340/aux", aux);

  k0 = bigFromBytes(
        taggedHash(
          "BIP0340/nonce",
          bigToBytes(t) + bigToBytes(P.X) + bmessage,
        ),
      ) %
      secp2561.n;

  if (k0.sign == 0) {
    throw new Error("k0 is zero");
  }

  R = secp256k1.scalarBaseMul(bigToBytes(k0));

  BigInt k;
  if (R.Y & one == 0) {
    // is even
    k = k0;
  } else {
    k = secp256k1.n - k0;
  }

  rX = bigToBytes(R.X);

  List<int> signature =
      rx + bigToBytes((k + getE(P, rx, message) + d) % secp256k1.n);

  return hex.encode(signature);
}

BigInt getE(AffinePoint P, List<int> rX, List<int> m) {
  return bigFromBytes(
        taggedHash(
          "BIP0340/challenge",
          rx + bigToBytes(P.X) + m,
        ),
      ) %
      secp256k1.n;
}
