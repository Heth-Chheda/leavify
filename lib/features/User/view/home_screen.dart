import 'package:flutter/material.dart';
import 'package:leavify/features/User/components/announcement_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _dummyAnnouncements = [
    {
      "title": "📣 Company Holiday",
      "message": "We will be closed on 15th Aug for Independence Day.",
    },
    {
      "title": "📢 Leave Policy Updated",
      "message": "New leave carry-forward rules apply from this month.",
    },
    {
      "title": "🚨 Server Maintenance",
      "message": "Portal will be offline on Sunday 12–3 AM.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16.0), child: _buildBody());
  }

  Widget _buildBody() {
    final bool hasAnnouncements = _dummyAnnouncements.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Announcements",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (hasAnnouncements) ...[
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _dummyAnnouncements.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final item = _dummyAnnouncements[index];
                return AnnouncementCard(
                  title: item['title']!,
                  message: item['message']!,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_dummyAnnouncements.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.blue
                        : Colors.grey.shade400,
                  ),
                );
              }),
            ),
          ),
        ] else
          Container(
            width: double.infinity,
            height: 140,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                "🎉 You have no announcements.\nHave a great day!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        const SizedBox(height: 20),
        // More widgets here
      ],
    );
  }
}
