import 'package:flutter/material.dart';
import 'event_types.dart';
import '../../widgets/category_card.dart';
import 'package:vknder_test/screens/events_in_category_page.dart';
import 'create_event_page.dart';

class EventsSection extends StatefulWidget {
  final String userName;
  const EventsSection({Key? key, required this.userName}) : super(key: key);

  @override
  State<EventsSection> createState() => _EventsSectionState();
}

class _EventsSectionState extends State<EventsSection> {
  final ScrollController _scrollController = ScrollController();
  double _scroll = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scroll = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String firstName = widget.userName.trim().split(' ').first;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 600;

    // Greeting card animation: fade out and scale down after 0-100px scroll
    final double fade = (1 - (_scroll / 100)).clamp(0.0, 1.0);
    final double scale = (1 - (_scroll / 400)).clamp(0.85, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF4B0082),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE23744),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventPage()),
          );
        },
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        tooltip: "Create Event",
      ),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: fade,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isWide ? 48 : 18,
                      vertical: isWide ? 32 : 18,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isWide ? 32 : 22,
                      horizontal: isWide ? 32 : 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                        width: 1.2,
                      ),
                      // Glassmorphism effect
                      backgroundBlendMode: BlendMode.overlay,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello $firstName 👋",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isWide ? 36 : 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          "Find your vibe today.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: isWide ? 22 : 16,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 40 : 10,
                vertical: isWide ? 12 : 6,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 0.92,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final type = eventTypes[i];
                    return CategoryCard(
                      icon: type["icon"] as IconData,
                      title: type["name"]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventsInCategoryPage(
                              eventType: type["name"]!,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: eventTypes.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
