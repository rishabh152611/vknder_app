import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vknder_test/screens/home/one_to_one_chat_screen.dart';

class MyRequestsPage extends StatelessWidget {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text("Sign in to see your requests.", style: TextStyle(color: Colors.white70, fontSize: 18)),
      );
    }

    final requestsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: requestsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text("No requests yet.", style: TextStyle(color: Colors.white70, fontSize: 18)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final senderUid = data['senderUid'];
            final senderNameReq = data['senderName'] ?? senderUid;
            final senderEmailReq = data['senderEmail'] ?? '';

            return Card(
              color: const Color(0xFF2E004F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.pinkAccent,
                  child: Text(
                    senderNameReq.isNotEmpty ? senderNameReq[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  senderNameReq,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(
                  senderEmailReq,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Accept"),
                  onPressed: () async {
                    // 1. Mark request as accepted
                    await docs[i].reference.update({'status': 'accepted'});

                    // 2. Fetch sender's profile (the person who sent the request)
                    final senderProfile = await FirebaseFirestore.instance.collection('users').doc(senderUid).get();
                    final senderProfileData = senderProfile.data() ?? {};
                    final senderName = senderProfileData['name'] ?? senderNameReq ?? senderUid;
                    final senderEmail = senderProfileData['email'] ?? senderEmailReq ?? '';

                    // 3. Fetch my profile (the current user accepting the request)
                    final myDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
                    final mySnapshot = await myDoc.get();
                    final myData = mySnapshot.data() as Map<String, dynamic>? ?? {};
                    final myName = myData['name'] ?? user.displayName ?? user.email ?? '';
                    final myEmail = user.email ?? '';

                    // 4. Add each other to favorites (store peer's info)
                    await myDoc.collection('favorites').doc('members').collection('members').doc(senderUid).set({
                      'uid': senderUid,
                      'name': senderName,
                      'email': senderEmail,
                      'addedAt': FieldValue.serverTimestamp(),
                    });
                    await FirebaseFirestore.instance.collection('users').doc(senderUid)
                        .collection('favorites').doc('members').collection('members').doc(user.uid).set({
                      'uid': user.uid,
                      'name': myName,
                      'email': myEmail,
                      'addedAt': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You are now connected with $senderName!'),
                        backgroundColor: Colors.pinkAccent,
                      ),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OneToOneChatScreen(
                          peerUid: senderUid,
                          peerName: senderName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
