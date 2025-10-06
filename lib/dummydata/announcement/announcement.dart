import 'package:leavify/features/Leave/models/response/get_announcements_response.dart';

const List<Map<String, dynamic>> dummyAnnouncementsResponse = [
  {
    "profileImage": "https://example.com/profile/emma_williams.jpg",
    "senderName": "Emma Williams",
    "title": "Team Meeting",
    "body":
        "Reminder: Team meeting scheduled on 25th September at 10 AM in Conference Room B.",
    "timeAgo": "2h ago",
  },
  {
    "profileImage": "https://example.com/profile/john_doe.jpg",
    "senderName": "John Doe",
    "title": "Project Deadline",
    "body":
        "Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.Please submit your final reports for Project A by end of this week.",
    "timeAgo": "5h ago",
  },
  {
    "profileImage": "https://example.com/profile/sophia_taylor.jpg",
    "senderName": "Sophia Taylor",
    "title": "HR Announcement",
    "body": "Leave policy has been updated. Check your emails for details.",
    "timeAgo": "1d ago",
  },
  {
    "profileImage": "https://example.com/profile/michael_anderson.jpg",
    "senderName": "Michael Anderson",
    "title": "Company Event",
    "body":
        "Annual company gathering will be held on 15th December. Save the date!",
    "timeAgo": "2d ago",
  },
  {
    "profileImage": "https://example.com/profile/alice_smith.jpg",
    "senderName": "Alice Smith",
    "title": "Maintenance Downtime",
    "body":
        "The internal portal will be down for maintenance on 23rd September from 1 AM to 3 AM.",
    "timeAgo": "3d ago",
  },
];

/// Converts dummy announcements into Dart objects
final List<GetAnnouncementsResponse> dummyAnnouncements =
    GetAnnouncementsResponse.listFromJson(dummyAnnouncementsResponse);
