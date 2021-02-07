import 'dart:math';
import 'package:elliptic/elliptic.dart';

var secp256k1 = EllipticCurve.fromHexes(
  "secp256k1",
  'fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f',
  '0000000000000000000000000000000000000000000000000000000000000007',
  'fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141',
  '79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798',
  '483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8',
  256,
);

class Point {
  BigInt x, y;

  Point(this.x, this.y);
}

var zero = BigInt.from(0);
var one = BigInt.from(1);
var two = BigInt.from(2);
var three = BigInt.from(3);
var four = BigInt.from(4);
var five = BigInt.from(5);
var six = BigInt.from(6);
var seven = BigInt.from(7);
var n2 = secp256k1.n - 2;

BigInt hex2Big(String string, {radix = 16}) {
  return BigInt.parse(string, radix: radix);
}

Point big2Point(BigInt n) {
  return hex2Point(n.toRadixString(16));
}

Point hex2Point(String hex) {
  final len = 64;
  if (hex.length != len) {
    throw ('point length must be ${len}!');
  }

  var firstByte = 2;

  // The curve equation for secp256k1 is: y^2 = x^3 + 7.
  var x = BigInt.parse(hex, radix: 16);

  var ySqared =
      ((x.modPow(BigInt.from(3), secp256k1.p)) + BigInt.from(7)) % secp256k1.p;

  // power = (p+1) // 4
  var p1 = secp256k1.p + BigInt.from(1); // p+1
  var power = (p1 - p1 % BigInt.from(4)) ~/ BigInt.from(4);
  var y = ySqared.modPow(power, secp256k1.p);

  var sq = y.pow(2) % secp256k1.p;
  if (sq != ySqared) {
    throw ('failed to retrieve y of public key from hex');
  }

  var firstBit = (y & BigInt.one).toInt();
  if (firstBit != (firstByte & 1)) {
    y = secp256k1.p - y;
  }

  return new Point(
    x,
    y,
  );
}

String point2Hex(Point point) {
  return point.x.toRadixString(16).padLeft(64, '0');
}
