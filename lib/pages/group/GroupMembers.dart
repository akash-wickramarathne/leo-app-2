import 'package:flutter/material.dart';

class GroupMembersPage extends StatelessWidget {
  final String groupID;

  const GroupMembersPage({Key? key, required this.groupID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // You can fetch the group members using the groupID and display them here.
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Members'),
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchGroupMembers(groupID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No members found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                
                return ListTile(
                  title: Text(snapshot.data![index]),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<String>> _fetchGroupMembers(String groupID) async {
    // Replace this with your method to fetch the group members from ZIMKit
    // using the groupID.
    // For demonstration, returning a dummy list.
    return ['Member 1', 'Member 2', 'Member 3'];
  }
}
