import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flag/flag.dart';


class CountryDropdown extends StatefulWidget {
  final ValueChanged<Country> onCountrySelected;

  CountryDropdown({required this.onCountrySelected});

  @override
  _CountryDropdownState createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  Country? _selectedCountry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double dropdownWidth = constraints.maxWidth * 0.5;

        return Center(
          child: Container(
            width: dropdownWidth,
            child: GestureDetector(
              onTap: () {
                _showCountryPicker(context);
              },
              child: Container(
                width: dropdownWidth,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.white12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (_selectedCountry != null)
                          Flag.fromString(_selectedCountry!.countryCode, height: 20, width: 30),
                        const SizedBox(width: 8),
                        Text(
                          _selectedCountry?.name ?? "Country",
                          style: GoogleFonts.outfit(
                            textStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_down, size: 20, color: Colors.black),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false, // Enable phone codes if needed
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
        widget.onCountrySelected(country);
      },
      countryListTheme: CountryListThemeData(
        inputDecoration: InputDecoration(
          hintText: "Search",
          hintStyle: GoogleFonts.outfit(
            textStyle: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
        ),
        borderRadius: BorderRadius.circular(25),
        backgroundColor: Colors.black87,
        textStyle: GoogleFonts.outfit(
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        flagSize: 0.0,
      ),
    );
  }
}
