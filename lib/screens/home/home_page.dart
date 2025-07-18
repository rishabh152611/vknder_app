import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'events_section.dart';
import 'package:vknder_test/ProfileSection/profile_section.dart';
import 'chats_page.dart';
import 'notifications_page.dart'; // merged notifications/requests
import 'create_event_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String userName = '';
  bool isLoading = true;
  int _unreadChats = 0;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                userName = userData['name'] ?? '';
                isLoading = false;
              });
            }
          });
        }
      } else {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                userName = '';
                isLoading = false;
              });
            }
          });
        }
      }
    } else {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              userName = '';
              isLoading = false;
            });
          }
        });
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openNotificationsPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => NotificationsPage()));
  }

  Widget? _buildFAB() {
    if (_selectedIndex == 0) {
      return FloatingActionButton(
        backgroundColor: const Color(0xFFE23744),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventPage()),
          );
        },
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        tooltip: "Create Event",
      );
    }
    return null;
  }

  // Defer setState for unread count to avoid setState in build
  void _updateUnreadChats(int count) {
    if (_unreadChats != count) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _unreadChats = count);
      });
    }
  }

  Widget get appBarTitle => Row(
    mainAxisSize: MainAxisSize.min,
    children: const [
      Icon(Icons.filter_vintage, color: Colors.pinkAccent, size: 28),
      SizedBox(width: 10),
      Text(
        'vknder',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    ],
  );

  final Color bgColor = const Color(0xFF1A0033);

  @override
  Widget build(BuildContext context) {
    final List<Widget> sections = [
      EventsSection(userName: userName),
      ChatsPage(onUnreadCount: _updateUnreadChats),
      ProfileSection(userName: userName, onProfileUpdated: fetchUserName),
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: appBarTitle,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: _openNotificationsPage,
            tooltip: "Notifications",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : sections[_selectedIndex],
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2E085F),
        selectedItemColor: const Color(0xFFE23744),
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Events'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.message_outlined),
                if (_unreadChats > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$_unreadChats',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
