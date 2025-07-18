import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/dummy_data.dart';
import 'uniform_card.dart';

class RequestsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A0033),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A0033),
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.filter_vintage, color: Colors.pinkAccent, size: 26),
              SizedBox(width: 10),
              Text(
                'vknder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          bottom: TabBar(
            labelColor: Colors.pinkAccent,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.pinkAccent,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: const [
              Tab(text: "Event Requests"),
              Tab(text: "Now Free Requests"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Event Requests
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4B0082), Color(0xFF1A0033)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                itemCount: requests.length,
                itemBuilder: (context, i) {
                  final req = requests[i];
                  return UniformCard(
                    avatar: req['avatar'],
                    avatarColor: Colors.pinkAccent,
                    title: req['employee'],
                    subtitle: "${req['company']} • ${req['location']}",
                    isThreeLine: true,
                    trailing: Text(
                      req['time'],
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                    ),
                    onTap: () {},
                  );
                },
              ),
            ),
            // Now Free Requests (dummy)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4B0082), Color(0xFF1A0033)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Text(
                  "Now Free Requests",
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
