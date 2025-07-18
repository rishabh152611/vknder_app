// lib/screens/home/create_now_free_event_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateNowFreeEventPage extends StatefulWidget {
  const CreateNowFreeEventPage({Key? key}) : super(key: key);

  @override
  State<CreateNowFreeEventPage> createState() => _CreateNowFreeEventPageState();
}

class _CreateNowFreeEventPageState extends State<CreateNowFreeEventPage> {
  final _formKey = GlobalKey<FormState>();
  String groupName = '';
  String groupDescription = '';
  String groupType = '';
  int peopleNeeded = 1;
  String location = '';
  String time = '';
  String contactNo = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E004F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E004F),
        elevation: 0,
        title: const Text('Create Now Free Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: const Color(0xFF4B0082),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Now Free Event Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        label: 'Event Name',
                        onSaved: (val) => groupName = val ?? '',
                        validator: (val) => val == null || val.isEmpty ? 'Enter event name' : null,
                      ),
                      _buildTextField(
                        label: 'Short Description',
                        onSaved: (val) => groupDescription = val ?? '',
                        validator: (val) => val == null || val.isEmpty ? 'Enter description' : null,
                      ),
                      _buildTextField(
                        label: 'Type (optional, e.g. Mixed/Only Male/Only Female)',
                        onSaved: (val) => groupType = val ?? '',
                      ),
                      _buildTextField(
                        label: 'People Needed',
                        keyboardType: TextInputType.number,
                        onSaved: (val) => peopleNeeded = int.tryParse(val ?? '1') ?? 1,
                        validator: (val) => val == null || val.isEmpty ? 'Enter number' : null,
                      ),
                      _buildTextField(
                        label: 'Time',
                        onSaved: (val) => time = val ?? '',
                        validator: (val) => val == null || val.isEmpty ? 'Enter time' : null,
                      ),
                      _buildTextField(
                        label: 'Location',
                        onSaved: (val) => location = val ?? '',
                        validator: (val) => val == null || val.isEmpty ? 'Enter location' : null,
                      ),
                      _buildTextField(
                        label: 'Contact No. of Creator',
                        keyboardType: TextInputType.phone,
                        onSaved: (val) => contactNo = val ?? '',
                        validator: (val) => val == null || val.isEmpty ? 'Enter contact number' : null,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              _formKey.currentState?.save();
                              await FirebaseFirestore.instance.collection('nowfree').add({
                                'groupName': groupName,
                                'groupDescription': groupDescription,
                                'groupType': groupType,
                                'peopleNeeded': peopleNeeded,
                                'location': location,
                                'time': time,
                                'contactNo': contactNo,
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Now Free Event Created!')),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Create Now Free Event'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
        onSaved: onSaved,
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: const Color(0xFF2E004F),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    );
  }
}
