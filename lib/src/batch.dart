import 'dart:core';
import 'dart:math';
import 'package:pointycastle/ecc/api.dart';
import './helpers.dart';
import './hex.dart';

/// Verifies a bunch of schnorr signatures at the same time for speed gains.
bool batchVerify(
  final List<ECPoint> pubkeys,
  List<String> messages,
  List<String> signatures,
) {
  final P = pubkeys[0];
  BigInt e =
      getE(P, hex.decode(signatures[0], 0, 64), hex.decode(messages[0], 0, 64));
  final R = publicKeyToPoint(signatures[0].substring(0, 64));

  BigInt leftSide = BigInt.zero;
  List<ECPoint> rightSideTerms = List.filled(pubkeys.length * 2, R);
  rightSideTerms[1] = (P * e)!;

  final random = Random.secure();

  for (var i = 1; i < pubkeys.length; i++) {
    final P = pubkeys[i];
    final s_num = BigInt.parse(signatures[i].substring(64, 128), radix: 16);
    BigInt e = getE(
        P, hex.decode(signatures[i], 0, 64), hex.decode(messages[i], 0, 64));
    final R = publicKeyToPoint(signatures[i].substring(0, 64));

    final a = BigInt.from(random.nextInt(4294967296));

    leftSide += a * s_num;
    rightSideTerms[i * 2] = (R * a)!;
    rightSideTerms[i * 2 + 1] = ((P * a)! * e)!;
  }

  final rightSide = rightSideTerms.reduce((a, b) => (a + b)!);

  return secp256k1.G * leftSide == rightSide;
}
