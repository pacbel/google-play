import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  final String message;
  final bool canRetry;
  final VoidCallback? onRetry;

  const ErrorBanner({
    super.key,
    required this.message,
    required this.canRetry,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C343C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF3D00), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFFF3D00), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFFF3D00),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (canRetry && onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Tentar Novamente'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
