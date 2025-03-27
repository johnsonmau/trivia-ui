import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:trivia_ui/custom_bottom_nav.dart';
import 'package:trivia_ui/custom_music_player.dart';
import 'dart:convert';
import 'auth_service.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? token;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _redirectToHomeIfNotSignedIn();
  }

  /// Redirects to home if the user is not signed in
  Future<void> _redirectToHomeIfNotSignedIn() async {
    token = await AuthService().getToken();
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/'); // Redirect to home
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve success message passed as an argument
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      setState(() {
        _successMessage = args;
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null; // Clear success message
    });

    if (_usernameController.text.trim().length == 0 &&
        _passwordController.text.trim().length == 0){
      setState(() {
        _errorMessage = "Username and password are required.";
        _isLoading = false;
      });
      return;
    }

    if (_usernameController.text.trim().length == 0){
      setState(() {
        _errorMessage = "Username is required.";
        _isLoading = false;
      });
      return;
    }

    if (_passwordController.text.trim().length == 0){
      setState(() {
        _errorMessage = "Password is required.";
        _isLoading = false;
      });
      return;
    }

    try {
      final String baseUrl = const String.fromEnvironment("url_base");
      String url = baseUrl+"/v1/auth/login";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": _usernameController.text,
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token'];

        await AuthService().saveToken(token);

        Navigator.pushReplacementNamed(
          context,
          '/profile',
        );
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = "Invalid username or password.";
        });
      } else if (response.statusCode == 429) {
        setState(() {
          _errorMessage = "Too many attempts. Please try in a couple minutes.";
        });
      } else {
        setState(() {
          _errorMessage = "An unexpected error occurred.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Unable to connect to the server.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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


  Widget _buildTextField(String label, TextEditingController controller, bool obscureText, FocusNode focusNode, FocusNode? nextFocusNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.4, // 80% of page width
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              focusNode: focusNode,
              textInputAction: nextFocusNode == null ? TextInputAction.done : TextInputAction.next,
              onSubmitted: (_) {
                if (nextFocusNode != null) {
                  FocusScope.of(context).requestFocus(nextFocusNode); // Move to next field
                } else {
                  _login(); // Submit when Enter is pressed in password field
                }
              },
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: label, // Placeholder text
                hintStyle: GoogleFonts.outfit(
                  textStyle: TextStyle(color: Colors.white54),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_successMessage != null) ...[
                      Text(
                        _successMessage!,
                        style: GoogleFonts.outfit(
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                    Text(
                      "Login",
                      style: TextStyle(
                          fontSize: 48,
                          fontFamily: 'Doto',
                          fontWeight: FontWeight.w900,
                          color: Colors.white
                        )
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Welcome back! Log in to continue.",
                      style: GoogleFonts.outfit(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: GoogleFonts.outfit(
                          textStyle: GoogleFonts.outfit(
                                textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                ),
                          )
                        )
                      ),
                      SizedBox(height: 20),
                    ],
                    _buildTextField("username", _usernameController, false, _usernameFocus, _passwordFocus),
                    SizedBox(height: 20),
                    _buildTextField("password", _passwordController, true, _passwordFocus, null),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.black)
                          : Text(
                        "Submit",
                        style: GoogleFonts.outfit(
                          textStyle: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _browseToSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Sign up Instead",
                        style: GoogleFonts.outfit(
                          textStyle: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
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
      bottomNavigationBar: BottomNavBar(currentIndex: _selectedIndex,
          onTap: _onBottomNavigationTapped, isAuthenticated: token != null)
    );
  }

  void _browseToSignup(){
    Navigator.pushNamed(context, '/signup');
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

}
