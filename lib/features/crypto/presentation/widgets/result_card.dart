import 'package:flutter/material.dart';
import '../../../../core/utils/clipboard_helper.dart';

class ResultCard extends StatelessWidget {
  final String result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E252B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00C853), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Color(0xFF00C853), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Resultado',
                style: TextStyle(
                  color: Color(0xFF00C853),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C343C),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3D4852)),
            ),
            child: SelectableText(
              result,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFFF1D592),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ClipboardHelper.copyToClipboard(result);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Copiado para a área de transferência!'),
                        ],
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: const Color(0xFF00C853),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copiar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF1E252B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
