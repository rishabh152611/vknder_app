import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/event_model.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatefulWidget {
  final EventModel event;
  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  bool _joined = false;
  bool _loading = true;
  int _membersCount = 0;
  static const vknderAdminUid = 'vknder_admin_7704900522';

  @override
  void initState() {
    super.initState();
    _checkIfJoined();
    _fetchMembersCount();
  }

  Future<void> _checkIfJoined() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _joined = false;
        _loading = false;
      });
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('event_chats')
        .doc(widget.event.id)
        .collection('members')
        .doc(user.uid)
        .get();
    setState(() {
      _joined = doc.exists;
      _loading = false;
    });
  }

  Future<void> _fetchMembersCount() async {
    final membersSnapshot = await FirebaseFirestore.instance
        .collection('event_chats')
        .doc(widget.event.id)
        .collection('members')
        .get();
    setState(() {
      _membersCount = membersSnapshot.docs.where((doc) => doc.id != vknderAdminUid).length;
    });
  }

  Future<void> _joinEventAndOpenChat(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to join the chat.')),
      );
      return;
    }

    final chatDocRef = FirebaseFirestore.instance.collection('event_chats').doc(widget.event.id);

    // 1. Ensure chat group exists
    final chatDocSnap = await chatDocRef.get();
    if (!chatDocSnap.exists) {
      final eventDocSnap = await FirebaseFirestore.instance.collection('events').doc(widget.event.id).get();
      if (eventDocSnap.exists) {
        final eventData = eventDocSnap.data()!;
        await chatDocRef.set({
          ...eventData,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await chatDocRef.set({
          'eventType': widget.event.eventType,
          'groupName': widget.event.groupName,
          'groupDescription': widget.event.groupDescription,
          'groupType': widget.event.groupType,
          'peopleNeeded': widget.event.peopleNeeded,
          'minPeople': widget.event.minPeople,
          'maxPeople': widget.event.maxPeople,
          'location': widget.event.location,
          'time': widget.event.time,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    // 2. Check maxPeople (excluding admin)
    final membersSnapshot = await chatDocRef.collection('members').get();
    final currentCount = membersSnapshot.docs.where((doc) => doc.id != vknderAdminUid).length;
    if (widget.event.maxPeople != null && currentCount >= widget.event.maxPeople!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group is full.')),
      );
      return;
    }

    // 3. Add user as member
    await chatDocRef.collection('members').doc(user.uid).set({
      'uid': user.uid,
      'name': user.displayName ?? user.email ?? '',
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // 4. Add admin as member if not present
    final adminDoc = await chatDocRef.collection('members').doc(vknderAdminUid).get();
    if (!adminDoc.exists) {
      await chatDocRef.collection('members').doc(vknderAdminUid).set({
        'uid': vknderAdminUid,
        'name': 'Saurabh',
        'phone': '7704900522',
        'joinedAt': FieldValue.serverTimestamp(),
        'isAdmin': true,
      });
    }

    // 5. Explicitly confirm user is a member before navigating
    bool isMember = false;
    for (int tries = 0; tries < 5; tries++) {
      final confirmMemberDoc = await chatDocRef.collection('members').doc(user.uid).get();
      if (confirmMemberDoc.exists) {
        isMember = true;
        break;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (!isMember) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join the group. Please try again.')),
      );
      return;
    }

    setState(() {
      _joined = true;
      _membersCount = currentCount + 1;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            groupId: widget.event.id,
            groupType: 'event',
            groupName: widget.event.groupName,
            avatar: Icons.emoji_events,
          ),
        ),
      );
    }
  }

  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('d MMM h:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }

  Widget _buildPeopleChips(int? min, int? max, int joined) {
    return Row(
      children: [
        Chip(
          label: Text(
            min != null ? "Min $min" : "Min -",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.pinkAccent.withOpacity(0.7),
        ),
        const SizedBox(width: 10),
        Chip(
          label: Text(
            max != null ? "Max $max" : "Max -",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.purpleAccent.withOpacity(0.7),
        ),
        const SizedBox(width: 10),
        Chip(
          label: Text(
            "Joined $joined",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.greenAccent.withOpacity(0.7),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final now = DateTime.now().toUtc();
    final eventTime = DateTime.tryParse(event.time)?.toUtc();
    final isExpired = eventTime != null && eventTime.isBefore(now);

    return Scaffold(
      backgroundColor: const Color(0xFF1A0033),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0033),
        elevation: 0,
        title: Text(
          event.groupName,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 22),
        children: [
          Row(
            children: [
              const Icon(Icons.category, color: Colors.pinkAccent, size: 22),
              const SizedBox(width: 8),
              Text(
                event.eventType,
                style: const TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.groupName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            event.groupDescription,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Icon(Icons.group, color: Colors.pinkAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                event.groupType,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildPeopleChips(event.minPeople, event.maxPeople, _membersCount),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.pinkAccent, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  event.location,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.schedule, color: Colors.pinkAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                _formatDateTime(event.time),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 38),
          if (!isExpired)
            Center(
              child: ElevatedButton.icon(
                onPressed: _joined ? null : () => _joinEventAndOpenChat(context),
                icon: Icon(_joined ? Icons.check_circle : Icons.check_circle_outline),
                label: Text(_joined ? "Joined" : "Join Event"),
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
          if (isExpired)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Center(
                child: Text(
                  "This event has ended.",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
