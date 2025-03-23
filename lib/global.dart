// globals.dart

library myapp.globals;

String _timezone = ""; // Private variable

// Getter to access the timezone
String get timezone => _timezone;

// Setter to modify the timezone
set timezone(String value) {
  _timezone = value;
}
