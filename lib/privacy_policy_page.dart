import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trivia_ui/custom_bottom_nav.dart';
import 'package:trivia_ui/custom_music_player.dart';
import 'package:trivia_ui/auth_service.dart';

class PrivacyPolicyPage extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  int _selectedIndex = 4;
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildSection(
                        "Privacy Policy",
                        "We may collect personal information such as your name, email, and game scores to enhance your experience. Additionally, we may collect device information, IP addresses, and interaction data to improve our service.",
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "How We Use Your Information",
                        "Your data is used to personalize your experience, improve our services, and provide game-related updates. We may also use aggregated data for analytics and performance tracking.",
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "Data Security",
                        "We implement security measures to protect your information, including encryption and access controls. However, no system is completely secure, and we cannot guarantee absolute security.",
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "Third-Party Services",
                        "We may use third-party services for analytics, advertising, and authentication. These services may collect data based on their privacy policies, and we recommend reviewing them for further details.",
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "Your Rights",
                        "You have the right to access, modify, or delete your personal data. You can request changes or deletions by contacting us through the provided support channels.",
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "Cookies and Tracking Technologies",
                        "We may use cookies and similar tracking technologies to enhance user experience and analyze usage patterns. You can adjust your cookie preferences in your browser settings.",
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "Children’s Privacy",
                        "Our services are not intended for children under the age of 13. We do not knowingly collect personal data from minors. If you believe we have collected such data, please contact us immediately.",
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "Changes to This Policy",
                        "We may update this privacy policy periodically. Please review it frequently for any changes. Continued use of our service constitutes acceptance of the updated policy.",
                      ),
                      const SizedBox(height: 40),
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
    return Text(
      title,
      style: GoogleFonts.outfit(
        textStyle: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 20,
              fontFamily: 'Doto',
              fontWeight: FontWeight.w900,
              color: Colors.white),
              textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
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
      ],
    );
  }
}