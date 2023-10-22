import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/Theme/pallete.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';

class SignInButton extends ConsumerWidget {
  final bool isFromLogin;

  const SignInButton({super.key, this.isFromLogin = true});

  void signInWithGoogle(BuildContext context, WidgetRef ref) {
    ref
        .watch(authControllerProvider.notifier)
        .signInWithGoogle(context, isFromLogin);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton.icon(
        onPressed: () => {signInWithGoogle(context, ref)},
        icon: Image.asset(
          Constants.googlePath,
          width: 35,
        ),
        label: const Text(
          "Continue With Google",
          style: TextStyle(fontSize: 18, color: Pallete.whiteColor),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }
}
