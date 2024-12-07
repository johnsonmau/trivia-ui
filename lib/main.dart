// ignore_for_file: prefer_const_constructors

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'sign_up_page.dart';

void main() => runApp(TriviaApp());

class TriviaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _jumpAnimation;
  late Color _currentColor;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400), // Duration for one jump cycle
    );

    // Create jump animation (moves up and down)
    _jumpAnimation = Tween<double>(begin: 0.0, end: -10.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);

    // Start infinite looping animation
    _controller.repeat(reverse: true);

    // Initialize random color and start color animation
    _currentColor = _generateRandomColor();
    _startColorAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Generates a random color
  Color _generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256), // Red
      random.nextInt(256), // Green
      random.nextInt(256), // Blue
    );
  }

  /// Animates the title's color to randomly change every 2 seconds
  void _startColorAnimation() async {
    while (mounted) {
      await Future.delayed(Duration(milliseconds: 600));
      setState(() {
        _currentColor = _generateRandomColor();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          _buildBackground(),
          // Page Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Title
                AnimatedBuilder(
                  animation: _jumpAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _jumpAnimation.value), // Apply jump effect
                      child: child,
                    );
                  },
                  child: AnimatedDefaultTextStyle(
                    duration: Duration(seconds: 2), // Smooth transition for color
                    style: GoogleFonts.fredoka(
                      textStyle: TextStyle(
                        fontSize: 100,
                        color: _currentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text("Brainzy"),
                  ),
                ),
                SizedBox(height: 20),
                // Description
                Text(
                  "Test your knowledge and compete with others!",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                // Buttons
                _buildButton(
                  context,
                  "Login",
                  Colors.black,
                  Colors.white,
                  GoogleFonts.poppins(),
                      () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                ),
                SizedBox(height: 20),
                _buildButton(
                  context,
                  "Sign Up",
                  Colors.white,
                  Colors.black,
                  GoogleFonts.poppins(),
                      () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      BuildContext context,
      String text,
      Color buttonColor,
      Color textColor,
      TextStyle fontStyle,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: fontStyle.copyWith(
            color: textColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          color: Colors.black.withOpacity(0.6),
        ),
      ],
    );
  }
}
