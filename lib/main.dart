import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trivia_ui/audio_notifier.dart';
import 'package:trivia_ui/custom_bottom_nav.dart';
import 'package:trivia_ui/custom_music_player.dart';
import 'package:trivia_ui/game_page.dart';
import 'package:trivia_ui/game_rules_page.dart';
import 'package:trivia_ui/leaderboard_page.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Load environment variables
  runApp(
    ChangeNotifierProvider(
      create: (_) => AudioNotifier(),
      child: TriviaApp(),
    ),
  );
}

class TriviaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Always start at the LandingPage
      routes: {
        '/': (context) => LandingPage(),
        '/profile': (context) => ProfilePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/play': (context) => GamePage(),
        '/rules': (context) => GameRulesPage(),
        '/leaderboard': (context) => LeaderboardPage(),
      },
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _jumpAnimation;
  late Color _currentColor;
  String? token;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final audioNotifier = Provider.of<AudioNotifier>(context, listen: false);
    audioNotifier.loadUrl('/assets/galactic_rap.mp3');
    _loadToken();
    _initializeAnimations();
  }

  Future<void> _loadToken() async {
    token = await AuthService().getToken();
    if (mounted) {
      setState(() {}); // Update the state only if the widget is still mounted
    }
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _jumpAnimation = Tween<double>(begin: 0.0, end: -10.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);

    _controller.repeat(reverse: true);

    _currentColor = _generateRandomColor();
    _startColorAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  void _startColorAnimation() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() {
          _currentColor = _generateRandomColor();
        });
      }
    }
  }

  void _onBottomNavigationTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, '/');
        break;

      case 1: // Profile
        if (token != null) {
          Navigator.pushReplacementNamed(context, '/profile');
        } else {
          Navigator.pushNamed(context, '/login');
        }
        break;

      case 2: // Rules
        Navigator.pushNamed(context, '/rules');
        break;

      case 3: // Rules
        Navigator.pushNamed(context, '/leaderboard');
        break;

      default:
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          _buildContent(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _selectedIndex,
          onTap: _onBottomNavigationTapped, isAuthenticated: token != null)
    );
  }

  Widget _buildContent() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAnimatedTitle(),
            const SizedBox(height: 20),
            _buildDescription(),
            const SizedBox(height: 40),
            if (token == null)
              ..._buildLoggedOutButtons()
            else
              ..._buildLoggedInButtons(),
            const SizedBox(height: 20),
            SimpleAudioPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _jumpAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _jumpAnimation.value),
          child: child,
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          double fontSize = constraints.maxWidth * 0.1; // Adjust the multiplier as needed
          return AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
                fontSize: 2 * fontSize.clamp(20.0, 75.0), // Clamp to a min/max range
                fontFamily: 'Doto',
                fontWeight: FontWeight.w900,
                color: _currentColor
            ),
            child: const Text("Brainzy"),
          );
        },
      ),

    );
  }

  Widget _buildDescription() {
    return Text(
      "Test your knowledge and compete with others!",
      style: GoogleFonts.outfit(
        textStyle: const TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }

  List<Widget> _buildLoggedOutButtons() {
    return [
      _buildButton("Login", Colors.black, Colors.white, '/login'),
      const SizedBox(height: 20),
      _buildButton("Sign Up", Colors.white, Colors.black, '/signup'),
    ];
  }

  List<Widget> _buildLoggedInButtons() {
    return [
      _buildButton("Play!", Colors.green, Colors.white, '/play'),
    ];
  }

  Widget _buildButton(String text, Color buttonColor, Color textColor, String route) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.outfit(
            textStyle: TextStyle(fontSize: 18, color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
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
