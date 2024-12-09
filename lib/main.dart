import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TriviaApp());
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
      },
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
  String? token;
  int _selectedIndex = 0; // Default to the Home tab

  @override
  void initState() {
    super.initState();
    _loadToken();
    _initializeAnimations();
  }

  Future<void> _loadToken() async {
    token = await AuthService().getToken();
    setState(() {}); // Refresh UI after loading token
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400), // Duration for one jump cycle
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
      await Future.delayed(Duration(milliseconds: 600));
      setState(() {
        _currentColor = _generateRandomColor();
      });
    }
  }

  void _onBottomNavigationTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Already on Home page
    } else if (index == 1 && token != null) {
      Navigator.pushReplacementNamed(context, '/profile');
    } else if (index == 1 && token == null) {
      Navigator.pushNamed(context, '/login');
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
      bottomNavigationBar: _buildBottomNavigationBar(),
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
            SizedBox(height: 20),
            _buildDescription(),
            SizedBox(height: 40),
            if (token == null) ..._buildLoggedOutButtons() else ..._buildLoggedInButtons(),
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
      child: AnimatedDefaultTextStyle(
        duration: Duration(seconds: 2),
        style: GoogleFonts.fredoka(
          textStyle: TextStyle(
            fontSize: 100,
            color: _currentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text("Brainzy"),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      "Test your knowledge and compete with others!",
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
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
      SizedBox(height: 20),
      _buildButton("Sign Up", Colors.white, Colors.black, '/signup'),
    ];
  }

  List<Widget> _buildLoggedInButtons() {
    return [
      _buildButton("Play!", Colors.green, Colors.white, '/profile'),
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
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
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

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavigationTapped,
      backgroundColor: Colors.blueGrey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            _selectedIndex == 0 ? Icons.home_filled : Icons.home_outlined,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            _selectedIndex == 1 ? Icons.person : Icons.person_outline,
          ),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    );
  }
}
