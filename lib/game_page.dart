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

    if (_gameTimeRemaining <= const Duration(seconds: 1)){
      return;
    }

    setState(() {
      isLoadingQuestion = true;
      isAnswerCorrect = null; // Reset answer status
      showOptions = true; // Show options again for the next question
      isAnswering = false; // Reset answering status
    });

    try {
      final String baseUrl = const String.fromEnvironment("url_base");
      String url = baseUrl+"/v1/questions/random";
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

    // Perform the API call to send game results
    try {
      final String baseUrl = const String.fromEnvironment("url_base");
      String apiUrl = baseUrl+"/v1/scores/save"; // Replace with your actual API URL
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          'score': userScore
        }),
      );

    } catch (e) {

    }

    // Show the game-over dialog
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
              width: MediaQuery.of(context).size.width * 0.7,
              padding: const EdgeInsets.all(24),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Text(
                        "GAME OVER",
                        style: TextStyle(
                            fontSize: constraints.maxWidth * 0.08,
                            fontFamily: 'Doto',
                            fontWeight: FontWeight.w900,
                          color: Colors.redAccent,
                        )
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Your Score: $userScore",
                    style: GoogleFonts.outfit(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Profile Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Profile",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Play Again Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(context, '/play', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Play Again",
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
              onPressed: () {
                Navigator.pop(context);
              },
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
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Customize the back arrow
          onPressed: () async {
            if (isGameStarted) {
              // Show confirmation dialog
              bool shouldExit = await _showExitConfirmationDialog();
              if (shouldExit) {
                Navigator.pop(context); // Navigate back if confirmed
              }
            } else {
              Navigator.pop(context); // Default behavior if no game is active
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
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          isGameStarted
              ? (isLoadingQuestion ? const Center(child: CircularProgressIndicator()) : _buildQuestionContent())
              : _buildStartContent(),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: SimpleAudioPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: isGameStarted
          ? null // Hides the bottom navigation bar when the game is active
          : BottomNavBar(currentIndex: _selectedIndex,
          onTap: _onBottomNavigationTapped, isAuthenticated: token != null)
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

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismiss by tapping outside
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            "Exit Game?",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          content: Text(
            "Are you sure you want to exit? Your progress will be lost.",
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Stay in the game
              child: Text(
                "Cancel",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.of(context).pop(true), // Exit the game
              child: Text(
                "Exit",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    ) ??
        false; // Return false if dialog is dismissed
  }


  Widget _buildStartContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              double fontSize = constraints.maxWidth * 0.08; // Adjust the multiplier as needed
              return Text(
                "Game Time!",
                style: TextStyle(
                  fontSize: 1.3* fontSize.clamp(24.0, 48.0), // Clamp to a min/max range
                    fontFamily: 'Doto',
                    fontWeight: FontWeight.w900,
                  color: Colors.white,
                )
              );
            },
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              "Start Game",
              style: GoogleFonts.outfit(
                textStyle: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _verifyAnswer(String selectedOption) async {
    setState(() {
      isAnswering = true;
      showOptions = true; // Keep options visible briefly for smooth transition
    });

    bool isCorrect = false;

    try {
      final String baseUrl = const String.fromEnvironment("url_base");
      String apiUrl = baseUrl+"/v1/questions/solve"; // Replace with your actual API URL
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          'qid': currentQuestion!["id"],
          'guess': selectedOption
        }),
      );

      isCorrect = json.decode(response.body)!["correctAnswer"];

    } catch (e) {

    }

    setState(() {
      isAnswerCorrect = isCorrect;

      if (isCorrect) {
        int baseScore = _calculateBaseScore(currentQuestion!["difficulty"]);
        double timeMultiplier = _questionTimeRemaining.inSeconds / 15.0;
        userScore += (baseScore * timeMultiplier).ceil();
      }
    });

    // Add a delay before hiding the options
   // await Future.delayed(const Duration(seconds: 1));

    setState(() {
      showOptions = false;
    });

    // Fetch the next question after a short delay
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
    final options = List<String>.from(currentQuestion!["allAnswers"].map((option) => unescape.convert(option)));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Score: $userScore",
              style: TextStyle(
                fontSize: 35,
                color: Colors.white,
                fontFamily: 'Doto',
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 50),
            Text(
              "Game Timer: ${_formatDuration(_gameTimeRemaining)}",
              style: GoogleFonts.outfit(
                textStyle: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 75,
                  width: 75,
                  child: CircularProgressIndicator(
                    value: _questionTimerController.value,
                    strokeWidth: 15,
                    color: Colors.red,
                    backgroundColor: Colors.grey,
                  ),
                ),
                Text(
                  "${_questionTimeRemaining.inSeconds}",
                  style: GoogleFonts.outfit(
                    textStyle: const TextStyle(fontSize: 26, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              unescapedQuestion,
              style: GoogleFonts.outfit(
                textStyle: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: showOptions ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: isAnswering
                          ? null
                          : () {
                        _verifyAnswer(option);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        option,
                        style: GoogleFonts.outfit(
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (isAnswerCorrect != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: AnimatedResultIcon(
                  isCorrect: isAnswerCorrect!,
                  key: ValueKey(isAnswerCorrect),
                ),
              ),

          ],
        ),
      ),
    );
  }

}
