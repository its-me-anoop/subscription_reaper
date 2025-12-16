import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      "title": "THE LEAK",
      "subtitle":
          "Your bank account is bleeding.\nSmall cuts. Monthly drains.\nIt adds up to thousands.",
      "color": AppTheme.kColorNeonRed,
      "icon": Icons.water_drop_outlined,
    },
    {
      "title": "THE LIST",
      "subtitle":
          "See everything in one place.\nSorted by urgency.\nKnow exactly when to strike.",
      "color": Colors.yellow,
      "icon": Icons.list_alt_outlined,
    },
    {
      "title": "THE REAPER",
      "subtitle":
          "Take back control.\nSwipe to kill unwanted subs.\nSave your future self.",
      "color": AppTheme.kColorNeonGreen,
      "icon": Icons.content_cut_outlined,
    },
  ];

  void _onNext() {
    HapticFeedback.lightImpact();
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishIntro();
    }
  }

  void _finishIntro() {
    HapticFeedback.heavyImpact();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kColorBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishIntro,
                child: Text(
                  "SKIP",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.kColorLightGrey,
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: slide["color"], width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: (slide["color"] as Color).withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            slide["icon"],
                            size: 64,
                            color: slide["color"],
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          slide["title"],
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(color: slide["color"], fontSize: 40),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          slide["subtitle"],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                height: 1.5,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? _slides[index]["color"]
                        : AppTheme.kColorGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Next/Start Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _slides[_currentPage]["color"],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1
                        ? "INITIALIZE REAPER"
                        : "NEXT",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 18,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
