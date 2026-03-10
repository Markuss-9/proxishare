import 'package:flutter/material.dart';
import 'package:proxishare/components/received_file.dart';
import 'package:proxishare/components/received_file_card.dart';
import 'package:proxishare/components/toast.dart';

class ReceivedFilesGrid extends StatelessWidget {
  final List<ReceivedFile> files;
  final VoidCallback onClear;

  const ReceivedFilesGrid({
    super.key,
    required this.files,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        files.isEmpty ? _buildEmptyState(context) : _buildGrid(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.file_download, size: 20),
            const SizedBox(width: 8),
            Text(
              'Received This Session',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${files.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        if (files.isNotEmpty)
          IconButton(
            onPressed: () {
              onClear();
              showToast(context, 'Session files cleared');
            },
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear session',
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No files received yet',
              style: TextStyle(color: Colors.grey.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 4),
            Text(
              'Files sent to this device will appear here',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return ReceivedFileCard(file: file);
      },
    );
  }
}
