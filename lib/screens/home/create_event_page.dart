import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'chat_screen.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String? _selectedCategory;
  String? _selectedLocation;
  int? _minPeople;
  int? _maxPeople;
  DateTime? _selectedDateTime;

  final List<String> _categories = [
    'Cricket',
    'Football',
    'Gokarting',
    'Mystery Rooms',
    'Badminton',
    'Arcade Games and Laser Tag',
    'Bowling',

    'Movie',
  ];

  final List<String> _locations = [
    'Koramangala',
    'Indiranagar',
    'Whitefield',
    'HSR Layout',
    'Jayanagar',
    'Marathahalli',
    'MG Road',
    'Electronic City',
    'JP Nagar',
  ];

  final List<int> _peopleOptions = List.generate(19, (i) => i + 2); // 2 to 20

  bool _isLoading = false;

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
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
      context: context,
      initialTime: TimeOfDay.now(),
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
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time for the event.')),
      );
      return;
    }
    if (_minPeople != null && _maxPeople != null && _minPeople! > _maxPeople!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum people cannot be more than maximum people.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to create an event.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Add event to 'events' collection
      final eventDocRef = await FirebaseFirestore.instance.collection('events').add({
        'eventType': _selectedCategory,
        'groupName': _groupNameController.text.trim(),
        'groupDescription': _descController.text.trim(),
        'minPeople': _minPeople,
        'maxPeople': _maxPeople,
        'time': _selectedDateTime!.toIso8601String(),
        'location': _selectedLocation,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': user.uid,
      });

      // Add creator as member in event_chats/{eventId}/members
      final chatDocRef = FirebaseFirestore.instance.collection('event_chats').doc(eventDocRef.id);

      // Create chat document if not exists
      final chatDocSnap = await chatDocRef.get();
      if (!chatDocSnap.exists) {
        await chatDocRef.set({
          'eventType': _selectedCategory,
          'groupName': _groupNameController.text.trim(),
          'groupDescription': _descController.text.trim(),
          'minPeople': _minPeople,
          'maxPeople': _maxPeople,
          'time': _selectedDateTime!.toIso8601String(),
          'location': _selectedLocation,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Add creator as member
      await chatDocRef.collection('members').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? user.email ?? '',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // --- ADD VKNDER ADMIN AS MEMBER ---
      const vknderAdminUid = 'vknder_admin_7704900522';
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
      // --- END ADMIN ADD ---

      setState(() => _isLoading = false);

      // Navigate to chat screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              groupId: eventDocRef.id,
              groupType: 'event',
              groupName: _groupNameController.text.trim(),
              avatar: Icons.emoji_events,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    }
  }

  InputDecoration _inputDecoration(String label, {Widget? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: icon,
      filled: true,
      fillColor: const Color(0xFF4B0082),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? selectedValue,
    required ValueChanged<T?> onChanged,
    required Widget icon,
    String? hint,
  }) {
    return DropdownButtonFormField2<T>(
      value: selectedValue,
      items: items
          .map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(
          item.toString(),
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      iconStyleData: const IconStyleData(
        icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
      ),
      decoration: _inputDecoration(label, icon: icon),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 220,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: const Color(0xFF4B0082),
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 8,
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(40),
          thickness: MaterialStatePropertyAll(6),
          thumbVisibility: MaterialStatePropertyAll(true),
        ),
      ),
      hint: Text(
        hint ?? 'Select $label',
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 12;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0033),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0033),
        title: const Text('Create Event', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildDropdown<String>(
                  label: 'Event Category',
                  items: _categories,
                  selectedValue: _selectedCategory,
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  icon: const Icon(Icons.sports_soccer, color: Colors.white70),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _groupNameController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: _inputDecoration('Group Name(Should be Unique)', icon: const Icon(Icons.group, color: Colors.white70)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter group name' : null,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _descController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  maxLines: 2,
                  decoration: _inputDecoration('Short Description', icon: const Icon(Icons.description, color: Colors.white70)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 18),
                _buildDropdown<int>(
                  label: 'Min People',
                  items: _peopleOptions,
                  selectedValue: _minPeople,
                  onChanged: (val) => setState(() => _minPeople = val),
                  icon: const Icon(Icons.people, color: Colors.white70),
                ),
                const SizedBox(height: 18),
                _buildDropdown<int>(
                  label: 'Max People',
                  items: _peopleOptions,
                  selectedValue: _maxPeople,
                  onChanged: (val) => setState(() => _maxPeople = val),
                  icon: const Icon(Icons.people_outline, color: Colors.white70),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: _pickDateTime,
                  child: AbsorbPointer(
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: _inputDecoration(
                        'Time & Date',
                        icon: const Icon(Icons.access_time, color: Colors.white70),
                      ),
                      controller: TextEditingController(
                        text: _selectedDateTime == null
                            ? ''
                            : "${_selectedDateTime!.day}/${_selectedDateTime!.month}/${_selectedDateTime!.year} "
                            "${_selectedDateTime!.hour.toString().padLeft(2, '0')}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}",
                      ),
                      validator: (val) => _selectedDateTime == null ? 'Please pick a time' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildDropdown<String>(
                  label: 'Location',
                  items: _locations,
                  selectedValue: _selectedLocation,
                  onChanged: (val) => setState(() => _selectedLocation = val),
                  icon: const Icon(Icons.location_on, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFFE23744))
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE23744),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Create Event',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
