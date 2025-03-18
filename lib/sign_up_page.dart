import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:trivia_ui/country_dropdown.dart';
import 'package:trivia_ui/custom_bottom_nav.dart';
import 'package:trivia_ui/custom_music_player.dart';
import 'dart:convert';
import 'auth_service.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  String? token;
  String? _errorMessage;
  bool _isLoading = false;
  Country? _selectedCountry;

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _redirectToHomeIfNotSignedIn();
  }

  Future<void> _redirectToHomeIfNotSignedIn() async {
    token = await AuthService().getToken();
    if (token != null) {
      Navigator.pushReplacementNamed(context, '/');
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

      default:
        break;
    }
  }

  Future<void> _signUp() async {

    var country = _selectedCountry;
    var countryCd = "unset";

    if (country != null){
      countryCd = country.countryCode;
    }

    bool requiredFields = _passwordController.text.trim().length == 0 || _confirmPasswordController.text.trim().length == 0
        || _usernameController.text.trim().length == 0 || countryCd == "unset";

    if (requiredFields){
      setState(() {
        _errorMessage = "All fields are required.";
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords do not match.";
      });
      return;
    }

    if (_usernameController.text.trim().length > 10){
      setState(() {
        _errorMessage = "Username can't be greater than 10 characters.";
      });
      return;
    }

    if (_passwordController.text.trim().length < 6){
      setState(() {
        _errorMessage = "Password must be at least 6 characters.";
      });
      return;
    }

    if (_passwordController.text.trim().contains(" ")){
      setState(() {
        _errorMessage = "Password cannot contain spaces.";
      });
      return;
    }

    if (_usernameController.text.trim().contains(" ")){
      setState(() {
        _errorMessage = "Username cannot contain spaces.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
      String url = baseUrl+"/v1/auth/register";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": _usernameController.text,
          "password": _passwordController.text,
          "country": countryCd
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(
          context,
          '/login',
          arguments: "Account created successfully! Please log in.",
        );
      }
      else if (response.statusCode == 429) {
        setState(() {
          _errorMessage = "Too many attempts. Please try in a couple minutes.";
        });
      } else {
        setState(() {
          _errorMessage = json.decode(response.body)['error'] ?? "Sign-up failed.";
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

  //Widget _buildDropDownMenu

  Widget _buildTextField(String label, TextEditingController controller, bool obscureText,
      FocusNode focusNode, FocusNode? nextFocusNode) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4, // 80% of page width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              obscureText: obscureText,
              focusNode: focusNode,
              textInputAction: nextFocusNode == null ? TextInputAction.done : TextInputAction.next,
              onSubmitted: (_) {
                if (nextFocusNode != null) {
                  FocusScope.of(context).requestFocus(nextFocusNode); // Move to the next field
                } else {
                  _signUp(); // Trigger submit when Enter is pressed on Confirm Password field
                }
              },
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: label, // Dynamic placeholder
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
          ],
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
          SimpleAudioPlayer(),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Sign Up",
                      style: TextStyle(
                          fontSize: 48,
                          fontFamily: 'Doto',
                          fontWeight: FontWeight.w900,
                          color: Colors.white
                      )
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Join us! Create an account to start.",
                      style: GoogleFonts.outfit(
                        textStyle: GoogleFonts.outfit(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 20),
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
                        ),
                      ),
                    ],
                    SizedBox(height: 20),
                    _buildTextField("username", _usernameController, false, _usernameFocus, _passwordFocus),
                    SizedBox(height: 20),
                    _buildTextField("password", _passwordController, true, _passwordFocus, _confirmPasswordFocus),
                    SizedBox(height: 20),
                    _buildTextField("confirm password", _confirmPasswordController, true, _confirmPasswordFocus, null),
                    SizedBox(height: 20),
                    CountryDropdown(
                      onCountrySelected: (country) {
                        setState(() {
                          _selectedCountry = country;
                        });
                      },
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
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
                      onPressed: _isLoading ? null : _browseToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.black)
                          : Text(
                        "Already have an account? Log in",
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
        ],
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: _selectedIndex,
          onTap: _onBottomNavigationTapped, isAuthenticated: token != null)
    );
  }

  void _browseToLogin(){
    Navigator.pushNamed(context, '/login');
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
