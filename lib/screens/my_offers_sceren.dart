import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/swap_service.dart';
import '../models/swap_model.dart';

final swapServiceProvider = Provider((ref) => SwapService());

class MyOffersScreen extends ConsumerWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final swapService = ref.watch(swapServiceProvider);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<List<Swap>>(
      stream: swapService.getUserSwaps(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No offers found'));
        }

        final swaps = snapshot.data!;

        // Collect all unique book IDs from swaps
        final bookIds = <String>{};
        for (var swap in swaps) {
          bookIds.add(swap.requesterBookId);
          bookIds.add(swap.receiverBookId);
        }

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('books')
              .where(FieldPath.documentId, whereIn: bookIds.toList())
              .get(),
          builder: (context, bookSnapshot) {
            if (!bookSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Map bookId -> bookName
            final bookMap = <String, String>{};
            for (var doc in bookSnapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              bookMap[doc.id] = data['name'] ?? data['title'] ?? 'Unknown Book';
            }

            return ListView.builder(
              itemCount: swaps.length,
              itemBuilder: (context, index) {
                final swap = swaps[index];

                final requesterBookName =
                    bookMap[swap.requesterBookId] ?? 'Unknown Book';
                final receiverBookName =
                    bookMap[swap.receiverBookId] ?? 'Unknown Book';

                // Optional: highlight the other participant's book
                final yourBook = swap.requesterId == userId
                    ? requesterBookName
                    : receiverBookName;
                final theirBook = swap.requesterId == userId
                    ? receiverBookName
                    : requesterBookName;

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Swap "$yourBook" with "$theirBook"'),
                    subtitle: Text('Status: ${swap.status}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (swap.status == 'pending')
                          ElevatedButton(
                            onPressed: () async {
                              await swapService.updateSwapStatus(
                                  swap.id, 'Accepted');
                            },
                            child: const Text('Accept'),
                          ),
                        if (swap.status == 'pending')
                          ElevatedButton(
                            onPressed: () async {
                              await swapService.updateSwapStatus(
                                  swap.id, 'Rejected');
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('Reject'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
