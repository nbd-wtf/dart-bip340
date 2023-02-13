import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:bip340/bip340.dart' as bip340;
import 'package:csv/csv.dart' as csv;

void main() async {
  // test public key derivation
  var privateKey =
      "ea7daa0537b93aa3ae4495a274ecc05077e3dc168809d77a7afa4ec1db0fb3bd";
  var publicKey = bip340.getPublicKey(privateKey);
  var expected =
      "0ba0206887bd61579bf65ec09d7806bea32c64be1cf2c978cf031a811cd238db";
  if (publicKey == expected) {
    print("PUBLIC KEY derivation is correct.");
  } else {
    print("PUBLIC KEY derivation incorrect!");
    print("  expected $expected, got $publicKey");
  }

  // test bip340 vectors from the bip itself
  var data = await http.read(Uri.parse(
      "https://raw.githubusercontent.com/bitcoin/bips/master/bip-0340/test-vectors.csv"));
  List<List<dynamic>> vectors = csv.CsvToListConverter().convert(
    data,
    shouldParseNumbers: false,
  );
  for (var i = 1; i < vectors.length; i++) {
    var line = vectors[i];
    var errorMessage = line[7].length == 0 ? "<blank>" : line[7];

    if (line[3].length > 0) {
      var sig = bip340.sign(line[1], line[4], line[3]);
      var expected = line[5].toLowerCase();
      if (sig != expected) {
        print("SIGN error on line $i: ${errorMessage}.");
        print("  got signature '$sig', expected '${expected}'.");
      } else {
        print("SIGN line $i is correct.");
      }
    }

    var ok = bip340.verify(line[2], line[4], line[5]);
    var expected = line[6].toLowerCase();
    if ((ok && expected == 'true') || (!ok && expected == 'false')) {
      print("VERIFY line $i is correct.");
    } else {
      print("VERIFY error on line $i: ${errorMessage}.");
      print("  verify() returned '$ok', expected '$expected'");
    }
  }
}
