import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/filter_button.dart';
import '../../widgets/item_card.dart';
import '../login_page.dart';
import 'buyer_cart.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => BuyerDashboardState();
}

class BuyerDashboardState extends State<BuyerDashboard> {
  String? selectedFilter;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    loadCartItemCount();
  }

  Future<void> loadCartItemCount() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final cartSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();
      setState(() {
        cartItemCount = cartSnapshot.docs.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Browse Items',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BuyerCart()),
                  ).then((_) =>
                      loadCartItemCount()); // Refresh count after returning
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                const Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      FilterButton(
                        label: 'All Items',
                        isSelected: selectedFilter == null,
                        onPressed: () {
                          setState(() {
                            selectedFilter = null;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      FilterButton(
                        label: 'Donate',
                        isSelected: selectedFilter == 'Donate',
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'Donate';
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      FilterButton(
                        label: 'Recyclable',
                        isSelected: selectedFilter == 'Recyclable',
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'Recyclable';
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      FilterButton(
                        label: 'Non-Recyclable',
                        isSelected: selectedFilter == 'Non-Recyclable',
                        onPressed: () {
                          setState(() {
                            selectedFilter = 'Non-Recyclable';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildItemsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No items available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final sellerId = doc.reference.parent.parent?.id;

                    return ItemCard(
                      itemId: doc.id,
                      sellerId: sellerId,
                      imageUrl: data['imageUrl'] ?? '',
                      title: data['title'] ?? 'Untitled Item',
                      description: data['description'] ?? 'No description',
                      categories: List<String>.from(data['categories'] ?? []),
                      onCartUpdated: loadCartItemCount,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {}); // Refresh the stream
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Stream<QuerySnapshot> _buildItemsStream() {
    var query = _firestore
        .collectionGroup('items')
        .where('status', isEqualTo: 'active');

    if (selectedFilter != null) {
      // Add the categories filter only when a filter is selected
      query = query.where('categories', arrayContains: selectedFilter);
    }

    // Always order by timestamp
    return query.orderBy('timestamp', descending: true).snapshots();
  }
}
