import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final now = DateTime.now().toUtc();

    return Scaffold(
      backgroundColor: const Color(0xFF1A0033),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0033),
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
          }
          final docs = snapshot.data?.docs ?? [];
          final List<Widget> notifications = [];

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final String eventId = doc.id;
            final String eventName = data['groupName'] ?? 'Event';
            final String eventType = data['eventType'] ?? '';
            final String? creator = data['createdBy'];
            final String timeStr = data['time'] ?? '';
            DateTime? eventTime;
            try {
              eventTime = DateTime.parse(timeStr).toUtc();
            } catch (e) {
              continue;
            }

            if (creator == myUid && eventTime != null) {
              final expiryTime = eventTime.add(const Duration(minutes: 1));
              if (now.isAfter(expiryTime) && (data['expiredNotified'] != true)) {
                notifications.add(
                  ExpiredEventNotificationCard(
                    eventId: eventId,
                    eventName: eventName,
                    eventType: eventType,
                    eventData: data,
                  ),
                );
              }
            }
          }

          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                "No notifications yet.",
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: notifications,
          );
        },
      ),
    );
  }
}

class ExpiredEventNotificationCard extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String eventType;
  final Map<String, dynamic> eventData;

  const ExpiredEventNotificationCard({
    required this.eventId,
    required this.eventName,
    required this.eventType,
    required this.eventData,
  });

  @override
  State<ExpiredEventNotificationCard> createState() => _ExpiredEventNotificationCardState();
}

class _ExpiredEventNotificationCardState extends State<ExpiredEventNotificationCard> {
  int _currentMembers = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentMembers();
  }

  Future<void> _fetchCurrentMembers() async {
    final membersSnapshot = await FirebaseFirestore.instance
        .collection('event_chats')
        .doc(widget.eventId)
        .collection('members')
        .get();
    setState(() {
      _currentMembers = membersSnapshot.docs.where((doc) => doc.id != 'vknder_admin_7704900522').length;
      _loading = false;
    });
  }

  Future<void> _showRepublishDialog(BuildContext context) async {
    final data = widget.eventData;
    final TextEditingController nameController = TextEditingController(text: data['groupName'] ?? '');
    final TextEditingController descController = TextEditingController(text: data['groupDescription'] ?? '');
    final TextEditingController locationController = TextEditingController(text: data['location'] ?? '');
    final TextEditingController venueController = TextEditingController(text: data['venue'] ?? '');
    int minPeople = (data['minPeople'] ?? (_currentMembers + 1)) <= _currentMembers
        ? _currentMembers + 1
        : (data['minPeople'] ?? (_currentMembers + 1));
    int maxPeople = (data['maxPeople'] ?? (minPeople + 1)) <= _currentMembers
        ? _currentMembers + 2
        : (data['maxPeople'] ?? (minPeople + 1));
    DateTime? newTime = DateTime.tryParse(data['time'] ?? '');
    String? errorText;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2E004F),
              title: const Text('Republish Event', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Event Name', labelStyle: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locationController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Location', labelStyle: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: venueController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Venue', labelStyle: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: minPeople.toString(),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Min People',
                              labelStyle: const TextStyle(color: Colors.white70),
                              helperText: '> $_currentMembers',
                              helperStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                            onChanged: (val) {
                              int v = int.tryParse(val) ?? (_currentMembers + 1);
                              if (v <= _currentMembers) v = _currentMembers + 1;
                              if (v >= maxPeople) {
                                setState(() {
                                  errorText = 'Min must be less than Max';
                                });
                              } else {
                                setState(() {
                                  errorText = null;
                                });
                              }
                              setState(() => minPeople = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: maxPeople.toString(),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Max People',
                              labelStyle: const TextStyle(color: Colors.white70),
                              helperText: '> Min and > $_currentMembers',
                              helperStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                            onChanged: (val) {
                              int v = int.tryParse(val) ?? (minPeople + 1);
                              if (v <= _currentMembers) v = _currentMembers + 2;
                              if (v <= minPeople) {
                                setState(() {
                                  errorText = 'Max must be greater than Min';
                                });
                              } else {
                                setState(() {
                                  errorText = null;
                                });
                              }
                              setState(() => maxPeople = v);
                            },
                          ),
                        ),
                      ],
                    ),
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(errorText!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                      ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        newTime == null
                            ? "Pick new date & time"
                            : DateFormat('d MMM yyyy, h:mm a').format(newTime ?? DateTime.now()),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      trailing: const Icon(Icons.edit, color: Colors.pinkAccent),
                      onTap: () async {
                        final now = DateTime.now();
                        final date = await showDatePicker(
                          context: ctx,
                          initialDate: newTime ?? now,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 90)),
                          builder: (context, child) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: const Color(0xFFE23744),
                                onPrimary: Colors.white,
                                surface: const Color(0xFF4B0082),
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (date == null) return;
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(newTime ?? DateTime.now()),
                          builder: (context, child) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: const Color(0xFFE23744),
                                onPrimary: Colors.white,
                                surface: const Color(0xFF4B0082),
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (time == null) return;
                        setState(() {
                          newTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.pinkAccent)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                  onPressed: () async {
                    if (newTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick a new date and time.')));
                      return;
                    }
                    if (minPeople <= _currentMembers) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Min People must be greater than current members ($_currentMembers).'),
                        backgroundColor: Colors.redAccent,
                      ));
                      return;
                    }
                    if (maxPeople <= _currentMembers) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Max People must be greater than current members ($_currentMembers).'),
                        backgroundColor: Colors.redAccent,
                      ));
                      return;
                    }
                    if (maxPeople <= minPeople) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Max People must be greater than Min People.'),
                        backgroundColor: Colors.redAccent,
                      ));
                      return;
                    }
                    await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
                      'groupName': nameController.text.trim(),
                      'groupDescription': descController.text.trim(),
                      'location': locationController.text.trim(),
                      'venue': venueController.text.trim(),
                      'minPeople': minPeople,
                      'maxPeople': maxPeople,
                      'time': newTime!.toIso8601String(),
                      'expiredNotified': false, // Allow event to show up again
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event republished!')));
                  },
                  child: const Text('Republish'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _ignoreAndContinueWithCurrentMembers(BuildContext context) async {
    await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
      'expiredNotified': true,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event removed from events list.')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
    }
    return Card(
      color: Colors.white.withOpacity(0.10),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.pinkAccent,
                child: Icon(Icons.event_busy, color: Colors.white),
              ),
              title: Text(
                "Your event \"${widget.eventName}\" has expired.",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                "You have $_currentMembers member(s) in the group. "
                    "Press IGNORE to accept current members and remove from listed events, or REPUBLISH to continue with more members.",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.pinkAccent),
                    foregroundColor: Colors.pinkAccent,
                  ),
                  onPressed: () => _showRepublishDialog(context),
                  child: const Text("Republish"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                  onPressed: () => _ignoreAndContinueWithCurrentMembers(context),
                  child: const Text("Ignore"),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
