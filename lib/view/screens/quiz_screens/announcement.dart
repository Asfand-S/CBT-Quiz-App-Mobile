import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Announcement extends StatefulWidget {
  const Announcement({super.key});

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance.collection("announcement");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcements"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore.orderBy('timestamp', descending: true).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildMessage(
                context,
                icon: Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                text: "Error loading announcements",
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildMessage(
                context,
                icon: Icons.info_outline,
                color: Theme.of(context).colorScheme.secondary,
                text: "No announcements available",
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var message = doc['message'] ?? "No message";

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            height: 1.5,
                          ),
                    ),
                    // trailing: IconButton(
                    //   icon: const Icon(Icons.delete, color: Colors.red),
                    //   onPressed: () async {
                    //     await firestore.doc(doc.id).delete();
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       const SnackBar(content: Text("Announcement deleted")),
                    //     );
                    //   },
                    // ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context,
      {required IconData icon, required Color color, required String text}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                ),
          ),
        ],
      ),
    );
  }
}
