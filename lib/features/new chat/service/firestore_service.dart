// services/firestore_service.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;

class FirestoreService {
  final _usersRef = FirebaseFirestore.instance.collection('users');
  final firestore = FirebaseFirestore.instance;
  Future<void> createUser(String uid, String email) async {
    await _usersRef.doc(uid).set({
      'email': email,
      'friends': [],
      'sentRequests': [],
      'receivedRequests': [],
    });
  }

  Future<AppUser> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    return AppUser.fromMap(doc.data()!, uid);
  }

  Stream<List<AppUser>> getAllUsers() {
    return _usersRef.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => AppUser.fromMap(doc.data(), doc.id))
              .toList(),
    );
  }

  Future<void> sendFriendRequest({
    required String fromUid,
    required String toUid,
    required String fromUsername,
  }) async {
    await _usersRef.doc(fromUid).update({
      'sentRequests': FieldValue.arrayUnion([toUid]),
    });
    await _usersRef.doc(toUid).update({
      'receivedRequests': FieldValue.arrayUnion([fromUid]),
    });

    final fromUserRef = firestore.collection('users').doc(fromUid);
    final toUserRef = firestore.collection('users').doc(toUid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final toUserSnapshot = await transaction.get(toUserRef);
      final fromUserSnapshot = await transaction.get(fromUserRef);

      final List received = toUserSnapshot['receivedRequests'] ?? [];
      final List sent = fromUserSnapshot['sentRequests'] ?? [];

      if (!received.contains(fromUid)) {
        received.add(fromUid);
        transaction.update(toUserRef, {'receivedRequests': received});
      }

      if (!sent.contains(toUid)) {
        sent.add(toUid);
        transaction.update(fromUserRef, {'sentRequests': sent});
      }

      // Get FCM token
      final fcmToken = toUserSnapshot['fcmToken'];
      if (fcmToken != null && fcmToken.toString().isNotEmpty) {
        await sendPushNotification(
          fcmToken: fcmToken,
          title: 'New Friend Request',
          body: '$fromUsername sent you a request!',
        );
      }
    });
  }

  Future<void> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    const String serverKey = ''; // Replace with your FCM server key

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': fcmToken,
          'notification': {'title': title, 'body': body},
          'priority': 'high',
        }),
      );
    } catch (e) {
      print('Notification error: $e');
    }
  }

  Future<void> rejectFriendRequest(String fromUserId, String toUserId) async {
    final firestore = FirebaseFirestore.instance;
    final fromUserRef = firestore.collection('users').doc(fromUserId);
    final toUserRef = firestore.collection('users').doc(toUserId);

    // await firestore.runTransaction((transaction) async {
    //   final fromUserSnapshot = await transaction.get(fromUserRef);
    //   final toUserSnapshot = await transaction.get(toUserRef);

    //   final sent = List<String>.from(fromUserSnapshot['sentRequests'] ?? []);
    //   final received = List<String>.from(
    //     toUserSnapshot['receivedRequests'] ?? [],
    //   );

    //   // Remove the request
    //   received.remove(fromUserId);
    //   sent.remove(toUserId);
    //   print("received $received , sent $sent");

    //   transaction.update(toUserRef, {'receivedRequests': []});
    //   transaction.update(fromUserRef, {'sentRequests': []});

    //   // firestore.collection('users').doc(fromUserId).

      
    // });

    await fromUserRef.update({
        'sentRequests': FieldValue.arrayRemove([toUserId]),
      });

      // 2. Remove fromUserId from toUser's receivedRequests
      await toUserRef.update({
        'receivedRequests': FieldValue.arrayRemove([fromUserId]),
      });
  }


  Future<void> revokeSentRequest(String fromUserId, String toUserId) async {
    final firestore = FirebaseFirestore.instance;
    final fromUserRef = firestore.collection('users').doc(fromUserId);
    final toUserRef = firestore.collection('users').doc(toUserId);

    // await firestore.runTransaction((transaction) async {
    //   final fromUserSnapshot = await transaction.get(fromUserRef);
    //   final toUserSnapshot = await transaction.get(toUserRef);

    //   final sent = List<String>.from(fromUserSnapshot['sentRequests'] ?? []);
    //   final received = List<String>.from(
    //     toUserSnapshot['receivedRequests'] ?? [],
    //   );

    //   // Remove the request
    //   received.remove(fromUserId);
    //   sent.remove(toUserId);
    //   print("received $received , sent $sent");

    //   transaction.update(toUserRef, {'receivedRequests': []});
    //   transaction.update(fromUserRef, {'sentRequests': []});

    //   // firestore.collection('users').doc(fromUserId).

      
    // });

    await fromUserRef.update({
        'receivedRequests': FieldValue.arrayRemove([toUserId]),
      });

      // 2. Remove fromUserId from toUser's receivedRequests
      await toUserRef.update({
        'sentRequests': FieldValue.arrayRemove([fromUserId]),
      });
  }

  // Future<void> rejectFriendRequest(String fromUserId, String toUserId) async {
  //   final firestore = FirebaseFirestore.instance;
  //   final DocumentReference fromUserRef = firestore.collection('users').doc(fromUserId);
  //   final DocumentReference toUserRef = firestore.collection('users').doc(toUserId);

  //   await firestore.runTransaction((transaction) async {
  //     final DocumentSnapshot fromUserSnapshot = await transaction.get(fromUserRef);
  //     final DocumentSnapshot toUserSnapshot = await transaction.get(toUserRef);

  //     final received =
  //   });
  // }

  Future<void> acceptFriendRequest(String currentUid, String senderUid) async {
    await _usersRef.doc(currentUid).update({
      'friends': FieldValue.arrayUnion([senderUid]),
      'receivedRequests': FieldValue.arrayRemove([senderUid]),
    });
    await _usersRef.doc(senderUid).update({
      'friends': FieldValue.arrayUnion([currentUid]),
      'sentRequests': FieldValue.arrayRemove([currentUid]),
    });
  }

  String getChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> saveFcmToken(String uid, String token) async {
    await _usersRef.doc(uid).update({'fcmToken': token});
  }
}
