import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:html_unescape/html_unescape.dart';
import 'package:trivia_ui/animated_result_icon.dart';
import 'package:trivia_ui/custom_bottom_nav.dart';
import 'package:trivia_ui/custom_music_player.dart';
import 'auth_service.dart';
import 'package:auto_size_text/auto_size_text.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  String? token;
  bool isGameStarted = false;
  bool isLoadingQuestion = false;
  bool isAnswering = false;
  bool? isAnswerCorrect;
  Map<String, dynamic>? currentQuestion;
  bool showOptions = true;
  int userScore = 0;
  int _selectedIndex = 0;
  late Timer _gameTimer;
  late Timer _questionTimer;

  Duration _gameTimeRemaining = const Duration(seconds: 90);
  Duration _questionTimeRemaining = const Duration(seconds: 15);

  late AnimationController _questionTimerController;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _loadToken();

    _questionTimerController = AnimationController(
      vsync: this,
      duration: _questionTimeRemaining,
    );

    _questionTimer = Timer(const Duration(seconds: 0), () {});
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    _questionTimer.cancel();
    _questionTimerController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    String? token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/');
      return;
    }

    if (AuthService().badToken(token)) {
      AuthService().clearToken();
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _loadToken() async {
    token = await AuthService().getToken();
    setState(() {});
  }

  void _startGame() {
    setState(() {
      isGameStarted = true;
    });
    _startGameTimer();
    _fetchNextQuestion();
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_gameTimeRemaining > const Duration(seconds: 1)) {
          _gameTimeRemaining -= const Duration(seconds: 1);
        } else {
          timer.cancel();
          _endGame();
        }
      });
    });
  }

  void _startQuestionTimer() {
    _questionTimerController.reset();
    _questionTimerController.forward();

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_questionTimeRemaining > const Duration(seconds: 1)) {
          _questionTimeRemaining -= const Duration(seconds: 1);
        } else {
          if (_gameTimeRemaining > const Duration(seconds: 1)) {
            _gameTimeRemaining -= const Duration(seconds: 1);
          } else {
            timer.cancel();
          }
          timer.cancel();
          _skipQuestion();
        }
      });
    });
  }

  void _resetQuestionTimer() {
    _questionTimer.cancel();
    setState(() {
      _questionTimeRemaining = const Duration(seconds: 15);
    });
    _startQuestionTimer();
  }

  Future<void> _fetchNextQuestion() async {
    if (_gameTimeRemaining <= const Duration(seconds: 1)) return;

    setState(() {
      isLoadingQuestion = true;
      isAnswerCorrect = null;
      showOptions = true;
      isAnswering = false;
    });

    try {
      final String baseUrl = const String.fromEnvironment("url_base");
      String url = "$baseUrl/v1/questions/random";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          currentQuestion = json.decode(response.body);
        });
        _resetQuestionTimer();
      } else {
        _showErrorDialog("Failed to load the question from the server.");
      }
    } catch (e) {
      _showErrorDialog("Unable to connect to the server.");
    } finally {
      setState(() {
        isLoadingQuestion = false;
      });
    }
  }

  int _calculateBaseScore(String difficulty) {
    switch (difficulty) {
      case "EASY":
        return 10;
      case "MEDIUM":
        return 20;
      case "HARD":
        return 30;
      default:
        return 0;
    }
  }

  Future<void> _skipQuestion() async {
    setState(() {
      isAnswerCorrect = false;
      showOptions = false;
    });

    await Future.delayed(const Duration(seconds: 2));
    _fetchNextQuestion();
  }

  Future<void> _endGame() async {
    _gameTimer.cancel();
    _questionTimer.cancel();

    try {
      final String baseUrl = const String.fromEnvironment("url_base");
      String apiUrl = "$baseUrl/v1/scores/save";
      await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({'score': userScore}),
      );
    } catch (e) {}

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "End Game",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.4,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Text(
                        "GAME OVER",
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.1,
                          fontFamily: 'Doto',
                          fontWeight: FontWeight.w900,
                          color: Colors.redAccent,
                        ),
                      );
                    },
                  ),
                  Text(
                    "Your Score: $userScore",
                    style: GoogleFonts.outfit(
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/profile', (route) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                              horizontal:
                              MediaQuery.of(context).size.width * 0.05,
                              vertical:
                              MediaQuery.of(context).size.height * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Profile",
                            style: GoogleFonts.outfit(
                              fontSize:
                              MediaQuery.of(context).size.width * 0.04,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/play', (route) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                              horizontal:
                              MediaQuery.of(context).size.width * 0.05,
                              vertical:
                              MediaQuery.of(context).size.height * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Play Again",
                            style: GoogleFonts.outfit(
                              fontSize:
                              MediaQuery.of(context).size.width * 0.04,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            if (isGameStarted) {
              bool shouldExit = await _showExitConfirmationDialog();
              if (shouldExit) Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: isGameStarted
                  ? (isLoadingQuestion
                  ? const Center(child: CircularProgressIndicator())
                  : _buildQuestionContent())
                  : _buildStartContent(),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.02,
            right: MediaQuery.of(context).size.width * 0.04,
            child: SimpleAudioPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: isGameStarted
          ? null
          : BottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onBottomNavigationTapped,
          isAuthenticated: token != null),
    );
  }

  void _onBottomNavigationTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        token != null
            ? Navigator.pushReplacementNamed(context, '/profile')
            : Navigator.pushNamed(context, '/login');
        break;
      case 2:
        Navigator.pushNamed(context, '/rules');
        break;
      case 3:
        Navigator.pushNamed(context, '/leaderboard');
        break;
    }
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            "Exit Game?",
            style: GoogleFonts.outfit(
              fontSize: MediaQuery.of(context).size.width * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          content: Text(
            "Are you sure you want to exit? Your progress will be lost.",
            style: GoogleFonts.outfit(
              fontSize: MediaQuery.of(context).size.width * 0.04,
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Cancel",
                style: GoogleFonts.outfit(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color: Colors.green,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Exit",
                style: GoogleFonts.outfit(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  Widget _buildStartContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              double fontSize = constraints.maxWidth * 0.08;
              return Text(
                "Game Time!",
                style: TextStyle(
                  fontSize: fontSize.clamp(24.0, 48.0),
                  fontFamily: 'Doto',
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 300,  // Maximum width for the button
              maxHeight: 60,  // Maximum height for the button
            ),
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(
                  vertical: (MediaQuery.of(context).size.height * 0.02).clamp(10.0, 20.0),  // Clamp vertical padding
                  horizontal: (MediaQuery.of(context).size.width * 0.08).clamp(20.0, 40.0), // Clamp horizontal padding
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Start Game",
                style: GoogleFonts.outfit(
                  fontSize: (MediaQuery.of(context).size.width * 0.045).clamp(16.0, 24.0), // Clamp font size
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyAnswer(String selectedOption) async {
    setState(() {
      isAnswering = true;
      showOptions = true;
    });

    bool isCorrect = false;
    try {
      final String baseUrl = const String.fromEnvironment("url_base");
      String apiUrl = "$baseUrl/v1/questions/solve";
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({'qid': currentQuestion!["id"], 'guess': selectedOption}),
      );
      isCorrect = json.decode(response.body)!["correctAnswer"];
    } catch (e) {}

    setState(() {
      isAnswerCorrect = isCorrect;
      if (isCorrect) {
        int baseScore = _calculateBaseScore(currentQuestion!["difficulty"]);
        double timeMultiplier = _questionTimeRemaining.inSeconds / 15.0;
        userScore += (baseScore * timeMultiplier).ceil();
      }
    });

    setState(() => showOptions = false);
    Future.delayed(const Duration(milliseconds: 500), _fetchNextQuestion);
  }

  Widget _buildQuestionContent() {
    if (currentQuestion == null) {
      return const Center(
        child: Text(
          "No question available.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final unescape = HtmlUnescape();
    final unescapedQuestion = unescape.convert(currentQuestion!["question"]);
    final options = List<String>.from(
        currentQuestion!["allAnswers"].map((option) => unescape.convert(option)));

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;

        // Calculate dynamic sizes based on available space
        final scoreFontSize = availableWidth * 0.09;
        final timerFontSize = availableWidth * 0.045;
        final questionFontSize = availableWidth * 0.06;
        final optionFontSize = availableWidth * 0.045;
        final timerSize = availableWidth * 0.2;
        final buttonHeight = availableHeight * 0.1;

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section: Score and Timers
            Column(
              children: [
                SizedBox(height: availableHeight * 0.02),
                Text(
                  "Score: $userScore",
                  style: TextStyle(
                    fontSize: scoreFontSize.clamp(20.0, 35.0),
                    color: Colors.white,
                    fontFamily: 'Doto',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: availableHeight * 0.015),
                Text(
                  "Game Timer: ${_formatDuration(_gameTimeRemaining)}",
                  style: GoogleFonts.outfit(
                    fontSize: timerFontSize.clamp(12.0, 18.0),
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: availableHeight * 0.015),
                SizedBox(
                  height: timerSize.clamp(50.0, 75.0),
                  width: timerSize.clamp(50.0, 75.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _questionTimerController.value,
                        strokeWidth: 10,
                        color: Colors.red,
                        backgroundColor: Colors.grey,
                      ),
                      Text(
                        "${_questionTimeRemaining.inSeconds}",
                        style: GoogleFonts.outfit(
                          fontSize: (timerSize * 0.35).clamp(16.0, 26.0),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Middle section: Question
            Padding(
              padding: EdgeInsets.symmetric(horizontal: availableWidth * 0.05),
              child: AutoSizeText(
                unescapedQuestion,
                style: GoogleFonts.outfit(
                  fontSize: questionFontSize.clamp(16.0, 24.0),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                minFontSize: 12,
              ),
            ),

            // Bottom section: Options and Result
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showOptions)
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: availableWidth * 0.05),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: options.map((option) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: availableHeight * 0.015),
                              child: SizedBox(
                                width: availableWidth * 0.55, // Reduced from 0.9 to 0.7
                                height: buttonHeight.clamp(30.0, 50.0),
                                child: ElevatedButton(
                                  onPressed: isAnswering
                                      ? null
                                      : () => _verifyAnswer(option),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: availableWidth * 0.02,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: AutoSizeText(
                                    option,
                                    style: GoogleFonts.outfit(
                                      fontSize: optionFontSize.clamp(10.0, 18.0),
                                      color: Colors.black,
                                    ),
                                    maxLines: 2,
                                    minFontSize: 8,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  if (isAnswerCorrect != null)
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: SizedBox(
                          width: availableWidth * 0.5,
                          height: availableWidth * 0.5,
                          child: AnimatedResultIcon(
                            isCorrect: isAnswerCorrect!,
                            key: ValueKey(isAnswerCorrect),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}