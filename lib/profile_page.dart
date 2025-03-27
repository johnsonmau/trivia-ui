import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:trivia_ui/custom_bottom_nav.dart';
import 'package:trivia_ui/custom_music_player.dart';
import 'auth_service.dart';
import 'dart:async';
import 'package:flag/flag.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
  List<Map<String, dynamic>> scores = [];
  int _currentPage = 1; // Start on page 1
  final int _rowsPerPage = 5; // 5 rows per page

  final Map<String, Map<String, dynamic>> categoryIcons = {
    "All Categories": {
      'icon': Icons.category,
      'color': Colors.grey, // Neutral color for "All"
    },
    "Mixed": {
      'icon': Icons.shuffle,
      'color': Colors.purpleAccent, // Vibrant color for randomness
    },
    "General Knowledge": {
      'icon': Icons.lightbulb,
      'color': Colors.yellow, // Bright color for knowledge
    },
    "Entertainment: Books": {
      'icon': Icons.book,
      'color': Colors.brown, // Earthy tone for books
    },
    "Entertainment: Board Games": {
      'icon': Icons.gamepad,
      'color': Colors.orange, // Fun color for games
    },
    "Entertainment: Cartoons": {
      'icon': Icons.animation,
      'color': Colors.pinkAccent, // Playful color for cartoons
    },
    "Entertainment: Comics": {
      'icon': Icons.menu_book,
      'color': Colors.redAccent, // Bold color for comics
    },
    "Entertainment: Film": {
      'icon': Icons.movie,
      'color': Colors.blueGrey, // Cinematic color for films
    },
    "Entertainment: Japanese Anime": {
      'icon': Icons.live_tv,
      'color': Colors.purple, // Vibrant color for anime
    },
    "Entertainment: Music": {
      'icon': Icons.music_note,
      'color': Colors.teal, // Soothing color for music
    },
    "Entertainment: Musicals & Theatres": {
      'icon': Icons.theater_comedy,
      'color': Colors.deepOrange, // Dramatic color for theater
    },
    "Entertainment: Television": {
      'icon': Icons.tv,
      'color': Colors.indigo, // Cool color for TV
    },
    "Entertainment: Video Games": {
      'icon': Icons.videogame_asset,
      'color': Colors.green, // Energetic color for video games
    },
    "Geography": {
      'icon': Icons.map,
      'color': Colors.greenAccent, // Earthy color for geography
    },
    "History": {
      'icon': Icons.history_edu,
      'color': Colors.amber, // Warm color for history
    },
    "Mythology": {
      'icon': Icons.temple_buddhist,
      'color': Colors.deepPurple, // Mystical color for mythology
    },
    "Politics": {
      'icon': Icons.account_balance,
      'color': Colors.blue, // Official color for politics
    },
    "Science & Nature": {
      'icon': Icons.biotech,
      'color': Colors.lime, // Fresh color for nature
    },
    "Science: Computers": {
      'icon': Icons.computer,
      'color': Colors.cyan, // Techy color for computers
    },
    "Science: Gadgets": {
      'icon': Icons.devices,
      'color': Colors.lightBlue, // Modern color for gadgets
    },
    "Science: Mathematics": {
      'icon': Icons.calculate,
      'color': Colors.blueAccent, // Logical color for math
    },
    "Sports": {
      'icon': Icons.sports,
      'color': Colors.red, // Energetic color for sports
    },
    "Vehicles": {
      'icon': Icons.directions_car,
      'color': Colors.grey, // Metallic color for vehicles
    },
    "Art": {
      'icon': Icons.palette,
      'color': Colors.pink, // Creative color for art
    },
    "Animals": {
      'icon': Icons.pets,
      'color': Colors.lightGreen, // Natural color for animals
    },
    "Celebrities": {
      'icon': Icons.star,
      'color': Colors.amberAccent, // Glamorous color for celebrities
    },
  };

  final Map<String, Map<String, dynamic>> difficultyIcons = {
    "Mixed": {
      'icon': Icons.shuffle,
      'color': Colors.purpleAccent, // Vibrant color for randomness (matches "Mixed" in categories)
    },
    "Easy": {
      'icon': Icons.sentiment_satisfied,
      'color': Colors.green, // Calming color for easy
    },
    "Medium": {
      'icon': Icons.sentiment_neutral,
      'color': Colors.orange, // Moderate color for medium
    },
    "Hard": {
      'icon': Icons.sentiment_dissatisfied,
      'color': Colors.red, // Intense color for hard
    },
  };

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

    if (AuthService().badToken(token)) {
      await AuthService().clearToken();
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    Map<String, dynamic>? userDetails = await AuthService().getUserDetails(token);
    if (userDetails != null) {
      setState(() {
        username = userDetails['username'] ?? "Unknown User";
        scores = List<Map<String, dynamic>>.from(userDetails['scores'] ?? []);
        countryCd = userDetails['country'] ?? "Unknown Country Code";
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
        const String baseUrl = String.fromEnvironment("url_base");
        final String url = "$baseUrl/v1/auth/delete";
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
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: 1.2,
                  duration: const Duration(milliseconds: 500),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 60,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Delete Account",
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to delete your account? This action cannot be undone.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                        Navigator.pop(context);
                        _deleteAccount();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
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
      case 3: // Leaderboard
        Navigator.pushNamed(context, '/leaderboard');
        break;
      case 4: // Privacy
        Navigator.pushNamed(context, '/privacy');
        break;
    }
  }

  void _sortScores(String column) {
    setState(() {
      if (_sortColumn == column) {
        _isAscending = !_isAscending;
      } else {
        _sortColumn = column;
        _isAscending = true;
      }

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

      _currentPage = 1; // Reset to first page after sorting
    });
  }

  void _goToPreviousPage() {
    setState(() {
      _currentPage--;
    });
  }

  void _goToNextPage() {
    setState(() {
      _currentPage++;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated) {
      return const SizedBox.shrink(); // Redirected if not authenticated
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildBackground(),
          _buildContent(),
          const Positioned(
            bottom: 16.0,
            right: 16.0,
            child: SimpleAudioPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavigationTapped,
        isAuthenticated: _isAuthenticated,
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

  Widget _buildContent() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWelcomeMessage(),
                const SizedBox(height: 40),
                _buildPlayButton(),
                const SizedBox(height: 20),
                _buildScoresTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildWelcomeMessage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = constraints.maxWidth * 0.08;
        double flagHeight = (fontSize * 0.8).clamp(16.0, 40.0);
        double flagWidth = (flagHeight * 1.5).clamp(24.0, 60.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                "Welcome, $username",
                style: TextStyle(
                  fontSize: fontSize.clamp(20.0, 50.0),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        "Play!",
        style: GoogleFonts.outfit(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildScoresTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double textScaleFactor = screenWidth / 400.0;
        final bool isMobile = screenWidth < 600;

        // Dynamic column widths to fit exactly within screen width
        final double scoreColumnWidth = screenWidth * (isMobile ? 0.22 : 0.25);
        final double dateColumnWidth = screenWidth * (isMobile ? 0.14 : 0.15);
        final double difficultyColumnWidth = screenWidth * (isMobile ? 0.19 : 0.15);
        final double categoryColumnWidth = screenWidth * (isMobile ? 0.30 : 0.25);

        // Text style for headers
        final headerStyle = GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 16 * textScaleFactor.clamp(0.8, 1.0),
          color: Colors.blueGrey,
        );

        // Text style for cells
        final cellStyle = GoogleFonts.outfit(
          fontSize: 12 * textScaleFactor.clamp(0.8, 1.0),
          fontWeight: FontWeight.bold,
          color: Colors.white54,
        );

        // Pagination logic
        final int totalRows = scores.length;
        final int totalPages = (totalRows / _rowsPerPage).ceil();
        final int startIndex = (_currentPage - 1) * _rowsPerPage;
        final int endIndex = startIndex + _rowsPerPage > totalRows ? totalRows : startIndex + _rowsPerPage;
        final List<Map<String, dynamic>> paginatedScores = scores.sublist(startIndex, endIndex);

        // Determine if buttons should be disabled
        final bool canGoPrevious = _currentPage > 1;
        final bool canGoNext = _currentPage < totalPages;

        return Container(
          width: screenWidth,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: scores.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "No games played yet.",
                style: GoogleFonts.outfit(
                  fontSize: 20 * textScaleFactor.clamp(0.8, 1.2),
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          )
              : Column(
            children: [
              Table(
                columnWidths: {
                  0: FixedColumnWidth(scoreColumnWidth),
                  1: FixedColumnWidth(dateColumnWidth),
                  2: FixedColumnWidth(difficultyColumnWidth),
                  3: FixedColumnWidth(categoryColumnWidth),
                },
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                children: [
                  // Header row
                  TableRow(
                    decoration: const BoxDecoration(color: Colors.black87),
                    children: [
                      TableCell(
                        child: SizedBox(
                          height: 56,
                          width: scoreColumnWidth,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: InkWell(
                                onTap: () => _sortScores('score'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Scores',
                                      style: headerStyle,
                                    ),
                                    if (_sortColumn == 'score')
                                      Icon(
                                        _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                        size: 16 * textScaleFactor.clamp(0.8, 1.0),
                                        color: Colors.blueGrey,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: SizedBox(
                          height: 56,
                          width: dateColumnWidth,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: InkWell(
                                onTap: () => _sortScores('date'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Date',
                                      style: headerStyle,
                                    ),
                                    if (_sortColumn == 'date')
                                      Icon(
                                        _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                        size: 16 * textScaleFactor.clamp(0.8, 1.0),
                                        color: Colors.blueGrey,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: SizedBox(
                          height: 56,
                          width: difficultyColumnWidth,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Difficulty',
                                style: headerStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: SizedBox(
                          height: 56,
                          width: categoryColumnWidth,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Category',
                                style: headerStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Data rows (paginated)
                  ...paginatedScores.map((score) {
                    final feedback = getFeedbackByScore(score['score']);
                    return TableRow(
                      decoration: const BoxDecoration(color: Colors.black87),
                      children: [
                        _buildScoreCell(score, feedback, scoreColumnWidth, cellStyle, textScaleFactor, isMobile),
                        _buildDateCell(score, dateColumnWidth, cellStyle),
                        _buildDifficultyCell(score, difficultyColumnWidth, cellStyle),
                        _buildCategoryCell(score, categoryColumnWidth, cellStyle),
                      ],
                    );
                  }).toList(),
                ],
              ),
              // Pagination controls
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: canGoPrevious ? _goToPreviousPage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.withOpacity(canGoPrevious ? 1.0 : 0.3),
                        foregroundColor: Colors.white54,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Previous',
                        style: GoogleFonts.outfit(
                          fontSize: 14 * textScaleFactor.clamp(0.8, 1.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Text(
                      'Page $_currentPage of $totalPages',
                      style: GoogleFonts.outfit(
                        fontSize: 14 * textScaleFactor.clamp(0.8, 1.0),
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: canGoNext ? _goToNextPage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.withOpacity(canGoNext ? 1.0 : 0.3),
                        foregroundColor: Colors.white54,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: GoogleFonts.outfit(
                          fontSize: 14 * textScaleFactor.clamp(0.8, 1.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreCell(Map<String, dynamic> score, Map<String, dynamic> feedback, double width, TextStyle style, double textScaleFactor, bool isMobile) {
    final descriptionStyle = TextStyle(
      fontSize: 15 * textScaleFactor.clamp(0.8, 1.0),
      color: feedback['color'] as Color,
      fontFamily: 'Doto',
      fontWeight: FontWeight.w900,
    );

    return TableCell(
      child: SizedBox(
        height: 150,
        width: width,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: isMobile
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${score['score']}',
                  style: style.copyWith(
                    fontSize: 20 * textScaleFactor.clamp(0.8, 1.0),
                    color: feedback['color'] as Color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${feedback['description']}',
                  style: descriptionStyle,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                const SizedBox(height: 4),
                Icon(
                  feedback['icon'] as IconData,
                  color: feedback['color'] as Color,
                  size: 20 * textScaleFactor.clamp(0.8, 1.0),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(
                    '${score['score']}',
                    style: style.copyWith(
                      fontSize: 20 * textScaleFactor.clamp(0.8, 1.0),
                      color: feedback['color'] as Color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 3,
                  child: Text(
                    '${feedback['description']}',
                    style: descriptionStyle,
                    textAlign: TextAlign.center,
                    softWrap: true,
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
        ),
      ),
    );
  }

  Widget _buildDateCell(Map<String, dynamic> score, double width, TextStyle style) {
    return TableCell(
      child: SizedBox(
        height: 150,
        width: width,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              _formatDate(score['date']),
              style: style.copyWith(fontSize: 10 * style.fontSize!.clamp(0.8, 1.0)),
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCell(Map<String, dynamic> score, double width, TextStyle style) {
    final String difficulty = score['difficulty'] ?? 'Unknown';
    final String shortenedDifficulty = _shortenDifficulty(difficulty);
    final Map<String, dynamic>? difficultyData = difficultyIcons[difficulty]; // Get the icon and color

    return TableCell(
      child: SizedBox(
        height: 150,
        width: width,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (difficultyData != null) ...[
                  Icon(
                    difficultyData['icon'] as IconData,
                    size: 16,
                    color: difficultyData['color'] as Color, // Use the difficulty-specific color
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    shortenedDifficulty,
                    style: style.copyWith(
                      color: Colors.white54, // Match text color to icon color
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCell(Map<String, dynamic> score, double width, TextStyle style) {
    final String category = score['category'] ?? 'Unknown';
    final String shortenedCategory = _shortenCategory(category);
    final Map<String, dynamic>? categoryData = categoryIcons[category]; // Get the icon and color

    return TableCell(
      child: SizedBox(
        height: 150,
        width: width,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (categoryData != null) ...[
                  Icon(
                    categoryData['icon'] as IconData,
                    size: 16,
                    color: categoryData['color'] as Color, // Use the category-specific color
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    shortenedCategory,
                    style: style,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  String _formatDate(String date) {
    try {
      final dateTimeParts = date.split(' ');
      if (dateTimeParts.length >= 3) {
        final datePart = dateTimeParts[0];
        final timePart = '${dateTimeParts[1]} ${dateTimeParts[2]}';
        final dateComponents = datePart.split('/');
        if (dateComponents.length == 3) {
          final month = dateComponents[0];
          final day = dateComponents[1];
          final year = dateComponents[2].substring(2);
          final formattedDate = '$month/$day/$year';
          return '$timePart\n$formattedDate';
        }
      }
      return date;
    } catch (e) {
      return date;
    }
  }

  String _shortenDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Med';
      case 'hard':
        return 'Hard';
      case 'mixed':
        return 'Mixed';
      default:
        return difficulty;
    }
  }

  String _shortenCategory(String category) {
    if (category.startsWith('Entertainment: ')) {
      return category.replaceFirst('Entertainment: ', 'Ent: ');
    } else if (category.startsWith('Science: ')) {
      return category.replaceFirst('Science: ', 'Sci: ');
    } else if (category == 'General Knowledge') {
      return 'Gen Know';
    }
    return category;
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 200,
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                "Logout",
                style: GoogleFonts.outfit(
                  color: Colors.redAccent,
                  fontSize: 16,
                ),
              ),
              onTap: () async {
                await AuthService().clearToken();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                "Delete Account",
                style: GoogleFonts.outfit(
                  color: Colors.redAccent,
                  fontSize: 14,
                ),
              ),
              onTap: _showDeleteConfirmationDialog,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}