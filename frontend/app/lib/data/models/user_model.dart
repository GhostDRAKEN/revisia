class UserModel {
  final int id;
  final String firstName;
  final String email;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'first_name': firstName, 'email': email};
  }
}
