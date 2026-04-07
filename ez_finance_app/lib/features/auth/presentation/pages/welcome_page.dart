import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.account_balance_wallet,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'EZ Finance',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Manage your finances with ease',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.login),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Skip to home for now (testing)
                  context.go(RouteNames.home);
                },
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
