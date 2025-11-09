import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../services/book_service.dart';

final bookServiceProvider = Provider((ref) => BookService());

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookService = ref.watch(bookServiceProvider);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: () => _showAddEditDialog(context, bookService),
        //   )
        // ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: bookService.getUserBooks(userId),
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
                        : 'https://imgs.search.brave.com/8aa9tWcgc3eo0WJodcbWhIflYtygAsbpg2ZRwQwlGiU/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9tYXJr/ZXRwbGFjZS5jYW52/YS5jb20vRUFHQkZ2/dUdCTjAvMS8wLzEw/MDN3L2NhbnZhLXNp/bXBsZS1hbmQtbWlu/aW1hbGlzdC1zZWxm/LWhlYWxpbmctYm9v/ay1jb3Zlci1TV2xj/TDVRN0VYay5qcGc',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(book.title),
                  subtitle: Text('${book.author} • ${book.condition}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _showAddEditDialog(
                            context, bookService,
                            book: book),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, bookService, book),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          
        },
      ),floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, bookService),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white)),
    );
  }

  // ---------------------- ADD / EDIT DIALOG ----------------------
  void _showAddEditDialog(BuildContext context, BookService bookService,
      {Book? book}) {
    final titleController = TextEditingController(text: book?.title ?? '');
    final authorController = TextEditingController(text: book?.author ?? '');
    String selectedCondition = book?.condition ?? 'New';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book == null ? 'Add Book' : 'Edit Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            DropdownButtonFormField<String>(
              value: selectedCondition,
              items: ['New', 'Like New', 'Good', 'Used']
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) selectedCondition = value;
              },
              decoration: const InputDecoration(labelText: 'Condition'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final author = authorController.text.trim();

              if (title.isEmpty || author.isEmpty) return;

              if (book == null) {
                // Add new book
                await bookService.addBook(Book(
                  id: '',
                  title: title,
                  author: author,
                  condition: selectedCondition,
                  imageUrl: 'https://imgs.search.brave.com/8aa9tWcgc3eo0WJodcbWhIflYtygAsbpg2ZRwQwlGiU/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9tYXJr/ZXRwbGFjZS5jYW52/YS5jb20vRUFHQkZ2/dUdCTjAvMS8wLzEw/MDN3L2NhbnZhLXNp/bXBsZS1hbmQtbWlu/aW1hbGlzdC1zZWxm/LWhlYWxpbmctYm9v/ay1jb3Zlci1TV2xj/TDVRN0VYay5qcGc',
                  ownerId: FirebaseAuth.instance.currentUser!.uid,
                  createdAt: DateTime.now(),
                ));
              } else {
                // Update existing book
                await bookService.updateBook(book.id, {
                  'title': title,
                  'author': author,
                  'condition': selectedCondition,
                  // imageUrl stays the same
                });
              }

              Navigator.pop(context);
            },
            child: Text(book == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  // ---------------------- DELETE CONFIRMATION ----------------------
  void _confirmDelete(BuildContext context, BookService bookService, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await bookService.deleteBook(book.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
