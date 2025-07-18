import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/event_model.dart';
import 'package:vknder_test/screens/home/event_detail_page.dart';
import 'package:intl/intl.dart';

class EventsInCategoryPage extends StatelessWidget {
  final String eventType;

  const EventsInCategoryPage({Key? key, required this.eventType}) : super(key: key);

  static const vknderAdminUid = 'vknder_admin_7704900522';

  String _formatDateTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return DateFormat('d MMM h:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }

  bool _isEventPast(String isoString) {
    try {
      final eventTime = DateTime.parse(isoString).toUtc();
      final now = DateTime.now().toUtc();
      return eventTime.isBefore(now);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B0082),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B0082),
        elevation: 0,
        title: Row(
          children: [
            const SizedBox(width: 10),
            Text(eventType, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .where('eventType', isEqualTo: eventType)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          // Filter out past events
          final futureDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final eventTime = data['time'] as String? ?? '';
            return !_isEventPast(eventTime);
          }).toList();

          if (futureDocs.isEmpty) {
            return const Center(
              child: Text('No upcoming events in this category', style: TextStyle(color: Colors.white70)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 10),
            itemCount: futureDocs.length,
            itemBuilder: (context, i) {
              final data = futureDocs[i].data() as Map<String, dynamic>;
              final event = EventModel.fromMap(data, id: futureDocs[i].id);

              // Listen to event_chats/{event.id}/members for real-time joined count
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('event_chats')
                    .doc(event.id)
                    .collection('members')
                    .snapshots(),
                builder: (context, membersSnapshot) {
                  if (membersSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  final membersDocs = membersSnapshot.data?.docs ?? [];
                  // Exclude admin from count
                  final joinedCount = membersDocs.where((doc) => doc.id != vknderAdminUid).length;
                  // Hide event if full, show again if not full
                  if (event.maxPeople != null && joinedCount >= event.maxPeople!) {
                    return const SizedBox.shrink();
                  }
                  return EventInfoCard(
                    event: event,
                    formatDateTime: _formatDateTime,
                    membersCount: joinedCount,
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

class EventInfoCard extends StatelessWidget {
  final EventModel event;
  final String Function(String) formatDateTime;
  final int membersCount;

  const EventInfoCard({
    Key? key,
    required this.event,
    required this.formatDateTime,
    required this.membersCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.width > 600 ? 22 : 18;
    double iconSize = MediaQuery.of(context).size.width > 600 ? 22 : 18;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 40 : 14,
        vertical: 8,
      ),
      child: Card(
        color: const Color(0xFF21003A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailPage(event: event),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.groupName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.people, color: Colors.pinkAccent, size: iconSize),
                    const SizedBox(width: 6),
                    Text(
                      "Min: ${event.minPeople ?? '-'}  Max: ${event.maxPeople ?? '-'}  Joined: $membersCount",
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.pinkAccent, size: iconSize),
                    const SizedBox(width: 6),
                    Text(
                      event.location,
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.schedule, color: Colors.pinkAccent, size: iconSize),
                    const SizedBox(width: 6),
                    Text(
                      formatDateTime(event.time),
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
