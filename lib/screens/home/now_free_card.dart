import 'package:flutter/material.dart';
import 'package:vknder_test/models/now_free_model.dart';
import 'package:vknder_test/screens/home/now_free_detail_page.dart';

class NowFreeCard extends StatelessWidget {
  final NowFreeModel model;
  const NowFreeCard({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String img = model.imageUrl?.isNotEmpty == true
        ? model.imageUrl!
        : 'assets/images/now_free.jpg';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Card(
        color: const Color(0xFF21003A),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NowFreeDetailPage(nowFreeEvent: model),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 140,
                  child: img.startsWith('http')
                      ? Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF21003A),
                      child: const Icon(Icons.broken_image, color: Colors.white54, size: 40),
                    ),
                  )
                      : Image.asset(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF21003A),
                      child: const Icon(Icons.broken_image, color: Colors.white54, size: 40),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.groupName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      model.groupDescription,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.place, color: Color(0xFFE23744), size: 18),
                        const SizedBox(width: 5),
                        Text(
                          model.location,
                          style: const TextStyle(
                            color: Color(0xFFE23744),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "•",
                          style: TextStyle(color: Colors.white38, fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          model.time,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
