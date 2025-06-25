import 'dart:convert';
import 'package:crypto/crypto.dart';

String sha1Hash(String text) {
  final bytes = utf8.encode(text);
  final digest = sha1.convert(bytes);
  return digest.toString();
}
