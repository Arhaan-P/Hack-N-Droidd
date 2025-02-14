import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  final String imageUrl;
  final List<String> selectedCategories;

  SummaryPage({required this.imageUrl, required this.selectedCategories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Summary")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(imageUrl, height: 200),
            ),
            SizedBox(height: 16),
            Text("Selected Categories:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: selectedCategories.map((category) => Chip(label: Text(category))).toList(),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Go Back"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
