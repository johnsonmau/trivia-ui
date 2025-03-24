import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trivia_ui/auth_service.dart';
import 'package:trivia_ui/custom_bottom_nav.dart';
import 'package:trivia_ui/custom_music_player.dart';

class GameRulesPage extends StatefulWidget {
  @override
  _GameRulesPageState createState() => _GameRulesPageState();
}

class _GameRulesPageState extends State<GameRulesPage> {

  @override
  void initState() {
    _loadToken();
    super.initState();
  }

  String? token;
  int _selectedIndex = 2; // Default to Rules tab

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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //SimpleAudioPlayer(),
                      //_buildTitle(),
                      const SizedBox(height: 20),
                      _buildSection(
                        "Objective",
                        "Answer as many questions correctly as you can in the 1 minute 30 seconds game duration. Each question has a difficulty level that impacts your score.",
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "How to Play",
                        "1. The game consists of Easy, Medium, and Hard questions.\n"
                            "2. Each question has a 15-second timer.\n"
                            "3. Faster answers score higher points.\n"
                            "4. Skipping questions results in no points.",
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        "Scoring",
                        "Easy: 10 points base\n"
                            "Medium: 20 points base\n"
                            "Hard: 30 points base\n"
                            "\n"
                            "Your final score depends on how quickly you answer within 15 seconds. For example, answering in 10 seconds gives a higher score multiplier.",
                      ),
                      const SizedBox(height: 20),
                      _buildIconsSection(),
                      const SizedBox(height: 40),
                      _buildStartButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _selectedIndex,
          onTap: _onBottomNavigationTapped, isAuthenticated: token != null),
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

  Widget _buildTitle() {
    return Text(
      "Game Rules",
      style: TextStyle(
          fontSize: 48,
          fontFamily: 'Doto',
          fontWeight: FontWeight.w900,
        color: Colors.white,
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
              color: Colors.white
          ),
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

  Widget _buildIconsSection() {
    final feedbackList = [
      {'icon': Icons.flash_on, 'description': 'Mythic Mastermind', 'color': Colors.purpleAccent, 'scoreRange': '> 1000'},
      {'icon': Icons.diamond, 'description': 'Immortal Genius', 'color': Colors.purple, 'scoreRange': '950 - 1000'},
      {'icon': Icons.military_tech, 'description': 'Supreme Conqueror', 'color': Colors.deepOrange, 'scoreRange': '900 - 949'},
      {'icon': Icons.emoji_events, 'description': 'Celestial Champion', 'color': Colors.amberAccent, 'scoreRange': '850 - 899'},
      {'icon': Icons.star, 'description': 'Galactic Warrior', 'color': Colors.orange, 'scoreRange': '800 - 849'},
      {'icon': Icons.auto_awesome, 'description': 'Eternal Innovator', 'color': Colors.teal, 'scoreRange': '750 - 799'},
      {'icon': Icons.check_circle, 'description': 'Heroic Leader', 'color': Colors.green, 'scoreRange': '700 - 749'},
      {'icon': Icons.thumb_up_alt, 'description': 'Strategic Master', 'color': Colors.blue, 'scoreRange': '650 - 699'},
      {'icon': Icons.sentiment_very_satisfied, 'description': 'Tactical Genius', 'color': Colors.cyan, 'scoreRange': '600 - 649'},
      {'icon': Icons.sentiment_satisfied, 'description': 'Sharp Thinker', 'color': Colors.lightBlueAccent, 'scoreRange': '550 - 599'},
      {'icon': Icons.lightbulb, 'description': 'Brilliant Achiever', 'color': Colors.yellow, 'scoreRange': '500 - 549'},
      {'icon': Icons.timer, 'description': 'Efficient Performer', 'color': Colors.orangeAccent, 'scoreRange': '450 - 499'},
      {'icon': Icons.stars, 'description': 'Shining Star', 'color': Colors.pink, 'scoreRange': '400 - 449'},
      {'icon': Icons.thumb_up, 'description': 'Dedicated Player', 'color': Colors.greenAccent, 'scoreRange': '350 - 399'},
      {'icon': Icons.check, 'description': 'Skilled Performer', 'color': Colors.lightGreen, 'scoreRange': '300 - 349'},
      {'icon': Icons.task_alt, 'description': 'Rising Star', 'color': Colors.lime, 'scoreRange': '250 - 299'},
      {'icon': Icons.sentiment_neutral, 'description': 'Steady Progress', 'color': Colors.yellow, 'scoreRange': '200 - 249'},
      {'icon': Icons.sentiment_dissatisfied, 'description': 'Needs Focus', 'color': Colors.orange, 'scoreRange': '150 - 199'},
      {'icon': Icons.warning, 'description': 'On the Right Path', 'color': Colors.redAccent, 'scoreRange': '100 - 149'},
      {'icon': Icons.trending_down, 'description': 'Keep Practicing', 'color': Colors.red, 'scoreRange': '75 - 99'},
      {'icon': Icons.loop, 'description': 'Try Again', 'color': Colors.grey, 'scoreRange': '50 - 74'},
      {'icon': Icons.refresh, 'description': 'Room for Growth', 'color': Colors.grey, 'scoreRange': '25 - 49'},
      {'icon': Icons.replay, 'description': 'Don’t Give Up', 'color': Colors.grey, 'scoreRange': '< 25'},
    ];


    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double fontSize = width * 0.04; // Adjust multiplier as needed
        final double iconSize = width * 0.08; // Adjust multiplier as needed

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: feedbackList.map((feedback) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    feedback['scoreRange'] as String,
                    style: TextStyle(
                      fontSize: fontSize.clamp(12, 24), // Minimum and maximum font size
                      fontFamily: 'Doto',
                      fontWeight: FontWeight.w900,
                      color: feedback['color'] as Color,
                    ),
                  ),
                  Text(
                    " pts = ",
                    style: TextStyle(
                      fontSize: fontSize.clamp(12, 24),
                      fontFamily: 'Doto',
                      fontWeight: FontWeight.w900,
                      color: feedback['color'] as Color,
                    ),
                  ),
                  Icon(
                    feedback['icon'] as IconData,
                    color: feedback['color'] as Color,
                    size: iconSize.clamp(24, 48), // Minimum and maximum icon size
                  ),
                  const SizedBox(width: 10),
                  Text(
                    feedback['description'] as String,
                    style: TextStyle(
                      fontSize: fontSize.clamp(12, 24),
                      fontFamily: 'Doto',
                      fontWeight: FontWeight.w900,
                      color: feedback['color'] as Color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );

  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/play');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        "Start Playing!",
        style: GoogleFonts.outfit(
          textStyle: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _loadToken() async {
    token = await AuthService().getToken();
    if (mounted) {
      setState(() {}); // Update the state only if the widget is still mounted
    }
  }

}
