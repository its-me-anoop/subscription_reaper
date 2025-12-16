import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/intro_screen.dart';

void main() {
  runApp(const SubscriptionReaperApp());
}

class SubscriptionReaperApp extends StatelessWidget {
  const SubscriptionReaperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Subscription Reaper',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const IntroScreen(),
      ),
    );
  }
}
