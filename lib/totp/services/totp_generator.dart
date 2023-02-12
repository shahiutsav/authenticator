import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:base32/base32.dart';

class OTP {
  static int generateTOTPCode(String secret, int time, String algorithm, int period, {int length = 6}) {
    time = (((time ~/ 1000).round()) ~/ period).floor();
    //time = (time ~/30).floor();
    return _generateCode(secret, time, length, algorithm);
  }

  // static int generateHOTPCode(String secret, int counter, {int length = 6}) {
  //   return _generateCode(secret, counter, length, algorithm);
  // }

  static int _generateCode(String secret, int time, int length, String algorithm) {
    length = (length <= 8 && length > 0) ? length : 6;

    var secretList = base32.decode(secret);
    var timebytes = _int2bytes(time);

    var hmac = Hmac(selectAlgorithm(algorithm), secretList);
    var hash = hmac.convert(timebytes).bytes;

    int offset = hash[hash.length - 1] & 0xf;

    int binary = ((hash[offset] & 0x7f) << 24) |
        ((hash[offset + 1] & 0xff) << 16) |
        ((hash[offset + 2] & 0xff) << 8) |
        (hash[offset + 3] & 0xff);

    return binary % pow(10, length) as int;
  }

  static String randomSecret() {
    var rand = Random();
    var bytes = <int>[];

    for (int i = 0; i < 10; i++) {
      bytes.add(rand.nextInt(256));
    }

    return base32.encode(Uint8List.fromList(bytes));
  }

  static List<int> _int2bytes(int long) {
    // we want to represent the input as a 8-bytes array
    List<int> byteArray = [0, 0, 0, 0, 0, 0, 0, 0];
    for (var index = byteArray.length - 1; index >= 0; index--) {
      var byte = long & 0xff;
      byteArray[index] = byte;
      long = (long - byte) ~/ 256;
    }
    return byteArray;
  }
}

selectAlgorithm(algorithm) {
  switch (algorithm) {
    case "SHA1":
      return sha1;
    case "SHA256":
      return sha256;
    case "SHA512":
      return sha512;
  }
}
