// announcement_card.dart

import 'package:flutter/material.dart';

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String message;
  final String? date;
  final bool isNew;
  final int? colorIndex;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.message,
    this.date,
    this.isNew = false,
    this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Define color schemes for different announcements
    final colorSchemes = [
      // Blue gradient
      {
        'colors': [
          Colors.blue.shade400,
          Colors.blue.shade500,
          Colors.blue.shade600,
        ],
        'shadowColor': Colors.blue,
      },
      // Purple gradient
      {
        'colors': [
          Colors.purple.shade400,
          Colors.purple.shade500,
          Colors.purple.shade600,
        ],
        'shadowColor': Colors.purple,
      },
      // Green gradient
      {
        'colors': [
          Colors.green.shade400,
          Colors.green.shade500,
          Colors.green.shade600,
        ],
        'shadowColor': Colors.green,
      },
      // Orange gradient
      {
        'colors': [
          Colors.orange.shade400,
          Colors.orange.shade500,
          Colors.orange.shade600,
        ],
        'shadowColor': Colors.orange,
      },
      // Teal gradient
      {
        'colors': [
          Colors.teal.shade400,
          Colors.teal.shade500,
          Colors.teal.shade600,
        ],
        'shadowColor': Colors.teal,
      },
      // Pink gradient
      {
        'colors': [
          Colors.pink.shade400,
          Colors.pink.shade500,
          Colors.pink.shade600,
        ],
        'shadowColor': Colors.pink,
      },
      // Indigo gradient
      {
        'colors': [
          Colors.indigo.shade400,
          Colors.indigo.shade500,
          Colors.indigo.shade600,
        ],
        'shadowColor': Colors.indigo,
      },
      // Cyan gradient
      {
        'colors': [
          Colors.cyan.shade400,
          Colors.cyan.shade500,
          Colors.cyan.shade600,
        ],
        'shadowColor': Colors.cyan,
      },
    ];

    // Select color scheme based on colorIndex or hash of title
    final selectedScheme =
        colorSchemes[colorIndex ?? title.hashCode.abs() % colorSchemes.length];

    return Container(
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: selectedScheme['colors'] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Bubble texture overlay
            Positioned.fill(
              child: CustomPaint(painter: BubbleTexturePainter()),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row with title and badges
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Announcement icon
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.campaign_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Title and badges
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isNew) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade400,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'NEW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (date != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 10,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    date!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Message content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.95),
                        height: 1.3,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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

class BubbleTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Create various bubble sizes and positions
    final bubbles = [
      {'x': size.width * 0.1, 'y': size.height * 0.2, 'radius': 8.0},
      {'x': size.width * 0.85, 'y': size.height * 0.1, 'radius': 12.0},
      {'x': size.width * 0.75, 'y': size.height * 0.7, 'radius': 6.0},
      {'x': size.width * 0.2, 'y': size.height * 0.8, 'radius': 10.0},
      {'x': size.width * 0.9, 'y': size.height * 0.4, 'radius': 4.0},
      {'x': size.width * 0.05, 'y': size.height * 0.6, 'radius': 7.0},
      {'x': size.width * 0.6, 'y': size.height * 0.15, 'radius': 5.0},
      {'x': size.width * 0.4, 'y': size.height * 0.9, 'radius': 9.0},
      {'x': size.width * 0.95, 'y': size.height * 0.8, 'radius': 3.0},
      {'x': size.width * 0.15, 'y': size.height * 0.4, 'radius': 6.0},
    ];

    // Draw bubbles
    for (final bubble in bubbles) {
      canvas.drawCircle(
        Offset(bubble['x'] as double, bubble['y'] as double),
        bubble['radius'] as double,
        paint,
      );
    }

    // Add some smaller bubbles with different opacity
    paint.color = Colors.white.withOpacity(0.05);
    final smallBubbles = [
      {'x': size.width * 0.3, 'y': size.height * 0.3, 'radius': 3.0},
      {'x': size.width * 0.7, 'y': size.height * 0.5, 'radius': 2.0},
      {'x': size.width * 0.5, 'y': size.height * 0.2, 'radius': 4.0},
      {'x': size.width * 0.8, 'y': size.height * 0.9, 'radius': 2.5},
      {'x': size.width * 0.1, 'y': size.height * 0.1, 'radius': 3.5},
    ];

    for (final bubble in smallBubbles) {
      canvas.drawCircle(
        Offset(bubble['x'] as double, bubble['y'] as double),
        bubble['radius'] as double,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
