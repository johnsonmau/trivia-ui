import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:trivia_ui/custom_bottom_nav.dart';
import 'package:trivia_ui/custom_music_player.dart';
import 'auth_service.dart';
import 'dart:async';
import 'package:flag/flag.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String username = "Unknown User";
  String countryCd = "Unknown Country Code";
  int _selectedIndex = 1; // Default to Profile tab
  bool _isAscending = true; // Default sorting direction
  String _sortColumn = 'score'; // Default sort by 'score'
  List<dynamic> scores = [];
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    String? token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    if (AuthService().badToken(token)){
      AuthService().clearToken();
      Navigator.pushReplacementNamed(context, '/');
    }

    Map<String, dynamic>? userDetails = await AuthService().getUserDetails(token);
    if (userDetails != null) {
      setState(() {
        username = userDetails['username'] ?? "Unknown User";
        scores = userDetails['scores'];
        countryCd = userDetails['country'];
        _isAuthenticated = true;
        _isLoading = false;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? token = await AuthService().getToken();
      if (token != null) {
        final String baseUrl = const String.fromEnvironment("url_base");
        String url = baseUrl+"/v1/auth/delete"; // Replace with your backend endpoint
        final response = await http.delete(
          Uri.parse(url),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        if (response.statusCode == 200) {
          await AuthService().clearToken();
          Navigator.pushReplacementNamed(
            context,
            '/',
            arguments: "Account deleted successfully.",
          );
        } else {
          _showErrorDialog("Failed to delete account. Please try again.");
        }
      }
    } catch (e) {
      _showErrorDialog("Unable to connect to the server.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon
                AnimatedScale(
                  scale: 1.2,
                  duration: const Duration(milliseconds: 500),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 60,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  "Delete Account",
                  style: GoogleFonts.outfit(
                    textStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Content
                Text(
                  "Are you sure you want to delete your account? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context), // Close dialog
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _deleteAccount();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Confirm",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
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
        Navigator.pushReplacementNamed(context, '/profile');
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
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (!_isAuthenticated) {
      return Container(); // Redirected if not authenticated
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildTransparentAppBar(),
      endDrawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildBackground(),
          _buildContent(),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: SimpleAudioPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _selectedIndex,
          onTap: _onBottomNavigationTapped, isAuthenticated: _isAuthenticated)
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  PreferredSizeWidget _buildTransparentAppBar() {
    return AppBar(
      automaticallyImplyLeading: false, // Hides the back button if present
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
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

  Widget _buildContent() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWelcomeMessage(),
              SizedBox(height: 40),
              _buildPlayButton(),
              const SizedBox(height: 20),
              _buildScoresTable()
            ],
          ),
        ),
      ),
    );
  }

  void _sortScores(String column) {
    setState(() {
      if (_sortColumn == column) {
        // If already sorted by this column, toggle the sort direction
        _isAscending = !_isAscending;
      } else {
        // Otherwise, set the new sort column and default to ascending
        _sortColumn = column;
        _isAscending = true;
      }

      // Perform sorting based on the column
      scores.sort((a, b) {
        if (column == 'score') {
          return _isAscending
              ? a['score'].compareTo(b['score'])
              : b['score'].compareTo(a['score']);
        } else if (column == 'date') {
          return _isAscending
              ? a['date'].compareTo(b['date'])
              : b['date'].compareTo(a['date']);
        }
        return 0;
      });
    });
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

  Widget _buildScoresTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth * 0.9;
        final textScaleFactor = constraints.maxWidth / 400.0;

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
                  sortColumnIndex: _sortColumn == 'score' ? 0 : 1,
                  sortAscending: _isAscending,
                  columnSpacing: tableWidth * 0.1,
                  headingRowColor: MaterialStateProperty.all(Colors.black87),
                  dataRowColor: MaterialStateProperty.all(Colors.black87),
                  columns: [
                    DataColumn(
                      label: InkWell(
                        onTap: () => _sortScores('score'),
                        child: Row(
                          children: [
                            Text(
                              'Scores',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16 * textScaleFactor.clamp(0.8, 1.0),
                                color: Colors.blueGrey,
                              ),
                            ),
                            if (_sortColumn == 'score')
                              Icon(
                                _isAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16 * textScaleFactor.clamp(0.8, 1.0),
                                color: Colors.blueGrey,
                              ),
                          ],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: InkWell(
                        onTap: () => _sortScores('date'),
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
                            if (_sortColumn == 'date')
                              Icon(
                                _isAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                size: 16 * textScaleFactor.clamp(0.8, 1.0),
                                color: Colors.blueGrey,
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
                                flex: 2,
                                child: Text(
                                  '${score['score']}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20 * textScaleFactor.clamp(0.8, 1.0),
                                    fontWeight: FontWeight.bold,
                                    color: feedback['color'] as Color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                flex: 3,
                                child: Text(
                                  '${feedback['description']}',
                                  style: TextStyle(
                                            fontSize: 15 * textScaleFactor.clamp(0.8, 1.0),
                                            color: feedback['color'] as Color,
                                            fontFamily: 'Doto',
                                            fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                flex: 1,
                                child: Icon(
                                  feedback['icon'] as IconData,
                                  color: feedback['color'] as Color,
                                  size: 20 * textScaleFactor.clamp(0.8, 1.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            score['date'],
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

  Widget _buildWelcomeMessage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamically calculate font and flag sizes based on screen width
        double fontSize = constraints.maxWidth * 0.08; // Adjusted multiplier for scaling
        double flagHeight = (fontSize * 0.8).clamp(16.0, 40.0); // Clamp height between 16 and 40
        double flagWidth = (flagHeight * 1.5).clamp(24.0, 60.0); // Clamp width proportionally

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                "Welcome, $username",
                style: TextStyle(
                  fontSize: fontSize.clamp(20.0, 50.0), // Minimum and maximum size
                  fontFamily: 'Doto',
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            const SizedBox(width: 4),
            if (countryCd.isNotEmpty)
              Flexible(
                child: SizedBox(
                  height: flagHeight,
                  width: flagWidth,
                  child: Flag.fromString(
                    countryCd,
                    height: flagHeight,
                    width: flagWidth,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }





  Widget _buildPlayButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/play');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        "Play!",
        style: GoogleFonts.outfit(
          textStyle: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return ClipRRect(
      borderRadius: BorderRadius.zero, // Ensures no rounded corners
      child: Drawer(
        width: 200,
        child: Container(
          color: Colors.black, // Change this to your desired background color
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  "Logout",
                  style: GoogleFonts.outfit(
                    textStyle: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                ),
                onTap: () async {
                  await AuthService().clearToken();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              const Spacer(), // Pushes the delete account button to the bottom
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  "Delete Account",
                  style: GoogleFonts.outfit(
                    textStyle: const TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),
                onTap: _showDeleteConfirmationDialog,
              ),
              const SizedBox(height: 20), // Add spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }




}
