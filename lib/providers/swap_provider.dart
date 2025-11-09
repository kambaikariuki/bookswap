import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/swap_model.dart';
import '../services/swap_service.dart';

// Swap service provider
final swapServiceProvider = Provider((ref) => SwapService());

// Stream provider for current user's swaps
final mySwapsStreamProvider = StreamProvider.autoDispose<List<Swap>>((ref) {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final swapService = ref.watch(swapServiceProvider);
  return swapService.getUserSwaps(userId);
});
