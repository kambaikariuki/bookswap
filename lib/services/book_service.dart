import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';

class BookService {
  final CollectionReference booksRef =
      FirebaseFirestore.instance.collection('books');

  // CREATE
  Future<void> addBook(Book book) async {
    await booksRef.add(book.toMap());
  }

  // READ ALL BOOKS(not by current user)
  Stream<List<Book>> getAllBooks(String userId) {
    return booksRef.where('ownerId', isNotEqualTo: userId).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }

  // READ (books owned by current user)
  Stream<List<Book>> getUserBooks(String userId) {
    return booksRef.where('ownerId', isEqualTo: userId).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Book.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }

  // UPDATE
  Future<void> updateBook(String id, Map<String, dynamic> data) async {
    await booksRef.doc(id).update(data);
  }

  // DELETE
  Future<void> deleteBook(String id) async {
    await booksRef.doc(id).delete();
  }
}
