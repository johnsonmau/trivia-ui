import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trivia_ui/auth_service.dart';
import 'package:trivia_ui/custom_bottom_nav.dart';
import 'package:http/http.dart' as http;
import 'package:flag/flag.dart';
import 'package:trivia_ui/custom_music_player.dart';
import 'global.dart' as globals;

void printTimezone() {
  print('Current timezone: ${globals.timezone}');
}


class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {

  @override
  void initState() {
    _loadToken();
    super.initState();
    getTop25();
  }

  String? token;
  int _selectedIndex = 3; // Default to Rules tab
  List<dynamic> scores = [];

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
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildTitle(),
                            _buildSection("Top 25", ""),
                            _buildLeaderboardTable(),
                          ],
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
            ),
          ],
        ),
      bottomNavigationBar: BottomNavBar(currentIndex: _selectedIndex,
          onTap: _onBottomNavigationTapped, isAuthenticated: token != null)
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

  Future<void> _loadToken() async {
    token = await AuthService().getToken();
    if (mounted) {
      setState(() {}); // Update the state only if the widget is still mounted
    }
  }

  Widget _buildLeaderboardTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth * 0.9;
        final textScaleFactor = constraints.maxWidth / 400.0;
        double flagHeight = (textScaleFactor * 0.8).clamp(16.0, 40.0); // Clamp height between 16 and 40
        double flagWidth = (flagHeight * 1.5).clamp(24.0, 60.0); // Clamp width proportionally

        return Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: tableWidth,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: scores.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "No games played yet.",
                    style: GoogleFonts.outfit(
                      fontSize: 20 * textScaleFactor.clamp(0.8, 1.0),
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              )
                  : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: tableWidth * 0.1,
                  headingRowColor: MaterialStateProperty.all(Colors.black87),
                  dataRowColor: MaterialStateProperty.all(Colors.black87),
                  columns: [
                    DataColumn(
                      label: InkWell(
                        child: Row(
                          children: [
                            Text(
                              'User',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * textScaleFactor.clamp(0.8, 1.0),
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: InkWell(
                        child: Row(
                          children: [
                            Text(
                              'Score',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * textScaleFactor.clamp(0.8, 1.0),
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: InkWell(
                        child: Row(
                          children: [
                            Text(
                              'Date',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * textScaleFactor.clamp(0.8, 1.0),
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  rows: scores.map((score) {
                    final feedback = getFeedbackByScore(score['score']);
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 0,
                                child: Text(
                                  '${score['username']}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12 * textScaleFactor.clamp(0.8, 1.0),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                flex: 0,
                                child: SizedBox(
                                  height: flagHeight,
                                  width: flagWidth,
                                  child: Flag.fromString(
                                    '${score['countryCd']}',
                                    height: flagHeight,
                                    width: flagWidth,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                flex: 0,
                                  child: Text(
                                      '${score['score']}',
                                      style: GoogleFonts.outfit(
                                      fontSize: 12 * textScaleFactor.clamp(0.8, 1.0),
                                      fontWeight: FontWeight.bold,
                                      color: feedback['color'] as Color,
                                      ),
                                  )
                              ),
                              Flexible(
                                flex: 0,
                                child: Icon(
                                  feedback['icon'] as IconData,
                                  color: feedback['color'] as Color,
                                  size: 15 * textScaleFactor.clamp(0.8, 1.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            '${score['date']}',
                            style: GoogleFonts.outfit(
                              fontSize: 12 * textScaleFactor.clamp(0.8, 1.0),
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> getFeedbackByScore(int score) {
    if (score > 1000) {
      return {
        'icon': Icons.flash_on,
        'color': Colors.purpleAccent,
        'description': 'Mythic Mastermind',
      };
    } else if (score > 950) {
      return {
        'icon': Icons.diamond,
        'color': Colors.purple,
        'description': 'Immortal Genius',
      };
    } else if (score > 900) {
      return {
        'icon': Icons.military_tech,
        'color': Colors.deepOrange,
        'description': 'Supreme Conqueror',
      };
    } else if (score > 850) {
      return {
        'icon': Icons.emoji_events,
        'color': Colors.amberAccent,
        'description': 'Celestial Champion',
      };
    } else if (score > 800) {
      return {
        'icon': Icons.star,
        'color': Colors.orange,
        'description': 'Galactic Warrior',
      };
    } else if (score > 750) {
      return {
        'icon': Icons.auto_awesome,
        'color': Colors.teal,
        'description': 'Eternal Innovator',
      };
    } else if (score > 700) {
      return {
        'icon': Icons.check_circle,
        'color': Colors.green,
        'description': 'Heroic Leader',
      };
    } else if (score > 650) {
      return {
        'icon': Icons.thumb_up_alt,
        'color': Colors.blue,
        'description': 'Strategic Master',
      };
    } else if (score > 600) {
      return {
        'icon': Icons.sentiment_very_satisfied,
        'color': Colors.cyan,
        'description': 'Tactical Genius',
      };
    } else if (score > 550) {
      return {
        'icon': Icons.sentiment_satisfied,
        'color': Colors.lightBlueAccent,
        'description': 'Sharp Thinker',
      };
    } else if (score > 500) {
      return {
        'icon': Icons.lightbulb,
        'color': Colors.yellow,
        'description': 'Brilliant Achiever',
      };
    } else if (score > 450) {
      return {
        'icon': Icons.timer,
        'color': Colors.orangeAccent,
        'description': 'Efficient Performer',
      };
    } else if (score > 400) {
      return {
        'icon': Icons.stars,
        'color': Colors.pink,
        'description': 'Shining Star',
      };
    } else if (score > 350) {
      return {
        'icon': Icons.thumb_up,
        'color': Colors.greenAccent,
        'description': 'Dedicated Player',
      };
    } else if (score > 300) {
      return {
        'icon': Icons.check,
        'color': Colors.lightGreen,
        'description': 'Skilled Performer',
      };
    } else if (score > 250) {
      return {
        'icon': Icons.task_alt,
        'color': Colors.lime,
        'description': 'Rising Star',
      };
    } else if (score > 200) {
      return {
        'icon': Icons.sentiment_neutral,
        'color': Colors.yellow,
        'description': 'Steady Progress',
      };
    } else if (score > 150) {
      return {
        'icon': Icons.sentiment_dissatisfied,
        'color': Colors.orange,
        'description': 'Needs Focus',
      };
    } else if (score > 100) {
      return {
        'icon': Icons.warning,
        'color': Colors.redAccent,
        'description': 'On the Right Path',
      };
    } else if (score > 75) {
      return {
        'icon': Icons.trending_down,
        'color': Colors.red,
        'description': 'Keep Practicing',
      };
    } else if (score > 50) {
      return {
        'icon': Icons.loop,
        'color': Colors.grey,
        'description': 'Try Again',
      };
    } else if (score > 25) {
      return {
        'icon': Icons.refresh,
        'color': Colors.grey,
        'description': 'Room for Growth',
      };
    } else {
      return {
        'icon': Icons.replay,
        'color': Colors.grey,
        'description': 'Don’t Give Up',
      };
    }
  }

  Widget _buildTitle() {
    return Text(
      "Global Leaderboard",
      style: TextStyle(
        fontSize: 48,
        fontFamily: 'Doto',
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> getTop25() async {
    final String baseUrl = const String.fromEnvironment("url_base");
    String url = baseUrl+"/v1/scores/leaders/25"; // Replace with your backend endpoint

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "X-User-Timezone": globals.timezone
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        scores = data;
      });
    } else {

    }

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
}
