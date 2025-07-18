import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class GiveInfoPage extends StatefulWidget {
  static const routeName = '/give-info';

  @override
  _GiveInfoPageState createState() => _GiveInfoPageState();
}

class _GiveInfoPageState extends State<GiveInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedGender;
  String? _selectedLocation;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _locations = ['Bangalore', 'Delhi NCR'];

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
      await dbRef.set({
        'name': _nameController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'gender': _selectedGender ?? '',
        'email': _emailController.text.trim(),
        'location': _selectedLocation ?? '',
        'emailVerified': false,
      });
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushReplacementNamed('/home');
  }

  InputDecoration _inputDecoration(String label, {Widget? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: icon,
      filled: true,
      fillColor: Colors.white12,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themePink = const Color(0xFFE23744);
    final themePurple = const Color(0xFF1A0033);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/logo.jpeg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themePurple.withOpacity(0.93),
                  themePink.withOpacity(0.80),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 420,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'vknder',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 8,
                              offset: Offset(2, 2),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tell us about yourself',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          'Note: These data cannot be edited once entered.',
                          style: GoogleFonts.poppins(
                            color: Colors.pinkAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Name
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: _inputDecoration('Name', icon: const Icon(Icons.person, color: Colors.white70)),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Age
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: _inputDecoration('Age', icon: const Icon(Icons.cake, color: Colors.white70)),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your age';
                          }
                          final age = int.tryParse(val);
                          if (age == null || age <= 0) {
                            return 'Please enter a valid age';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Gender Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        dropdownColor: themePurple,
                        decoration: _inputDecoration('Gender', icon: const Icon(Icons.wc, color: Colors.white70)),
                        items: _genders
                            .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g, style: const TextStyle(color: Colors.white)),
                        ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedGender = val),
                        validator: (val) => val == null ? 'Please select your gender' : null,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        iconEnabledColor: Colors.white70,
                      ),
                      const SizedBox(height: 18),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: _inputDecoration('Email', icon: const Icon(Icons.email, color: Colors.white70)),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                          if (!emailRegex.hasMatch(val)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Location Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedLocation,
                        dropdownColor: themePurple,
                        decoration: _inputDecoration('Location', icon: const Icon(Icons.location_on, color: Colors.white70)),
                        items: _locations
                            .map((loc) => DropdownMenuItem(
                          value: loc,
                          child: Text(loc, style: const TextStyle(color: Colors.white)),
                        ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedLocation = val),
                        validator: (val) => val == null ? 'Please select your location' : null,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        iconEnabledColor: Colors.white70,
                      ),
                      const SizedBox(height: 32),

                      _isLoading
                          ? const CircularProgressIndicator(color: Color(0xFFE23744))
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themePink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
