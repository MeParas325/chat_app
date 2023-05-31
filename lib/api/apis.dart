import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import 'package:untitled/models/messages.dart';
import '../models/chat_user.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for accessing firebase messaging (Push notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // get the current user data
  static late ChatUser me;

  // for accessing the current user
  static User get user => auth.currentUser!;

  // for getting firebase messaging token
  static Future<void> 
  getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Pushtoken: ${t}');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message in the foreground');
      log('Message Data: ${message.data}');

      if (message.notification == null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        'to': chatUser.pushToken,
        'notification': {
          'title': chatUser.name,
          'body': msg,
          'android_channel_id': 'chats'
        },
        'data': {
          'some_data': 'User ID: ${me.id}',
        }
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAYBKdJwI:APA91bGSL_bGDbn-kfhjmh3X4x5KtUhTxfwQQTKgMtXummaqhvroYk9Sl92F1MA9g_zquTHkhdy46ZUDMs89ZLH73CeNlPfl0pjDQQ_mVQJrZ2hjv9_QW1SWIQu5JmGtWrI6gAG9wPmn'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotification: ${e}');
    }
  }

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
        await getFirebaseMessagingToken();
        APIs.updateActiveStatus(true);
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

  // for updating the profile picture
  static Future<void> updateProfilePhoto(File file) async {
    // getting the image file extension
    final ext = file.path.split('.').last;
    log("File extension is: ${ext}");

    // storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.${ext}');

    //uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/${ext}')).then(
        (p0) => log("Data transferred: ${p0.bytesTransferred / 1000} kb"));

    // updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // """"""""""""""""Chat screen related APIs""""""""""""""""""

  // for getting the conversion id
  static String getConversionId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}.$id'
      : '${id}.${user.uid}';

  // for getting all messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return APIs.firestore
        .collection('chats/${getConversionId(user.id)}/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        sent: time,
        fromId: user.uid);
    final ref =
        firestore.collection('chats/${getConversionId(chatUser.id)}/messages');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  // for updating message read status
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversionId(message.fromId)}/messages')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // for getting the last message
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return APIs.firestore
        .collection('chats/${getConversionId(user.id)}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // for sending chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;

    // storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversionId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.${ext}');

    //uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/${ext}')).then(
        (p0) => log("Data transferred: ${p0.bytesTransferred / 1000} kb"));

    // updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // for getting the online offline status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }
}
