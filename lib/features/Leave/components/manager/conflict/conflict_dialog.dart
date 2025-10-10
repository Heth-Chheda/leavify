import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leavify/features/Leave/models/response/get_leave_by_id_response.dart';

class ConflictDialog extends StatelessWidget {
  final List<TeamConflictingLeave> conflicts;
  final String illustrationAsset;

  const ConflictDialog({
    super.key,
    required this.conflicts,
    required this.illustrationAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1D4ED8), // Deep blue
              Color(0xFF3B82F6), // Bright blue
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // White content section
            Container(
              margin: const EdgeInsets.only(
                top: 60,
              ), // Push down to leave space for image
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Conflicting Leaves',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This leave overlaps with the following team members:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: conflicts.length * 60.0,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: conflicts.length,
                      itemBuilder: (context, index) {
                        final conflict = conflicts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    conflict.profileImagePath.isNotEmpty
                                    ? NetworkImage(conflict.profileImagePath)
                                    : null,
                                child: conflict.profileImagePath.isEmpty
                                    ? const Icon(Icons.person, size: 16)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${conflict.fName} ${conflict.lName} '
                                  '(${DateFormat('dd MMM').format(conflict.fromDate)} '
                                  '- ${DateFormat('dd MMM').format(conflict.toDate)})',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Conflict illustration image (partially outside)
            Positioned(
              top: -90, // Move above the container
              child: Image.asset(illustrationAsset, height: 150),
            ),
          ],
        ),
      ),
    );
  }
}
