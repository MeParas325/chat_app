import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_user.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // get the current user data
  static late ChatUser me;

  // for accessing the current user
  static User get user => auth.currentUser!;

  // for checking if user exist or not
  static Future<bool> userExists() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  // for creating a new user
  static Future<void> createuser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        name: user.displayName.toString(),
        id: user.uid,
        email: user.email.toString(),
        about: 'Hey i am using the chat',
        image: user.photoURL.toString(),
        created_At: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return APIs.firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for getting the current user info
  static Future<void> getSelfInfo() async {
    await APIs.firestore
        .collection('users')
        .doc(user.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createuser().then((user) => getSelfInfo());
      }
    });
  }

  // for updating user information
  static Future<void> updateUserInfo() async {
    return await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }
}
