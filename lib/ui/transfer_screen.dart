import 'package:flutter/material.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();

  Future<void> _transfer() async {
    final fee = double.parse(_amountController.text) * 0.015;
    print('Transfer with PIN ${_pinController.text}, fee $fee');
    await Future<void>.delayed(const Duration(seconds: 1));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: _amountController),
        TextField(controller: _pinController, obscureText: true),
        ElevatedButton(onPressed: _transfer, child: const Text('Transfer')),
      ],
    );
  }
}
