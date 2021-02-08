import 'dart:core';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:bip340/bip340.dart' as bip340;
import 'package:csv/csv.dart' as csv;

void main() async {
  print("hello world, let's sign some messages.");

  String key =
      "b493d48364afe44d11c0165cf470a4164d1e2609911ef998be868d46ade3de4e";
  String message = 'dart is a programming language like the others';
  String aux =
      "6216cddf83a0a3b7b1948541806adff3b4d457be49885db225877685576a4014";
  var signature = bip340.sign(key, message, aux);
  print(
      "the signature for '$message' with the key '${key}' and auxiliary data '$aux' is '$signature'");

  print("ok, now let's sign the messages from the bip340 test vectors.");
  var data = await http.read(
      "https://raw.githubusercontent.com/bitcoin/bips/master/bip-0340/test-vectors.csv");

  List<List<dynamic>> vectors = csv.CsvToListConverter().convert(
    data,
    shouldParseNumbers: false,
  );
  for (var i = 1; i < vectors.length; i++) {
    var line = vectors[i];
    if (line[3].length > 0) {
      var sig = bip340.sign(line[1], line[4], line[3]);
      if (sig != line[5]) {
        print("error on line $i: ${line[7]}");
        print("got signature '$sig', expected '${line[5]}'");
      }
    }
  }
}
