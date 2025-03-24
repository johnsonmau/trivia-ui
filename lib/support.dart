import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trivia_ui/custom_bottom_nav.dart';
import 'package:trivia_ui/custom_music_player.dart';
import 'package:trivia_ui/auth_service.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  int _selectedIndex = 0;
  String? token;

  @override
  void initState() {
    _loadToken();
    super.initState();
  }

  Future<void> _loadToken() async {
    token = await AuthService().getToken();
    if (mounted) {
      setState(() {}); // Update the state only if the widget is still mounted
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


      case 4: // Rules
        Navigator.pushNamed(context, '/privacy');
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle("Support"),
                      const SizedBox(height: 20),
                      _buildSection(
                        "",
                        "Welcome to the Brainzzy support page! Below, you'll find information on troubleshooting issues and contacting us for further assistance.",
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "What is Brainzzy?",
                        "Brainzzy is a fast-paced general knowledge trivia game where players answer multiple-choice questions within a time limit. The game is designed to test your intelligence and reward quick thinking.",
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "How Do I Report a Bug or Issue?",
                        "If you're experiencing any issues, please try the following:\n- Ensure your app is up to date.\n- Restart your device and relaunch the app.\n- Clear the app cache.\n- If the issue persists, contact our support team.",
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "Contact Us",
                        "For further assistance, feel free to reach out:\n📧 Email: mbjjr95@gmail.com\n 📱 Social Media: Follow us on Twitter, Instagram, and Facebook for updates!",
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: SimpleAudioPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavigationTapped,
        isAuthenticated: true,
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

  Widget _buildTitle(String title) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 40,
          fontFamily: 'Doto',
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }


  Widget _buildSection(String title, String content) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Doto',
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20), // Adjust for centering
            child: Text(
              content,
              style: GoogleFonts.outfit(
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

}