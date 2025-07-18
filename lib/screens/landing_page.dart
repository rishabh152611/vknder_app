import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'login_page.dart';

class LandingPage extends StatefulWidget {
  static const routeName = '/landing';

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'animation': 'assets/animations/first.json',
      'text': 'Stuck? Need a buddy for your plans?\nvknder’s here to help you get going.',
    },
    {
      'animation': 'assets/animations/second.json',
      'text': 'Plan or join hangouts in a tap.\nQuick outings, events — all just a click away.',
    },
    {
      'animation': 'assets/animations/third.json',
      'text': 'Join like-minded groups.\nGet the party started with your kind of people.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themePink = Color(0xFFE23744);
    final themePurple = Color(0xFF1A0033);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Beautiful background image
          Image.asset('assets/images/logo.jpeg', fit: BoxFit.cover),
          // Gradient overlay for darkening and theme
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themePurple.withOpacity(0.93),
                  themePink.withOpacity(0.80),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                // App logo or name
                Text(
                  "vknder",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: onboardingData.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            onboardingData[index]['animation']!,
                            height: MediaQuery.of(context).size.height * 0.32,
                          ),
                          const SizedBox(height: 40),
                          Text(
                            onboardingData[index]['text']!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                        (i) => AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      height: 10,
                      width: _currentPage == i ? 28 : 10,
                      decoration: BoxDecoration(
                        color: _currentPage == i ? themePink : Colors.white54,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (_currentPage == i)
                            BoxShadow(
                              color: themePink.withOpacity(0.5),
                              blurRadius: 8,
                            )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == onboardingData.length - 1) {
                      Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
                    } else {
                      _controller.nextPage(
                        duration: Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themePink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    elevation: 5,
                  ),
                  child: Text(
                    _currentPage == onboardingData.length - 1 ? 'Get Started' : 'Next',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
