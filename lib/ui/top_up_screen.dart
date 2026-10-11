import 'package:flutter/material.dart';

import '../data/top_up_repository.dart';
import '../wallet.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key, required this.repository});

  final TopUpRepository repository;

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _amountController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amountMinor = int.tryParse(_amountController.text.trim());
    if (amountMinor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a whole amount')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.repository.topUp(Money(amountMinor));
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on TopUpFailedException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Top-up failed: ${e.reason}')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const CircularProgressIndicator()
              : const Text('Top up'),
        ),
      ],
    );
  }
}
