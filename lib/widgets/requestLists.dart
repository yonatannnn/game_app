import 'package:flutter/material.dart';
import 'package:game_app/models/requestModel.dart';
import 'package:game_app/services/requestService.dart';
import 'package:game_app/widgets/singleRequestWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestsLists extends StatefulWidget {
  @override
  State<RequestsLists> createState() => _RequestsListsState();
}

class _RequestsListsState extends State<RequestsLists> {
  final RequestService requestService = RequestService();
  late String username;

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RequestModel>>(
      stream: requestService.fetchRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<RequestModel>? requests = snapshot.data;

        if (requests == null || requests.isEmpty) {
          return Center(child: Text('No requests found.'));
        }
        List<RequestModel> filteredRequests =
            requests.where((request) => request.senderId == username).toList();

        if (filteredRequests.isEmpty) {
          return Center(child: Text('No Sent requests found.'));
        }

        return ListView.separated(
          itemCount: filteredRequests.length,
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemBuilder: (context, index) {
            RequestModel filteredRequest = filteredRequests[index];
            if (filteredRequest.senderId == username) {
              return SingleRequestWidget(
                  isSender: true, request: filteredRequest);
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}
