import 'package:flutter/material.dart';

Future<String?> showRoleSelectionDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Your Role'),
        content: const Text('Are you a buyer or a seller?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Buyer'),
            onPressed: () => Navigator.of(context).pop('buyer'),
          ),
          TextButton(
            child: const Text('Seller'),
            onPressed: () => Navigator.of(context).pop('seller'),
          ),
        ],
      );
    },
  );
}
