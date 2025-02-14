import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final String itemId;
  final String? sellerId;
  final String imageUrl;
  final String title;
  final String description;
  final List<String> categories;
  final VoidCallback? onCartUpdated;

  const ItemCard({
    super.key,
    required this.itemId,
    required this.sellerId,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.categories,
    this.onCartUpdated,
  });

  Future<void> _addToCart(
      BuildContext context, String sellerId, String itemId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Add to cart collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .add({
      'sellerId': sellerId,
      'itemId': itemId,
      'timestamp': Timestamp.now(),
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'categories': categories,
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart!')),
      );
      // Call the callback to update the cart count
      onCartUpdated?.call();
      // Remove the direct state access
      // final dashboardState = context.findAncestorStateOfType<BuyerDashboardState>();
      // dashboardState?._loadCartItemCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showImageDialog(context, imageUrl),
            child: Hero(
              tag: 'image-$itemId',
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => _showDetailsDialog(
                          context, title, description, categories),
                      tooltip: 'View Details',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    return Chip(
                      label: Text(category),
                      backgroundColor: _getCategoryColor(category),
                      labelStyle:
                          const TextStyle(color: Colors.white, fontSize: 12),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[800]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          if (sellerId == null) return;
                          FirebaseFirestore.instance
                              .collection('reminders')
                              .add({
                            'userId': FirebaseAuth.instance.currentUser?.uid,
                            'sellerId': sellerId,
                            'itemId': itemId,
                            'timestamp': Timestamp.now(),
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reminder set')),
                          );
                        },
                        icon: const Icon(Icons.notifications_active, size: 18),
                        label: const Text('Remind Later'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (sellerId == null) return;
                          _addToCart(context, sellerId!, itemId);
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: Hero(
                  tag: 'fullscreen-$itemId',
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 300,
                        height: 300,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDetailsDialog(BuildContext context, String title,
      String description, List<String> categories) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      return Chip(
                        label: Text(category),
                        backgroundColor: _getCategoryColor(category),
                        labelStyle: const TextStyle(color: Colors.white),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description.isEmpty
                        ? 'No description provided'
                        : description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'donate':
        return Colors.green[600]!;
      case 'recyclable':
        return Colors.blue[600]!;
      case 'non-recyclable':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
