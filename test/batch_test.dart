import 'dart:core';
import 'package:test/test.dart';
import 'package:bip340/bip340.dart' as bip340;
import 'package:bip340/src/helpers.dart';

void main() async {
  test("batch verification", () {
    final res = bip340.batchVerify(
      [
        "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798",
        "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798",
        "a4abd9ee548ba4680e4cb632b3d9c8a94f1b773fba3a96605504593a92071994",
        "defdea4cdb677750a420fee807eacf21eb9898ae79b9768766e4faa04a2d4a34"
      ].map(publicKeyToPoint).toList(),
      [
        "7b005ce588ed4fdfc40a2aca6f36e8ff63d9e31d919dbd152f91b22d99c95283",
        "1d78e40642437911c03ae12e6e25781e8fddf0d856bd85b4e6ab5ba62e529775",
        "c35a94aa9a90f70ef36b62899999adde7a6a15b611118dce6e8b07579c40f489",
        "12c95ee32f3ce77718b86e632f407967d84df8335b78e400aee9e7af7dc24300"
      ],
      [
        "6b0f87723550c0f66b0a11dc93bfd35a6d90dcfbdc6ff9d12c34b1dec583b081b6a8b951b474e1d04639c483eec235195b898bc5981dd00a5f5bc86b99a70e2f",
        "2661421edda8f912da6563c4c791955347df5423deb2037ceade1b327556379afe7f5d791bc57721a6e77a76f3ab5ac6b52c1627475d9fe7e78b6296728e4719",
        "96a36dbc2dc961d13ea0f5536d27c820cd9b11f641befd2f80d2505375a17b6a8a9deaee93ef553e94352113910c26098683a4d2874016aad5bba65397c6bb42",
        "9f2ac59bdc63b07e484ef7e0d2ad71aa7ea4103f927207516b9e9867b9ef023154558c5591ee0782c64761fa280a86cf6dd5c9536d96d144386c77d77cc2b2fe"
      ],
    );
    expect(res, true);
  });
}
