import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  final String email;
  final String name;
  final String id;
  final String token;

  UserModel({
    required this.email,
    required this.name,
    required this.id,
    required this.token,
  });

  UserModel copyWith({String? email, String? name, String? id, String? token}) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      id: id ?? this.id,
      token: token ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'email': email, 'name': name, 'id': id};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] ?? "",
      name: map['name'] ?? "",
      id: map['id'] ?? "",
      token: map['token'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'UserModel(email: $email, name: $name, id: $id)';
}
