import 'dart:core';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:bip340/bip340.dart' as bip340;
import 'package:csv/csv.dart' as csv;

void main() async {
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
      var expected = line[5].toLowerCase();
      if (sig != expected) {
        print("error on line $i: ${line[7]}.");
        print("got signature '$sig', expected '${expected}'.");
      } else {
        print("line $i is ok.");
      }
    }
  }
}
