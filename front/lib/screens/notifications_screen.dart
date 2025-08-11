import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jobmatch_app/models/notifications.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationMod> notifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('toUserId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('date', descending: true)
        .get();

    final data = snapshot.docs.map((doc) {
      try {
        return NotificationMod.fromDocument(doc);
      } catch (e) {
        print("Erreur parsing notif: $e");
        return null;
      }
    }).whereType<NotificationMod>().toList();

    setState(() {
      notifications = data;
    });
  }

  void _showBottomSheetOptions(BuildContext context, NotificationMod notification) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '"${notification.title}"',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.mark_email_read),
                title: const Text("Mark as read"),
                onTap: () {
                  markAsRead(notification.id);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.mark_email_unread),
                title: const Text("Mark as unread"),
                onTap: () {
                  markAsUnread(notification.id);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Delete"),
                onTap: () {
                  deleteNotification(notification.id);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("View more details"),
                onTap: () {
                  Navigator.pop(context);
                  _showNotificationDetails(context, notification);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationDetails(BuildContext context, NotificationMod notif) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => NotificationDetailModal(
        title: notif.title,
        message: notif.description,
        date: DateFormat.yMMMd().add_jm().format(notif.date),
      ),
    );
  }

  Future<void> markAsRead(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).update({'status': 'read'});
    await loadNotifications();
  }

  Future<void> markAsUnread(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).update({'status': 'unread'});
    await loadNotifications();
  }

  Future<void> deleteNotification(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).delete();
    await loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdfddf3),
      appBar: AppBar(
        backgroundColor: const Color(0xffbfbcf3),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              loadNotifications();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              notifications.isNotEmpty
                  ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return GestureDetector(
                    onTap: () => _showBottomSheetOptions(context, notif),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: notif.status == 'read'
                            ? Colors.grey[300]
                            : Colors.deepPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      height: 80,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: notif.image.isNotEmpty
                                ? AssetImage(notif.image)
                                : null,
                            backgroundColor: Colors.white,
                            radius: 25,
                            child: notif.image.isEmpty
                                ? const Icon(Icons.notifications, size: 30, color: Colors.deepPurple)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notif.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text(notif.description,
                                    style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                          ),
                          Text(
                            '${notif.date.hour}:${notif.date.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
                  : const Text('No Notifications'),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationDetailModal extends StatelessWidget {
  final String title;
  final String message;
  final String date;

  const NotificationDetailModal({
    super.key,
    required this.title,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            date,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}