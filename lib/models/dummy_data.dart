import 'package:flutter/material.dart';
import 'event_model.dart';

// --- EXISTING DATA (UNCHANGED) ---

// Group Chats (for ChatsPage)
final List<Map<String, dynamic>> groupChats = [
  {
    "name": "Weekend Wanderers",
    "lastMessage": "See you at 7pm!",
    "time": "5:30 PM",
    "isGroup": true,
    "avatar": Icons.group,
    "messages": [
      {"from": "Shubh", "text": "Who's bringing snacks?", "me": false},
      {"from": "You", "text": "I'll get chips!", "me": true},
      {"from": "Shriya", "text": "I can bring drinks.", "me": false},
    ]
  },
  {
    "name": "Movie Buffs",
    "lastMessage": "Interstellar or Inception?",
    "time": "4:12 PM",
    "isGroup": true,
    "avatar": Icons.movie,
    "messages": [
      {"from": "You", "text": "Let's do Inception!", "me": true},
      {"from": "Anshi", "text": "Yesss!", "me": false},
    ]
  },
  {
    "name": "Foodies United",
    "lastMessage": "Pizza or Sushi tonight?",
    "time": "2:05 PM",
    "isGroup": true,
    "avatar": Icons.fastfood,
    "messages": [
      {"from": "You", "text": "Pizza always!", "me": true},
      {"from": "Dolly", "text": "Sushi for me!", "me": false},
    ]
  },
  {
    "name": "Board Gamers",
    "lastMessage": "Settlers of Catan at my place.",
    "time": "Yesterday",
    "isGroup": true,
    "avatar": Icons.sports_esports,
    "messages": [
      {"from": "Shweta", "text": "Who's in?", "me": false},
      {"from": "You", "text": "I'm in!", "me": true},
    ]
  },
];

// Requests (for RequestsPage)
final List<Map<String, dynamic>> requests = [
  {
    "employee": "Saurabh Pandey",
    "company": "Worley",
    "location": "Bangalore",
    "avatar": Icons.person,
    "time": "2 min ago"
  },
  {
    "employee": "Shriya Jalan",
    "company": "PWC",
    "location": "Bangalore",
    "avatar": Icons.person,
    "time": "10 min ago"
  },
  {
    "employee": "Sunidhi Pandey",
    "company": "HSBC",
    "location": "Bangalore",
    "avatar": Icons.person,
    "time": "15 min ago"
  },
  {
    "employee": "Rishabh Pandey",
    "company": "Google",
    "location": "Bangalore",
    "avatar": Icons.person,
    "time": "20 min ago"
  },
];

// Now Free Nearby (for NowFreeSection) with new fields venue and time
final List<Map<String, dynamic>> nowFreeNearby = [
  {
    'id': 'nf1',
    'employee': 'Saurabh Pandey',
    'company': 'Worley',
    'location': 'Nearby (0.5 km)',
    'avatar': Icons.person,
    'status': 'Wants to grab coffee',
    'venue': 'Office Canteen',
    'time': 'Now',
  },
  {
    'id': 'nf2',
    'employee': 'Shriya Jalan',
    'company': 'PWC',
    'location': 'Nearby (0.8 km)',
    'avatar': Icons.person,
    'status': 'Looking for a walk',
    'venue': 'Nearby Park',
    'time': 'Now',
  },
  {
    'id': 'nf3',
    'employee': 'Anshika Sahu',
    'company': 'Amazon',
    'location': 'Nearby (1.2 km)',
    'avatar': Icons.person,
    'status': 'Gossips about the manager',
    'venue': 'Office Lobby',
    'time': 'Now',
  },
  {
    'id': 'nf4',
    'employee': 'Rishabh Pandey',
    'company': 'Google',
    'location': 'Nearby (1.5 km)',
    'avatar': Icons.person,
    'status': 'Wants to play board games',
    'venue': 'Garden Area',
    'time': 'Now',
  },
];

// --- UPDATED EVENTS DATA ---

final List<Map<String, dynamic>> eventsRaw = [
  {
    'id': 'e1',
    'title': 'Karaoke Night',
    'subtitle': 'Sing your heart out',
    'icon': Icons.music_note,
    'color': Color(0xFF9B59B6),
    'imageUrl': 'assets/images/karaoke_night.jpg',
    'venue': 'Downtown Club',
    'time': 'June 15, 7:00 PM',
    'people': 23,
    'description': 'Join us for a fun night of karaoke, food, and friends at the Downtown Club. All are welcome!',
  },
  {
    'id': 'e2',
    'title': 'Foodies Meetup',
    'subtitle': 'Explore new cuisines',
    'icon': Icons.fastfood,
    'color': Color(0xFFE040FB),
    'imageUrl': 'assets/images/foodies_meetup.jpg',
    'venue': 'City Square',
    'time': 'June 18, 6:30 PM',
    'people': 12,
    'description': 'A gathering for food enthusiasts to try out new dishes and share recipes. Bring your appetite!',
  },
  {
    'id': 'e3',
    'title': 'Game Night',
    'subtitle': 'Board & video games',
    'icon': Icons.sports_esports,
    'color': Color(0xFF536DFE),
    'imageUrl': 'assets/images/game_night.jpg',
    'venue': 'Community Center',
    'time': 'June 20, 8:00 PM',
    'people': 16,
    'description': 'Bring your favorite games or just show up and join a table. Snacks provided.',
  },
  {
    'id': 'e4',
    'title': 'Outdoor Walk',
    'subtitle': 'Nature & fresh air',
    'icon': Icons.park,
    'color': Color(0xFF00E676),
    'imageUrl': 'assets/images/outdoor_walk.jpg',
    'venue': 'City Park Trail',
    'time': 'June 22, 9:00 AM',
    'people': 8,
    'description': 'A refreshing walk through the scenic City Park. All fitness levels are welcome.',
  },
  {
    'id': 'e5',
    'title': 'Movie Marathon',
    'subtitle': 'Binge watch classics',
    'icon': Icons.movie,
    'color': Color(0xFFFF5252),
    'imageUrl': 'assets/images/movie_marathon.jpg',
    'venue': 'The Local Cinema',
    'time': 'June 25, 2:00 PM',
    'people': 6,
    'description': 'A cozy movie marathon featuring classic films from the 90s. Popcorn and drinks on us!',
  },
  {
    'id': 'e6',
    'title': 'Art Jam',
    'subtitle': 'Paint and create',
    'icon': Icons.brush,
    'color': Color(0xFFFFA726),
    'imageUrl': 'assets/images/art_jam.jpg',
    'venue': 'The Creative Studio',
    'time': 'June 28, 4:00 PM',
    'people': 10,
    'description': 'Unleash your creativity at our collaborative art jam session. All materials will be provided.',
  },
];

// For card-based use (automatically updated):
final List<EventModel> events = eventsRaw.map((e) => EventModel.fromMap(e, id: e['id'])).toList();
