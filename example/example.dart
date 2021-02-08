import 'dart:core';
import 'dart:math';
import 'package:bip340/bip340.dart' as bip340;

void main() {
  print("hello world, let's sign some messages.");

  BigInt key = BigInt.parse(
      "b493d48364afe44d11c0165cf470a4164d1e2609911ef998be868d46ade3de4e",
      radix: 16);
  String message = 'dart is a programming language like the others';
  String aux =
      "6216cddf83a0a3b7b1948541806adff3b4d457be49885db225877685576a4014";
  var signature = bip340.sign(key, message, aux);
  print(
      "the signature for '$message' with the key '${key.toRadixString(16)}' and auxiliary data '$aux' is '$signature'");
}
