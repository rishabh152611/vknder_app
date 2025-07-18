import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String groupType; // 'event' or 'nowfree'
  final String groupName;
  final IconData avatar;

  const ChatScreen({
    super.key,
    required this.groupId,
    required this.groupType,
    required this.groupName,
    required this.avatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _profileName;
  static const vknderAdminUid = 'vknder_admin_7704900522';
  static const vknderAdminDisplay = 'Saurabh';

  CollectionReference get groupRef => FirebaseFirestore.instance
      .collection(widget.groupType == 'event' ? 'event_chats' : 'nowfree_chats');
  CollectionReference get messagesRef => groupRef.doc(widget.groupId).collection('messages');
  CollectionReference get membersRef => groupRef.doc(widget.groupId).collection('members');

  @override
  void initState() {
    super.initState();
    _fetchProfileName();
    _ensureVknderAdminMember();
    _handleJoinGroup();
  }

  Future<void> _fetchProfileName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dbRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
      final snapshot = await dbRef.get();
      if (snapshot.exists && mounted) {
        setState(() {
          _profileName = (snapshot.value as Map)['name'] ?? user.email ?? '';
        });
      } else {
        setState(() {
          _profileName = user.email ?? '';
        });
      }
    }
  }

  Future<void> _ensureVknderAdminMember() async {
    final adminDoc = await membersRef.doc(vknderAdminUid).get();
    if (!adminDoc.exists) {
      await membersRef.doc(vknderAdminUid).set({
        'uid': vknderAdminUid,
        'name': vknderAdminDisplay,
        'phone': '7704900522',
        'joinedAt': FieldValue.serverTimestamp(),
        'isAdmin': true,
      });
    }
  }

  Future<void> _handleJoinGroup() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final memberDoc = await membersRef.doc(user.uid).get();
    if (!memberDoc.exists) {
      await membersRef.doc(user.uid).set({
        'uid': user.uid,
        'name': _profileName ?? user.email ?? '',
        'joinedAt': FieldValue.serverTimestamp(),
      });
      await messagesRef.add({
        'text': '${_profileName ?? user.email ?? 'A user'} joined the group.',
        'createdAt': FieldValue.serverTimestamp(),
        'uid': vknderAdminUid,
        'userName': 'Vknder Admin',
        'system': true,
      });
    }
    await _markAllMessagesAsRead();
  }

  void _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_controller.text.trim().isNotEmpty && user != null && _profileName != null) {
      await messagesRef.add({
        'text': _controller.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'uid': user.uid,
        'userName': _profileName,
      });
      _controller.clear();
      await _markAllMessagesAsRead();
    }
  }

  Future<void> _markAllMessagesAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final latestMsg = await messagesRef.orderBy('createdAt', descending: true).limit(1).get();
    if (latestMsg.docs.isNotEmpty) {
      final lastMsgId = latestMsg.docs.first.id;
      await membersRef.doc(user.uid).set({'lastReadMsgId': lastMsgId}, SetOptions(merge: true));
    }
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return DateFormat('hh:mm a').format(dt);
    } else {
      return DateFormat('MMM d, hh:mm a').format(dt);
    }
  }

  Future<void> _leaveGroup(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await membersRef.doc(user.uid).delete();
    await messagesRef.add({
      'text': '${_profileName ?? "A user"} left the group.',
      'createdAt': FieldValue.serverTimestamp(),
      'uid': vknderAdminUid,
      'userName': 'Vknder Admin',
      'system': true,
    });
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showLeaveGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2E004F),
        title: const Text('Leave Group', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to leave this group? You will no longer see this chat.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.pinkAccent)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _leaveGroup(context);
            },
            child: const Text('Leave', style: TextStyle(color: Colors.pinkAccent)),
          ),
        ],
      ),
    );
  }

  // --- Helper: Fetch member name from Realtime Database ---
  Future<String> getMemberName(String uid) async {
    if (uid == vknderAdminUid) {
      return vknderAdminDisplay;
    }
    final dbRef = FirebaseDatabase.instance.ref().child('users').child(uid);
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      if (data['name'] != null && data['name'].toString().isNotEmpty) {
        return data['name'];
      } else if (data['email'] != null && data['email'].toString().isNotEmpty) {
        return data['email'];
      }
    }
    return uid; // fallback to uid
  }

  void _showGroupInfoModal(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2E004F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final Color avatarBgColor = Colors.pinkAccent;
        final double maxHeight = MediaQuery.of(ctx).size.height * 0.8;
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 1,
          minChildSize: 0.5,
          initialChildSize: 0.8,
          builder: (ctx, scrollController) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .doc(widget.groupId)
                  .snapshots(),
              builder: (context, eventSnap) {
                final eventData = eventSnap.data?.data() as Map<String, dynamic>?;

                return StreamBuilder<QuerySnapshot>(
                  stream: membersRef.snapshots(),
                  builder: (context, membersSnapshot) {
                    final memberDocs = membersSnapshot.data?.docs ?? [];
                    return ListView(
                      controller: scrollController,
                      children: [
                        Center(
                          child: Container(
                            width: 60,
                            height: 6,
                            margin: const EdgeInsets.only(top: 10, bottom: 18),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: avatarBgColor,
                              radius: 26,
                              child: Icon(widget.avatar, color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.groupName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (eventData != null) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Event Info",
                                  style: TextStyle(
                                    color: Colors.pinkAccent.shade100,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule, color: Colors.pinkAccent, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      eventData['time'] != null
                                          ? DateFormat('EEE, d MMM yyyy, h:mm a').format(DateTime.parse(eventData['time']))
                                          : '-',
                                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.pinkAccent, size: 20),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        eventData['location'] ?? '-',
                                        style: const TextStyle(color: Colors.white70, fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if ((eventData['venue'] ?? '').toString().isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.place, color: Colors.pinkAccent, size: 20),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          eventData['venue'] ?? '-',
                                          style: const TextStyle(color: Colors.white70, fontSize: 15),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.people, color: Colors.pinkAccent, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Min: ${eventData['minPeople'] ?? '-'}  Max: ${eventData['maxPeople'] ?? '-'}  Joined: ${memberDocs.length}",
                                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        Text(
                          "Members (${memberDocs.length}):",
                          style: const TextStyle(
                            color: Colors.pinkAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...memberDocs.map((doc) {
                          final uid = doc.id;
                          return FutureBuilder<String>(
                            future: getMemberName(uid),
                            builder: (context, snapshot) {
                              final memberName = snapshot.data ?? '...';
                              final isAdmin = uid == vknderAdminUid;
                              final isMe = uid == myUid;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        memberName + (isAdmin ? " (Admin)" : "") + (isMe ? " (You)" : ""),
                                        style: TextStyle(
                                          color: isAdmin ? Colors.greenAccent : Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (!isMe)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.pinkAccent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: () async {
                                          final user = FirebaseAuth.instance.currentUser;
                                          if (user == null) return;
                                          if (uid == vknderAdminUid) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("You can't send requests to admin!")),
                                            );
                                            return;
                                          }
                                          if (uid == user.uid) return;

                                          // Send request to this member
                                          final senderName = _profileName ?? user.displayName ?? user.email ?? '';
                                          final senderEmail = user.email ?? '';

                                          final requestRef = FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(uid)
                                              .collection('requests')
                                              .doc(user.uid);

                                          await requestRef.set({
                                            'senderUid': user.uid,
                                            'senderName': senderName,
                                            'senderEmail': senderEmail,
                                            'createdAt': FieldValue.serverTimestamp(),
                                            'status': 'pending',
                                          });

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Request sent to $memberName!'),
                                              backgroundColor: Colors.pinkAccent,
                                            ),
                                          );
                                        },

                                        child: const Text('Send Request', style: TextStyle(fontSize: 13)),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        }).toList(),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bubbleColor = Colors.pinkAccent;
    final Color otherBubbleColor = Colors.white.withOpacity(0.09);
    final Color avatarBgColor = Colors.pinkAccent;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF1A0033),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0033),
        elevation: 0,
        title: GestureDetector(
          onTap: () => _showGroupInfoModal(context),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: avatarBgColor,
                child: Icon(widget.avatar, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget.groupName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              StreamBuilder<QuerySnapshot>(
                stream: membersRef.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final count = snapshot.data!.docs.length;
                  return Text(
                    '$count member${count == 1 ? "" : "s"}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  );
                },
              ),
              const SizedBox(width: 8),
              const Icon(Icons.info_outline, color: Colors.pinkAccent, size: 20),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'leave') _showLeaveGroupDialog(context);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'leave',
                    child: Text('Leave Group'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: messagesRef.orderBy('createdAt', descending: true).limit(50).snapshots(),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snap.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final isMe = data['uid'] == user?.uid;
                      final isSystem = data['system'] == true;
                      final time = _formatTime(data['createdAt']);
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : isSystem
                            ? Alignment.center
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSystem
                                ? Colors.pinkAccent.withOpacity(0.1)
                                : isMe
                                ? bubbleColor
                                : otherBubbleColor,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isMe ? 18 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: isSystem
                                ? CrossAxisAlignment.center
                                : CrossAxisAlignment.start,
                            children: [
                              if (!isSystem)
                                Text(
                                  data['userName'] ?? '',
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.pinkAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              Text(
                                data['text'] ?? '',
                                style: TextStyle(
                                  color: isSystem
                                      ? Colors.pinkAccent
                                      : isMe
                                      ? Colors.white
                                      : Colors.white70,
                                  fontSize: 15,
                                  fontStyle: isSystem ? FontStyle.italic : FontStyle.normal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: isMe
                                    ? MainAxisAlignment.end
                                    : isSystem
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.start,
                                children: [
                                  Text(
                                    time,
                                    style: TextStyle(
                                      color: isSystem
                                          ? Colors.pinkAccent
                                          : Colors.white54,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              color: const Color(0xFF2E004F),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Color(0xFF4B0082),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onTap: () {
                        _focusNode.requestFocus();
                        _markAllMessagesAsRead();
                      },
                      onSubmitted: (_) {
                        _sendMessage();
                        _focusNode.requestFocus();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.pinkAccent),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
