import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:bip340/bip340.dart' as bip340;
import 'package:csv/csv.dart' as csv;

void main() async {
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
