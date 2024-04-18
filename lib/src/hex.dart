import 'dart:typed_data';

class hex {
  static const String _ALPHABET = "0123456789abcdef";

  static Uint8List decode(String str, int offset, int length) {
    Uint8List result = new Uint8List(length ~/ 2);
    final end = offset + length;
    for (int i = offset; i < end; i += 2) {
      int firstDigit = _ALPHABET.indexOf(str[i]);
      int secondDigit = _ALPHABET.indexOf(str[i + 1]);
      if (firstDigit == -1 || secondDigit == -1) {
        throw new FormatException("Non-hex character detected in $hex");
      }
      result[i ~/ 2] = (firstDigit << 4) + secondDigit;
    }
    return result;
  }

  static encode(List<int> bytes) {
    StringBuffer buffer = new StringBuffer();
    for (int part in bytes) {
      if (part & 0xff != part) {
        throw new FormatException("Non-byte integer detected");
      }
      buffer.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
    }
    return buffer.toString();
  }
}
