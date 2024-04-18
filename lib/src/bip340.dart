import 'dart:core';
import 'package:pointycastle/ecc/api.dart';
import './helpers.dart';
import './hex.dart';

/// Generates a schnorr signature using the BIP-340 scheme.
///
/// privateKey must be 32-bytes hex-encoded, i.e., 64 characters.
/// message must also be 32-bytes hex-encoded (a hash of the _actual_ message).
/// aux must be 32-bytes random bytes, generated at signature time.
/// It returns the signature as a string of 64 bytes hex-encoded, i.e., 128 characters.
/// For more information on BIP-340 see bips.xyz/340.
String sign(String privateKey, String message, String aux) {
  final List<int> bmessage = hex.decode(message, 0, 64);
  final List<int> baux = hex.decode(aux.padLeft(64, '0'), 0, 64);
  final BigInt d0 = BigInt.parse(privateKey, radix: 16);

  if ((d0 < BigInt.one) || (d0 > (secp256k1.n - BigInt.one))) {
    throw new Error();
  }

  final ECPoint P = (secp256k1.G * d0)!;

  BigInt d;
  if (P.y!.toBigInteger()! % BigInt.two == BigInt.zero) {
    // even
    d = d0;
  } else {
    d = secp256k1.n - d0;
  }

  if (baux.length != 32) {
    throw new Error();
  }

  final t = d ^ bigFromBytes(taggedHash("BIP0340/aux", baux));

  final BigInt k0 = bigFromBytes(
        taggedHash(
          "BIP0340/nonce",
          bigToBytes(t) + bigToBytes(P.x!.toBigInteger()!) + bmessage,
        ),
      ) %
      secp256k1.n;

  if (k0.sign == 0) {
    throw new Error();
  }

  final R = (secp256k1.G * k0)!;

  BigInt k;
  if (R.y!.toBigInteger()! % BigInt.two == BigInt.zero) {
    // is even
    k = k0;
  } else {
    k = secp256k1.n - k0;
  }

  final rX = bigToBytes(R.x!.toBigInteger()!);
  final e = getE(P, rX, bmessage);

  final List<int> signature = rX + bigToBytes((k + e * d) % secp256k1.n);

  return hex.encode(signature);
}

/// Verifies a schnorr signature using the BIP-340 scheme.
///
/// publicKey must be 32-bytes hex-encoded, i.e., 64 characters
///   (if you have a pubkey with 33 bytes just remove the first one).
/// message must also be 32-bytes hex-encoded (a hash of the _actual_ message).
/// signature must be 64-bytes hex-encoded, i.e., 128 characters.
/// It returns true if the signature is valid, false otherwise.
/// For more information on BIP-340 see bips.xyz/340.
bool verify(String publicKey, String message, String signature) {
  ECPoint point;
  try {
    point = publicKeyToPoint(publicKey);
  } catch (err) {
    return false;
  }
  return verifyWithPoint(point, message, signature);
}

bool verifyWithPoint(ECPoint P, String message, String signature) {
  final List<int> bmessage = hex.decode(message, 0, 64);

  // signature = signature.padLeft(128, '0');
  final r = hex.decode(signature, 0, 64);
  final r_num = BigInt.parse(signature.substring(0, 64), radix: 16);
  final s_num = BigInt.parse(signature.substring(64, 128), radix: 16);
  if (r_num >= curveP || s_num >= secp256k1.n) {
    return false;
  }

  // not sure what these things mean
  BigInt e = getE(P, r, bmessage);
  ECPoint sG = (secp256k1.G * s_num)!;
  ECPoint eP_ = (P * e)!;
  BigInt ePy = curveP - eP_.y!.toBigInteger()!;
  ECPoint eP = secp256k1.curve.createPoint(eP_.x!.toBigInteger()!, ePy);

  // R is something important
  final ECPoint R = (sG + eP)!;
  if (R.isInfinity) {
    return false;
  }

  // now that we have R we get its coords
  final Rx = R.x!.toBigInteger()!;
  final Ry = R.y!.toBigInteger();

  // and we them in these checks which I don't understand
  if ((Rx.sign == 0 && Ry!.sign == 0) ||
      (Ry! % BigInt.two != BigInt.zero /* is odd */) ||
      (Rx != r_num)) {
    return false;
  }

  // the checks passed, it means the signature is good
  return true;
}

/// Produces the public key from a private key
///
/// Takes privateKey, a 32-bytes hex-encoded string, i.e. 64 characters.
/// Returns a public key as also 32-bytes hex-encoded.
String getPublicKey(String privateKey) {
  final d0 = BigInt.parse(privateKey, radix: 16);
  ECPoint P = (secp256k1.G * d0)!;
  return P.x!.toBigInteger()!.toRadixString(16).padLeft(64, "0");
}
