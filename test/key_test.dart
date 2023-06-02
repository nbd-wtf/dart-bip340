import 'dart:core';
import 'package:bip340/bip340.dart' as bip340;
import 'package:test/test.dart';

void main() async {
  test('Public key derivation', () {
    var privateKey =
        "ea7daa0537b93aa3ae4495a274ecc05077e3dc168809d77a7afa4ec1db0fb3bd";
    var publicKey = bip340.getPublicKey(privateKey);
    var expected =
        "0ba0206887bd61579bf65ec09d7806bea32c64be1cf2c978cf031a811cd238db";

    expect(publicKey, expected);
  });
}
