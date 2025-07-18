import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'one_to_one_chat_screen.dart';

class ChatsPage extends StatelessWidget {
  final int initialTab;
  final void Function(int)? onUnreadCount;

  const ChatsPage({super.key, this.initialTab = 0, this.onUnreadCount});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A0033),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A0033),
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 18,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: TabBar(
              indicatorColor: Colors.pinkAccent,
              labelColor: Colors.pinkAccent,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontSize: 16),
              tabs: [
                Tab(
                  icon: Icon(Icons.forum, size: 26),
                  iconMargin: EdgeInsets.only(bottom: 2),
                  child: Text("Event Chats"),
                ),
                Tab(
                  icon: Icon(Icons.star, size: 26),
                  iconMargin: EdgeInsets.only(bottom: 2),
                  child: Text("Favorites"),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _EventChatsSection(onUnreadCount: onUnreadCount),
            const _FavoritesSection(),
          ],
        ),
      ),
    );
  }
}

class _EventChatsSection extends StatelessWidget {
  final void Function(int)? onUnreadCount;
  static const vknderAdminUid = 'vknder_admin_7704900522';

  const _EventChatsSection({this.onUnreadCount});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text("Please sign in to view chats.", style: TextStyle(color: Colors.white70, fontSize: 18)),
      );
    }

    final Stream<QuerySnapshot> chatStream = FirebaseFirestore.instance
        .collection('event_chats')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: chatStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
        }
        final docs = snapshot.data!.docs;
        List<Widget> chatTiles = [];
        int totalUnread = 0;

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final groupId = doc.id;
          final groupName = data['title'] ?? data['groupName'] ?? 'Group Chat';

          if (user.uid == vknderAdminUid) {
            // Admin: show all groups, unread badge always 0 for admin
            chatTiles.add(_GroupChatListTile(
              groupName: groupName,
              unreadCount: 0,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      groupId: groupId,
                      groupType: 'event',
                      groupName: groupName,
                      avatar: Icons.emoji_events,
                    ),
                  ),
                );
              },
            ));
          } else {
            // Normal user: show only if member
            chatTiles.add(
              StreamBuilder<DocumentSnapshot>(
                stream: doc.reference.collection('members').doc(user.uid).snapshots(),
                builder: (context, memberSnap) {
                  if (!memberSnap.hasData || !memberSnap.data!.exists) return const SizedBox();
                  final memberData = memberSnap.data!.data() as Map<String, dynamic>? ?? {};
                  final lastReadMsgId = memberData['lastReadMsgId'];

                  return StreamBuilder<QuerySnapshot>(
                    stream: doc.reference.collection('messages').orderBy('createdAt', descending: false).snapshots(),
                    builder: (context, msgSnap) {
                      int unreadCount = 0;
                      if (msgSnap.hasData) {
                        final msgs = msgSnap.data!.docs;
                        if (msgs.isNotEmpty) {
                          if (lastReadMsgId == null) {
                            unreadCount = msgs.length;
                          } else {
                            int lastReadIndex = msgs.indexWhere((m) => m.id == lastReadMsgId);
                            unreadCount = lastReadIndex == -1
                                ? msgs.length
                                : msgs.length - (lastReadIndex + 1);
                          }
                        }
                      }
                      totalUnread += unreadCount;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (onUnreadCount != null) onUnreadCount!(totalUnread);
                      });

                      return _GroupChatListTile(
                        groupName: groupName,
                        unreadCount: unreadCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                groupId: groupId,
                                groupType: 'event',
                                groupName: groupName,
                                avatar: Icons.emoji_events,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            );
          }
        }

        if (chatTiles.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (onUnreadCount != null) onUnreadCount!(0);
          });
          return const Center(
            child: Text(
              "No Event Chats yet. Join an event to start chatting!",
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          children: chatTiles,
        );
      },
    );
  }
}

class _GroupChatListTile extends StatelessWidget {
  final String groupName;
  final int unreadCount;
  final VoidCallback onTap;

  const _GroupChatListTile({
    required this.groupName,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2E004F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Colors.pinkAccent,
          child: const Icon(Icons.emoji_events, color: Colors.white),
        ),
        title: Text(
          groupName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_forward_ios, color: Colors.pinkAccent, size: 20),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _FavoritesSection extends StatelessWidget {
  const _FavoritesSection();

  Future<String> getPeerName(String peerUid, String? fallback) async {
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    final doc = await FirebaseFirestore.instance.collection('users').doc(peerUid).get();
    final data = doc.data();
    if (data != null) {
      final name = data['name'] as String?;
      final email = data['email'] as String?;
      if (name != null && name.trim().isNotEmpty) return name;
      if (email != null && email.trim().isNotEmpty) return email;
    }
    return peerUid;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text(
          "Please sign in to view favorites.",
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      );
    }

    final favMembersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc('members')
        .collection('members');

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4B0082), Color(0xFF1A0033)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: favMembersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No favorite members yet.\nAccept requests or mark members as favorite to chat with them here!",
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final memberUid = docs[i].id;
              final memberNameRaw = data['name'] as String?;

              return FutureBuilder<String>(
                future: getPeerName(memberUid, memberNameRaw),
                builder: (context, nameSnap) {
                  final memberName = nameSnap.data ?? memberUid;
                  return Card(
                    color: const Color(0xFF2E004F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.pinkAccent,
                        child: Text(
                          memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      title: Text(
                        memberName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chat, color: Colors.pinkAccent, size: 22),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OneToOneChatScreen(
                              peerUid: memberUid,
                              peerName: memberName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}