import 'package:flutter/cupertino.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
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
      child: AdaptiveApp(
        materialLightTheme: AppTheme.lightTheme,
        materialDarkTheme: AppTheme.darkTheme,
        cupertinoLightTheme: const CupertinoThemeData(
          brightness: Brightness.light,
        ),
        cupertinoDarkTheme: const CupertinoThemeData(
          brightness: Brightness.dark,
        ),
        material: (context, platform) =>
            const MaterialAppData(debugShowCheckedModeBanner: false),
        cupertino: (context, platform) =>
            const CupertinoAppData(debugShowCheckedModeBanner: false),
        home: const IntroScreen(),
      ),
    );
  }
}
