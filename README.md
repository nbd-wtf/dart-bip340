<a href="https://nbd.wtf"><img align="right" height="196" src="https://user-images.githubusercontent.com/1653275/194609043-0add674b-dd40-41ed-986c-ab4a2e053092.png" /></a>

bip340 [![Pub](https://img.shields.io/pub/v/bip340.svg?style=flat)](https://pub.dev/packages/bip340)
======

Implements basic signing and verification functions for the [BIP-340](https://bips.xyz/340) Schnorr Signature Scheme.

It passes the [tests](https://github.com/bitcoin/bips/blob/master/bip-0340/test-vectors.csv) attached to the BIP (`dart run example/example.dart` to run that), but no guarantees are made of anything and _this is not safe cryptography_, do not use to store Bitcoins.

Provides these functions:

1. `String sign(String privateKey, String message, String aux)`

  Generates a schnorr signature using the BIP-340 scheme.

  * `privateKey` must be 32-bytes hex-encoded, i.e., 64 characters.
  * `message` must also be 32-bytes hex-encoded (a hash of the _actual_ message).
  * `aux ` must be 32-bytes random bytes, generated at signature time.
  * Returns the signature as a string of 64 bytes hex-encoded, i.e., 128 characters.

2. `bool verify(String publicKey, String message, String signature)`

  Verifies a schnorr signature using the BIP-340 scheme.

  * `publicKey` must be 32-bytes hex-encoded, i.e., 64 characters (if you have a pubkey with 33 bytes just remove the first one).
  * `message` must also be 32-bytes hex-encoded (a hash of the _actual_ message).
  * `signature` must be 64-bytes hex-encoded, i.e., 128 characters.
  * Returns true if the signature is valid, false otherwise.

3. `String getPublicKey(String privateKey)`

  Produces the public key from a private key

  * `privateKey` must be a 32-bytes hex-encoded string, i.e. 64 characters.
  * Returns a public key as also 32-bytes hex-encoded.

Made for integration with [Nostr](https://github.com/fiatjaf/nostr).
