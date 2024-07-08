import 'package:bcrypt/bcrypt.dart';

class PasswordChanger {
  String changePassword(String password) {
    String salt = BCrypt.gensalt();
    String hashedPassword = BCrypt.hashpw(password, salt);
    return hashedPassword;
  }

  bool checkPassword(String plainPassword, String hashedPassword) {
    return BCrypt.checkpw(plainPassword, hashedPassword);
  }
}