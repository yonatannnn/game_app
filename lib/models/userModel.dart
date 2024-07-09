class User {
  String firstName;
  String lastName;
  String userName;
  String password;
  String id;


  User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.userName,
      required this.password});



  Map<String, dynamic> toMap() {
    return {
      'id': userName,
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'password': password
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      userName: map['userName'],
      password: map['password'],
    );
  }
}
