import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const commonPorts = [8080, 5173, 3000];

class PortSelectorWidget extends StatelessWidget {
  final TextEditingController portController;
  final VoidCallback? onPortChanged;

  const PortSelectorWidget({
    super.key,
    required this.portController,
    this.onPortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: portController,
      builder: (_, __, ___) {
        final text = portController.text;
        int? textPort = int.tryParse(text);
        bool isAutomatic = text.isEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ChoiceChip(
                    label: const Text('Automatic'),
                    selected: isAutomatic,
                    onSelected: (sel) {
                      if (sel) {
                        portController.clear();
                        onPortChanged?.call();
                      }
                    },
                  ),
                ),
                ...commonPorts.map(
                  (p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ChoiceChip(
                      label: Text('$p'),
                      selected: textPort == p,
                      onSelected: (sel) {
                        if (sel) {
                          portController.text = p.toString();
                          onPortChanged?.call();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 200,
              child: TextField(
                controller: portController,
                keyboardType: TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Port (optional)',
                  helperText: 'Leave blank for automatic port selection',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
