import 'package:bookswap/models/swap_model.dart';
import 'package:bookswap/providers/swap_provider.dart';
import 'package:bookswap/screens/chats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'message_screen.dart';

final bookServiceProvider = Provider((ref) => BookService());

class BrowseScreen extends ConsumerWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookService = ref.watch(bookServiceProvider);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<List<Book>>(
      stream: bookService.getAllBooks(userId), // only show books not owned by user
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No books found'));
        }

        final books = snapshot.data!;

        return ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: Image.network(
                  book.imageUrl.isNotEmpty
                      ? book.imageUrl
                      : 'https://via.placeholder.com/150',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(book.title),
                subtitle: Text('${book.author} • ${book.condition}'),
                trailing: ElevatedButton(
                  onPressed: () => _showSwapDialog(context, ref, book),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Swap'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

void _showSwapDialog(
  BuildContext context,
  WidgetRef ref,
  Book requestedBook,
) async {
  final bookService = ref.read(bookServiceProvider);
  final swapService = ref.read(swapServiceProvider);
  final chatService = ref.read(chatServiceProvider); // ✅ instance
  final userId = FirebaseAuth.instance.currentUser!.uid;

  // Get current user's books
  final myBooksSnapshot = await bookService.getUserBooks(userId).first;
  final myBooks = myBooksSnapshot;

  if (myBooks.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have no books to offer!')),
    );
    return;
  }

  Book? selectedBook;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Choose a book to offer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: myBooks
            .map(
              (b) => RadioListTile<Book>(
                title: Text(b.title),
                subtitle: Text(b.author),
                value: b,
                groupValue: selectedBook,
                onChanged: (value) {
                  selectedBook = value;
                  (context as Element).markNeedsBuild();
                },
              ),
            )
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (selectedBook == null) return;

            // 1️⃣ Create Swap object
            final swap = Swap(
              id: '',
              requesterId: userId,
              receiverId: requestedBook.ownerId,
              requesterBookId: selectedBook!.id,
              receiverBookId: requestedBook.id,
              status: 'pending',
              createdAt: DateTime.now(),
              participants: [userId, requestedBook.ownerId],
            );

            // 2️⃣ Save swap in Firestore
            final createdSwap = await swapService.createSwap(swap);

            // 3️⃣ Create or get existing chat
            final chatId = await chatService.createOrGetChat(
              userA: userId,
              userB: requestedBook.ownerId,
              swapId: createdSwap.id,
            );

            // 4️⃣ Send initial message
            await chatService.sendMessage(
              chatId: chatId,
              senderId: userId,
              text:
                  "Hi! I'd like to swap my '${selectedBook!.title}' for your '${requestedBook.title}'.",
            );

            // 5️⃣ Navigate to MessageScreen
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) =>
            //         MessageScreen(chatId: chatId, swapId: swap.id),
            //   ),
            // );

            Navigator.pop(context); // close the offer selection dialog
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}
