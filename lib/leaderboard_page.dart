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
  String? token;
  int _selectedIndex = 3; // Default to Leaderboard tab
  List<dynamic> scores = [];
  String selectedCategory = 'All Categories'; // Updated default value
  String selectedDifficulty = 'All Difficulties'; // Updated default value

  final List<String> categories = [
    "All Categories",
    "Mixed",
    "General Knowledge",
    "Entertainment: Books",
    "Entertainment: Board Games",
    "Entertainment: Cartoons",
    "Entertainment: Comics",
    "Entertainment: Film",
    "Entertainment: Japanese Anime",
    "Entertainment: Music",
    "Entertainment: Musicals & Theatres",
    "Entertainment: Television",
    "Entertainment: Video Games",
    "Geography",
    "History",
    "Mythology",
    "Politics",
    "Science & Nature",
    "Science: Computers",
    "Science: Gadgets",
    "Science: Mathematics",
    "Sports",
    "Vehicles",
    "Art",
    "Animals",
    "Celebrities"
  ];

  final Map<String, Map<String, dynamic>> categoryIcons = {
    "All Categories": {'icon': Icons.category, 'color': Colors.grey},
    "Mixed": {'icon': Icons.shuffle, 'color': Colors.purpleAccent},
    "General Knowledge": {'icon': Icons.lightbulb, 'color': Colors.yellow},
    "Entertainment: Books": {'icon': Icons.book, 'color': Colors.brown},
    "Entertainment: Board Games": {'icon': Icons.gamepad, 'color': Colors.orange},
    "Entertainment: Cartoons": {'icon': Icons.animation, 'color': Colors.pinkAccent},
    "Entertainment: Comics": {'icon': Icons.menu_book, 'color': Colors.redAccent},
    "Entertainment: Film": {'icon': Icons.movie, 'color': Colors.blueGrey},
    "Entertainment: Japanese Anime": {'icon': Icons.live_tv, 'color': Colors.purple},
    "Entertainment: Music": {'icon': Icons.music_note, 'color': Colors.teal},
    "Entertainment: Musicals & Theatres": {'icon': Icons.theater_comedy, 'color': Colors.deepOrange},
    "Entertainment: Television": {'icon': Icons.tv, 'color': Colors.indigo},
    "Entertainment: Video Games": {'icon': Icons.videogame_asset, 'color': Colors.green},
    "Geography": {'icon': Icons.map, 'color': Colors.greenAccent},
    "History": {'icon': Icons.history_edu, 'color': Colors.amber},
    "Mythology": {'icon': Icons.temple_buddhist, 'color': Colors.deepPurple},
    "Politics": {'icon': Icons.account_balance, 'color': Colors.blue},
    "Science & Nature": {'icon': Icons.biotech, 'color': Colors.lime},
    "Science: Computers": {'icon': Icons.computer, 'color': Colors.cyan},
    "Science: Gadgets": {'icon': Icons.devices, 'color': Colors.lightBlue},
    "Science: Mathematics": {'icon': Icons.calculate, 'color': Colors.blueAccent},
    "Sports": {'icon': Icons.sports, 'color': Colors.red},
    "Vehicles": {'icon': Icons.directions_car, 'color': Colors.grey},
    "Art": {'icon': Icons.palette, 'color': Colors.pink},
    "Animals": {'icon': Icons.pets, 'color': Colors.lightGreen},
    "Celebrities": {'icon': Icons.star, 'color': Colors.amberAccent},
  };

  final List<String> difficulties = ["Mixed", "Easy", "Medium", "Hard"];

  final Map<String, Map<String, dynamic>> difficultyIcons = {
    "All Difficulties": {'icon': Icons.all_inclusive, 'color': Colors.grey},
    "Mixed": {'icon': Icons.shuffle, 'color': Colors.purpleAccent},
    "Easy": {'icon': Icons.sentiment_satisfied, 'color': Colors.green},
    "Medium": {'icon': Icons.sentiment_neutral, 'color': Colors.orange},
    "Hard": {'icon': Icons.sentiment_dissatisfied, 'color': Colors.red},
  };

  @override
  void initState() {
    _loadToken();
    super.initState();
    getTop25(); // Initial fetch with default values
  }

  Future<void> _loadToken() async {
    token = await AuthService().getToken();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getTop25() async {
    final String baseUrl = const String.fromEnvironment("url_base");
    // Adjust query parameters: use "Mixed" for "All Difficulties" to fetch all difficulties
    String categoryParam = selectedCategory;
    String difficultyParam = selectedDifficulty;
    String url = "$baseUrl/v1/scores/leaders/25?category=${Uri.encodeQueryComponent(categoryParam)}&difficulty=${Uri.encodeQueryComponent(difficultyParam)}";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "X-User-Timezone": globals.timezone,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        scores = data;
      });
    } else {
      print('Failed to load leaderboard: ${response.statusCode}');
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
      case 3: // Leaderboard
        Navigator.pushNamed(context, '/leaderboard');
        break;
      case 4: // Privacy
        Navigator.pushNamed(context, '/privacy');
        break;
      default:
        break;
    }
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Ensure the value exists in the items list
    if (!items.contains(value)) {
      value = items.first; // Fallback to the first item if value is invalid
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250, minWidth: 160),
      child: IntrinsicWidth(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            dropdownColor: Colors.black,
            value: value,
            onChanged: (String? newValue) {
              onChanged(newValue);
              getTop25(); // Fetch new data when selection changes
            },
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
                  child: Text(
                    value,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              );
            }).toList(),
            isExpanded: true,
            underline: SizedBox(),
            iconSize: 24,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
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
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildTitle(),
                          SizedBox(height: 75),
                          // Responsive Category Dropdown and Difficulty Panel
                          LayoutBuilder(
                            builder: (context, constraints) {
                              const double mobileBreakpoint = 600;
                              bool isMobile = constraints.maxWidth < mobileBreakpoint;

                              // Build a single difficulty button
                              Widget buildDifficultyButton(String difficulty) {
                                final isSelected = difficulty == selectedDifficulty;
                                final difficultyData = difficultyIcons[difficulty]!;
                                final buttonColor = difficultyData['color'] as Color;

                                return SizedBox(
                                  width: difficulty == "All Difficulties" ? 150 : 100, // Wider for "All Difficulties"
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() => selectedDifficulty = difficulty);
                                      getTop25(); // Fetch new data when selection changes
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected ? buttonColor.withOpacity(0.8) : Colors.black,
                                      foregroundColor: buttonColor,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: buttonColor, width: isSelected ? 2 : 1),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(difficultyData['icon'] as IconData, size: 16, color: isSelected ? Colors.white : buttonColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          difficulty,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            color: isSelected ? Colors.white : buttonColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              // Split difficulties into two rows for mobile
                              final firstRow = difficulties.sublist(0, 2); // "Mixed", "Easy"
                              final secondRow = difficulties.sublist(2, 4); // "Medium", "Hard"

                              return Column(
                                children: [
                                  // Category Dropdown
                                  isMobile
                                      ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 10),
                                          _buildDropdown(
                                            value: selectedCategory,
                                            items: categories,
                                            onChanged: (String? newValue) {
                                              setState(() => selectedCategory = newValue!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                      : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Category:",
                                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                                      ),
                                      SizedBox(width: 10),
                                      _buildDropdown(
                                        value: selectedCategory,
                                        items: categories,
                                        onChanged: (String? newValue) {
                                          setState(() => selectedCategory = newValue!);
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  // Difficulty Panel
                                  Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      // "All Difficulties" button
                                      buildDifficultyButton("All Difficulties"),
                                      const SizedBox(height: 10),
                                      // Other difficulty buttons
                                      isMobile
                                          ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: firstRow
                                                .map((difficulty) => Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                              child: buildDifficultyButton(difficulty),
                                            ))
                                                .toList(),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: secondRow
                                                .map((difficulty) => Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                              child: buildDifficultyButton(difficulty),
                                            ))
                                                .toList(),
                                          ),
                                        ],
                                      )
                                          : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: difficulties
                                            .map((difficulty) => Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                          child: buildDifficultyButton(difficulty),
                                        ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 50),
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavigationTapped,
        isAuthenticated: token != null,
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

  Widget _buildLeaderboardTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenWidth = constraints.maxWidth;
        final double textScaleFactor = screenWidth / 400.0;
        final double flagHeight = (textScaleFactor * 0.8).clamp(12.0, 30.0);
        final double flagWidth = (flagHeight * 1.5).clamp(18.0, 45.0);
        final bool isMobile = screenWidth < 600;

        // Dynamic column widths to fit exactly within screen width
        final double userColumnWidth = screenWidth * (isMobile ? 0.22 : 0.2);
        final double scoreColumnWidth = screenWidth * (isMobile ? 0.12 : 0.15);
        final double dateColumnWidth = screenWidth * (isMobile ? 0.14 : 0.15);
        final double difficultyColumnWidth = screenWidth * (isMobile ? 0.15 : 0.15);
        final double categoryColumnWidth = screenWidth * (isMobile ? 0.30 : 0.25);

        // Text style for headers
        final headerStyle = GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 14 * textScaleFactor.clamp(0.8, 1.0),
          color: Colors.blueGrey,
        );

        // Text style for cells
        final cellStyle = GoogleFonts.outfit(
          fontSize: 12 * textScaleFactor.clamp(0.8, 1.0),
          fontWeight: FontWeight.bold,
          color: Colors.white54,
        );

        return Container(
          width: screenWidth,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
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
              : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Table(
              columnWidths: {
                0: FixedColumnWidth(userColumnWidth),
                1: FixedColumnWidth(scoreColumnWidth),
                2: FixedColumnWidth(dateColumnWidth),
                3: FixedColumnWidth(difficultyColumnWidth),
                4: FixedColumnWidth(categoryColumnWidth),
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
                    _buildHeaderCell('User', userColumnWidth, headerStyle),
                    _buildHeaderCell('Score', scoreColumnWidth, headerStyle),
                    _buildHeaderCell('Date', dateColumnWidth, headerStyle),
                    _buildHeaderCell('Difficulty', difficultyColumnWidth, headerStyle),
                    _buildHeaderCell('Category', categoryColumnWidth, headerStyle),
                  ],
                ),
                // Data rows
                ...scores.map((score) {
                  final feedback = getFeedbackByScore(score['score']);
                  return TableRow(
                    decoration: const BoxDecoration(color: Colors.black87),
                    children: [
                      _buildUserCell(score, userColumnWidth, cellStyle, flagHeight, flagWidth, isMobile),
                      _buildScoreCell(score, feedback, scoreColumnWidth, cellStyle, textScaleFactor, isMobile),
                      _buildDateCell(score, dateColumnWidth, cellStyle),
                      _buildDifficultyCell(score, difficultyColumnWidth, cellStyle),
                      _buildCategoryCell(score, categoryColumnWidth, cellStyle),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper to build header cells
  Widget _buildHeaderCell(String label, double width, TextStyle style) {
    return TableCell(
      child: SizedBox(
        height: 48,
        width: width,
        child: Center(
          child: Text(
            label,
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Helper to build User cell
  Widget _buildUserCell(Map<String, dynamic> score, double width, TextStyle style, double flagHeight, double flagWidth, bool isMobile) {
    return TableCell(
      child: SizedBox(
        height: isMobile ? 72 : 48,
        width: width,
        child: Center(
          child: isMobile
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: flagHeight,
                width: flagWidth,
                child: Flag.fromString(
                  '${score['countryCd']}',
                  height: flagHeight,
                  width: flagWidth,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  '${score['username']}',
                  style: style,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '${score['username']}',
                  style: style,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                height: flagHeight,
                width: flagWidth,
                child: Flag.fromString(
                  '${score['countryCd']}',
                  height: flagHeight,
                  width: flagWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build Score cell
  Widget _buildScoreCell(Map<String, dynamic> score, Map<String, dynamic> feedback, double width, TextStyle style, double textScaleFactor, bool isMobile) {
    return TableCell(
      child: SizedBox(
        height: isMobile ? 72 : 48,
        width: width,
        child: Center(
          child: isMobile
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${score['score']}',
                style: style.copyWith(color: feedback['color'] as Color),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Icon(
                feedback['icon'] as IconData,
                color: feedback['color'] as Color,
                size: 14 * textScaleFactor.clamp(0.8, 1.0),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '${score['score']}',
                  style: style.copyWith(color: feedback['color'] as Color),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                feedback['icon'] as IconData,
                color: feedback['color'] as Color,
                size: 14 * textScaleFactor.clamp(0.8, 1.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build Date cell
  Widget _buildDateCell(Map<String, dynamic> score, double width, TextStyle style) {
    return TableCell(
      child: SizedBox(
        height: 72,
        width: width,
        child: Center(
          child: Text(
            _formatDate(score['date']),
            style: style.copyWith(fontSize: 12 * style.fontSize!.clamp(0.8, 1.0)),
            textAlign: TextAlign.center,
            softWrap: false,
          ),
        ),
      ),
    );
  }

  // Helper to build Difficulty cell
  Widget _buildDifficultyCell(Map<String, dynamic> score, double width, TextStyle style) {
    final String difficulty = score['difficulty'] ?? 'Unknown';
    final String shortenedDifficulty = _shortenDifficulty(difficulty);
    final Map<String, dynamic>? difficultyData = difficultyIcons[difficulty];

    return TableCell(
      child: SizedBox(
        height: 72,
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
                    color: difficultyData['color'] as Color,
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    shortenedDifficulty,
                    style: style.copyWith(color: Colors.white54),
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

  // Helper to build Category cell
  Widget _buildCategoryCell(Map<String, dynamic> score, double width, TextStyle style) {
    final String category = score['category'] ?? 'Unknown';
    final String shortenedCategory = _shortenCategory(category);
    final Map<String, dynamic>? categoryData = categoryIcons[category];

    return TableCell(
      child: SizedBox(
        height: 72,
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
                    color: categoryData['color'] as Color,
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

  // Shorten date format (e.g., "2023-10-15" -> "23-10-15")
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

  // Shorten difficulty text
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

  // Shorten category text by removing prefixes and abbreviating
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

  Map<String, dynamic> getFeedbackByScore(int score) {
    if (score > 1000) {
      return {'icon': Icons.flash_on, 'color': Colors.purpleAccent, 'description': 'Mythic Mastermind'};
    } else if (score > 950) {
      return {'icon': Icons.diamond, 'color': Colors.purple, 'description': 'Immortal Genius'};
    } else if (score > 900) {
      return {'icon': Icons.military_tech, 'color': Colors.deepOrange, 'description': 'Supreme Conqueror'};
    } else if (score > 850) {
      return {'icon': Icons.emoji_events, 'color': Colors.amberAccent, 'description': 'Celestial Champion'};
    } else if (score > 800) {
      return {'icon': Icons.star, 'color': Colors.orange, 'description': 'Galactic Warrior'};
    } else if (score > 750) {
      return {'icon': Icons.auto_awesome, 'color': Colors.teal, 'description': 'Eternal Innovator'};
    } else if (score > 700) {
      return {'icon': Icons.check_circle, 'color': Colors.green, 'description': 'Heroic Leader'};
    } else if (score > 650) {
      return {'icon': Icons.thumb_up_alt, 'color': Colors.blue, 'description': 'Strategic Master'};
    } else if (score > 600) {
      return {'icon': Icons.sentiment_very_satisfied, 'color': Colors.cyan, 'description': 'Tactical Genius'};
    } else if (score > 550) {
      return {'icon': Icons.sentiment_satisfied, 'color': Colors.lightBlueAccent, 'description': 'Sharp Thinker'};
    } else if (score > 500) {
      return {'icon': Icons.lightbulb, 'color': Colors.yellow, 'description': 'Brilliant Achiever'};
    } else if (score > 450) {
      return {'icon': Icons.timer, 'color': Colors.orangeAccent, 'description': 'Efficient Performer'};
    } else if (score > 400) {
      return {'icon': Icons.stars, 'color': Colors.pink, 'description': 'Shining Star'};
    } else if (score > 350) {
      return {'icon': Icons.thumb_up, 'color': Colors.greenAccent, 'description': 'Dedicated Player'};
    } else if (score > 300) {
      return {'icon': Icons.check, 'color': Colors.lightGreen, 'description': 'Skilled Performer'};
    } else if (score > 250) {
      return {'icon': Icons.task_alt, 'color': Colors.lime, 'description': 'Rising Star'};
    } else if (score > 200) {
      return {'icon': Icons.sentiment_neutral, 'color': Colors.yellow, 'description': 'Steady Progress'};
    } else if (score > 150) {
      return {'icon': Icons.sentiment_dissatisfied, 'color': Colors.orange, 'description': 'Needs Focus'};
    } else if (score > 100) {
      return {'icon': Icons.warning, 'color': Colors.redAccent, 'description': 'On the Right Path'};
    } else if (score > 75) {
      return {'icon': Icons.trending_down, 'color': Colors.red, 'description': 'Keep Practicing'};
    } else if (score > 50) {
      return {'icon': Icons.loop, 'color': Colors.grey, 'description': 'Try Again'};
    } else if (score > 25) {
      return {'icon': Icons.refresh, 'color': Colors.grey, 'description': 'Room for Growth'};
    } else {
      return {'icon': Icons.replay, 'color': Colors.grey, 'description': 'Don’t Give Up'};
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
            color: Colors.white,
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
}