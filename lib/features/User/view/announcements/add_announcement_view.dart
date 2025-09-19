import 'package:flutter/material.dart';
import 'package:leavify/features/User/viewmodel/announcements_view_model.dart';
import 'package:leavify/features/Home/viewmodel/home_view_model.dart';
import 'package:provider/provider.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  void _sendAnnouncement() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both title and body")),
      );
      return;
    }

    final viewModel = context.read<AnnouncementViewModel>();
    final homeViewModel = context.read<HomeViewModel>();

    final success = await viewModel.addAnnouncement(title, body);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.latestAnnouncement?.message ?? "Announcement sent",
          ),
        ),
      );
      _titleController.clear();
      _bodyController.clear();
      Navigator.pushNamed(context, '/home');
      homeViewModel.refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? "Failed to send announcement",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AnnouncementViewModel>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Body",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: viewModel.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: const Text("Send Announcement"),
              onPressed: viewModel.isLoading ? null : _sendAnnouncement,
            ),
          ],
        ),
      ),
    );
  }
}
