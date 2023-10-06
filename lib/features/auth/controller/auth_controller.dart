import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/features/auth/repository/auth_repository.dart';
import 'package:reddit/user_model.dart';
import 'package:reddit/utils.dart';

final authControllerProvider = Provider((ref) => AuthController(authRepository: ref.read(authRepositoryProvider)));

class AuthController {
  late final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository}): _authRepository = authRepository;

  void signInWithGoogle(BuildContext context) async {
    final user = await _authRepository.signInWithGoogle();
    user.fold((l) => showSnackBar(context, l.message), (r) => null);
  }
}