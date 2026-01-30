import 'dart:convert';

import 'package:client/core/failure/failure.dart';
import 'package:client/features/auth/model/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

class AuthRemoteRepositories {
  Future<Either<Failure, UserModel>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/auth/signup'),
        headers: {'Content-Type': 'applcation/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final resBodyMap = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 201) {
        // HANDLE THE ERROR!
        return Left(Failure(resBodyMap['detail']));
      }

      return Right(UserModel.fromMap(resBodyMap));
    } catch (e) {
      print(e.toString());
      return Left(Failure(e.toString()));
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/auth/login'),
        headers: {'Content-Type': 'applcation/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print(response.body);
      print(response.statusCode);
    } catch (e) {
      print(e.toString());
    }
  }
}
