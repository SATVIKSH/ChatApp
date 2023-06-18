import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chat App',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 42, color: Theme.of(context).colorScheme.onPrimary),
            ),
            const SizedBox(
              height: 18,
            ),
            Image.asset(
              'assets/images/chat.png',
              width: 200,
              height: 200,
            ),
          ],
        ),
      ),
    );
  }
}
