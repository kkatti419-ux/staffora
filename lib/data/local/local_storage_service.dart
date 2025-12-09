import 'package:get_storage/get_storage.dart';

class LocalStorage {
  static final box = GetStorage();

  static String? get token => box.read("token");

  static void saveToken(String token) {
    box.write("token", token);
  }
}
