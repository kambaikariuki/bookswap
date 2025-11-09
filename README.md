#  BookSwap App

BookSwap is a Flutter-based mobile application that allows users to swap books with each other. The app uses **Firebase** for authentication, real-time database updates, and chat functionality.

---

## 🔹 Features

- **User Authentication** – Sign up and log in using Firebase Authentication.  
- **Book Management** – Users can add books they own and mark them available for swap.  
- **Swap Requests** – Request to swap books with another user.  
- **Swap Status** – Track swaps with statuses: `pending`, `accepted`, `rejected`.  
- **Real-time Chat** – Users can chat in real-time about swaps.  
- **Ownership Update** – When swaps are accepted, ownership of books is updated automatically.  

---

## 🗂 Database Structure (Firestore)

### Collections:

**users**  
- `uid`  
- `name`  
- `email`  
- `createdAt`  

**books**  
- `id`  
- `title`  
- `author`  
- `ownerId`  
- `status` (`available` / `swapped`)  
- `createdAt`  

**swaps**  
- `id`  
- `requesterId`  
- `receiverId`  
- `requesterBookId`  
- `receiverBookId`  
- `status` (`pending`, `accepted`, `rejected`)  
- `participants` ([requesterId, receiverId])  
- `createdAt`  

**chats**  
- `id`  
- `participants` ([userAId, userBId])  
- `swapId` (optional)  
- `lastMessageTime`  
- **Subcollection `messages`**:  
  - `senderId`  
  - `text`  
  - `createdAt`  

---

## ⚙️ State Management

- Implemented using **Riverpod**.  
- Providers expose services like `SwapService` and `ChatService`.  
- **StreamBuilders** listen to Firestore updates for swaps and chats.  
- Reactive UI updates automatically when Firestore data changes.

---

## 🛠 Setup Instructions

**Clone the repository:**

git clone https://github.com/kambaikariuki/bookswap.git
cd bookswap

**Install dependencies:**

flutter pub get

**Configure Firebase:**

Create a Firebase project on Firebase Console

Add Firebase to your Flutter project (flutterfire configure)

Ensure firebase_options.dart is generated.

**Run the app:**

flutter run
