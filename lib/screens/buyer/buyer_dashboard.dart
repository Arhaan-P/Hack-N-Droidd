import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_page.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterButton(
                  label: 'Donation',
                  onPressed: () {
                    // Handle donation filter
                  },
                ),
                FilterButton(
                  label: 'Recycle',
                  onPressed: () {
                    // Handle recycle filter
                  },
                ),
                FilterButton(
                  label: 'Non Recycle',
                  onPressed: () {
                    // Handle non-recycle filter
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // List of items
            Expanded(
              child: ListView.builder(
                itemCount: 4, // Replace with actual item count
                itemBuilder: (context, index) {
                  return ItemCard(
                    customerName: 'Customer name',
                    description: 'I have Newspapers and other stuff',
                    onBuyNow: () {
                      // Handle buy now action
                    },
                    onRemindLater: () {
                      // Handle remind later action
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }
}

class ItemCard extends StatelessWidget {
  final String customerName;
  final String description;
  final VoidCallback onBuyNow;
  final VoidCallback onRemindLater;

  const ItemCard({
    super.key,
    required this.customerName,
    required this.description,
    required this.onBuyNow,
    required this.onRemindLater,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customerName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onRemindLater,
                  child: const Text('Remind later'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onBuyNow,
                  child: const Text('Buy Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
