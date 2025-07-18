import 'package:flutter/material.dart';
import 'my_profile_page.dart';
import 'my_requests_page.dart';
import 'my_events_page.dart';

class ProfileSection extends StatefulWidget {
  final String userName;
  final VoidCallback? onProfileUpdated;
  const ProfileSection({super.key, required this.userName, this.onProfileUpdated});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0033),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0033),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 0,

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.pinkAccent,
          labelColor: Colors.pinkAccent,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          tabs: const [
            Tab(icon: Icon(Icons.person), text: "Profile"),
            Tab(icon: Icon(Icons.assignment), text: "Requests"),
            Tab(icon: Icon(Icons.event), text: "My Events"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MyProfilePage(),
          MyRequestsPage(),
          MyEventsPage(),
        ],
      ),
    );
  }
}
