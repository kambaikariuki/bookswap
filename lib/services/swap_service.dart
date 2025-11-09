import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/swap_model.dart';

class SwapService {
   final CollectionReference swapsRef =
      FirebaseFirestore.instance.collection('swaps');

  // CREATE
  Future<DocumentReference> createSwap(Swap swap) async {
    final docRef = await swapsRef.add(swap.toMap());
    return docRef;
  }
  // READ
  Stream<List<Swap>> getUserSwaps(String userId) {
    return swapsRef
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Swap.fromMap(doc.data() as Map<String, dynamic>, doc.id))

              .toList(),
        );
  }
  //UPDATE STATUS
  Future<void> updateSwapStatus(String swapId, String status) async {
    await swapsRef.doc(swapId).update({'status': status});
  }

  // UPDATE
  Future<void> completeSwap(String swapId) async {
    final swapDoc = await swapsRef.doc(swapId).get();
    if (!swapDoc.exists) return;

    final data = swapDoc.data()!;
    final mapData = data as Map<String, dynamic>;

    final requesterId = mapData['requesterId'];
    final receiverId = mapData['receiverId'];
    final requesterBookId = mapData['requesterBookId'];
    final receiverBookId = mapData['receiverBookId'];

    final booksRef = FirebaseFirestore.instance.collection('books');

    // Swap book ownership
    await booksRef.doc(requesterBookId).update({'ownerId': receiverId});
    await booksRef.doc(receiverBookId).update({'ownerId': requesterId});

    // Update swap status
    await swapsRef.doc(swapId).update({'status': 'Accepted'});
  }
}
