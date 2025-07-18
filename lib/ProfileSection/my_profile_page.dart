import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        setState(() {
          userData = Map<String, dynamic>.from(snapshot.value as Map);
          isLoading = false;
        });
      } else {
        setState(() {
          userData = null;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
    // Optionally, navigate to login page instead
    // Navigator.pushReplacementNamed(context, '/login');
  }

  Widget _profileField({required String label, required String value, required IconData icon}) {
    return Card(
      color: Colors.white.withOpacity(0.09),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.pinkAccent),
        title: Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
    }
    if (userData == null) {
      return const Center(child: Text('No profile data found.', style: TextStyle(color: Colors.white)));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        _profileField(label: 'Name', value: userData?['name'] ?? '', icon: Icons.person),
        _profileField(label: 'Company', value: userData?['company'] ?? '', icon: Icons.business_center),
        _profileField(label: 'Phone', value: userData?['phone'] ?? '', icon: Icons.phone),
        _profileField(label: 'Email', value: userData?['email'] ?? '', icon: Icons.email),
        _profileField(label: 'Location', value: userData?['location'] ?? '', icon: Icons.location_on),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 4,
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF2E004F),
                  title: const Text('Log Out', style: TextStyle(color: Colors.white)),
                  content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel', style: TextStyle(color: Colors.pinkAccent)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Log Out', style: TextStyle(color: Colors.pinkAccent)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _logout(context);
              }
            },
          ),
        ),
      ],
    );
  }
}
