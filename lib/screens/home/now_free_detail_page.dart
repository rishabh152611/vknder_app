import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/now_free_model.dart';
import 'chats_page.dart';

class NowFreeDetailPage extends StatelessWidget {
  final NowFreeModel nowFreeEvent;
  const NowFreeDetailPage({Key? key, required this.nowFreeEvent}) : super(key: key);

  Future<void> _joinNowFreeAndOpenChat(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to join the chat.')),
      );
      return;
    }
    final chatDoc = FirebaseFirestore.instance.collection('nowfree_chats').doc(nowFreeEvent.id);

    await chatDoc.set({
      'groupName': nowFreeEvent.groupName,
      'groupDescription': nowFreeEvent.groupDescription,
      'groupType': nowFreeEvent.groupType,
      'time': nowFreeEvent.time,
      'location': nowFreeEvent.location,
      'contactNo': nowFreeEvent.contactNo,
    }, SetOptions(merge: true));

    final membersRef = chatDoc.collection('members').doc(user.uid);

    await membersRef.set({
      'uid': user.uid,
      'name': user.displayName ?? user.email ?? '',
      'joinedAt': FieldValue.serverTimestamp(),
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatsPage(initialTab: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String img = nowFreeEvent.imageUrl?.isNotEmpty == true
        ? nowFreeEvent.imageUrl!
        : 'assets/images/now_free.jpg';

    return Scaffold(
      backgroundColor: const Color(0xFF1A0033),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0033),
        elevation: 0,
        title: Text(
          nowFreeEvent.groupName,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: img.startsWith('http')
                  ? Image.network(
                img,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF21003A),
                  child: const Icon(Icons.broken_image, color: Colors.white54, size: 40),
                ),
              )
                  : Image.asset(
                img,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF21003A),
                  child: const Icon(Icons.broken_image, color: Colors.white54, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Text(
              nowFreeEvent.groupName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Text(
              nowFreeEvent.groupDescription,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.group, color: Colors.pinkAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  nowFreeEvent.groupType,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.pinkAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  nowFreeEvent.location,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.pinkAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  nowFreeEvent.time,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.phone, color: Colors.pinkAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  nowFreeEvent.contactNo,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const Text(
              "About this quick event",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
            child: Text(
              nowFreeEvent.groupDescription,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => _joinNowFreeAndOpenChat(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Join Now Free"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
