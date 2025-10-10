import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String body;
  final String? illustrationAsset; // optional top image
  final double? illustrationHeight; // optional, default 150
  final String confirmButtonText;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.body,
    required this.confirmButtonText,
    required this.onConfirm,
    this.illustrationAsset,
    this.illustrationHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main white container
          Container(
            width: 320,
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      confirmButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Optional illustration image
          if (illustrationAsset != null)
            Positioned(
              top: -90, // overlaps half of the container
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  illustrationAsset!,
                  height: illustrationHeight ?? 150,
                ),
              ),
            ),
          // Close button (x) at top-right
          Positioned(
            top: 8,
            right: 10,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                radius: 15,
                backgroundColor: Colors.white,
                child: Icon(Icons.close, size: 24, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
