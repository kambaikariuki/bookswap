import 'package:bookswap/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/log_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: BookSwapApp()));
}

class BookSwapApp extends ConsumerWidget {
  const BookSwapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookSwap',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const SignUpScreen(),
      },
      home: authState.when(
        data: (user) {
          if (user == null) return const LoginScreen();
          return user.emailVerified
              ? const HomeScreen() // replace with HomeScreen later
              : const VerifyEmailScreen();
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) => const Scaffold(body: Center(child: Text('Auth Error'))),
      ),
    );
  }
}

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('A verification link has been sent to your email.'),
            ElevatedButton(
              onPressed: () async => await authService.resendVerificationEmail(),
              child: const Text('Resend verification email'),
            ),
            TextButton(
              onPressed: () async {
                await authService.signOut();
              },
              child: const Text('Back to login'),
            ),
          ],
        ),
      ),
    );
  }
}
