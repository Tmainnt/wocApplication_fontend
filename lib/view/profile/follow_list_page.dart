import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woc/model/user.dart';
import 'package:woc/view/profile/profile_page.dart';
import 'package:woc/theme/widget_color.dart';
import 'package:woc/widget/community/report_user_dialog.dart';
import 'package:woc/provider/user_provider.dart';
import 'package:woc/service/backend_service.dart';

class FollowListPage extends StatefulWidget {
  final String profileOwnerUID;
  final String currentUID;
  final bool isFollowersMode;
  final String currentRole;

  const FollowListPage({
    super.key,
    required this.profileOwnerUID,
    required this.currentUID,
    required this.isFollowersMode,
    required this.currentRole,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  final widgetColors = WidgetColor();
  final BackendService _backendService = BackendService();
  late Future<List<String>> _followListFuture;

  @override
  void initState() {
    super.initState();
    _loadFollowList();
  }

  void _loadFollowList() {
    // Assuming backend returns list of UIDs
    _followListFuture = widget.isFollowersMode
        ? _backendService.getFollowers(widget.profileOwnerUID)
        : _backendService.getFollowing(widget.profileOwnerUID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close, color: Colors.white),
        ),
        title: Text(
          widget.isFollowersMode ? "ผู้ติดตาม" : "กำลังติดตาม",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: WidgetColor().applicationMainTheme(),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: _followListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                widget.isFollowersMode
                    ? "ยังไม่มีผู้ติดตาม"
                    : "ยังไม่ได้ติดตามใคร",
              ),
            );
          }

          final followList = snapshot.data!;
          return ListView.builder(
            itemCount: followList.length,
            itemBuilder: (context, index) {
              String targetUID = followList[index];

              return FutureBuilder<dynamic>(
                future: _backendService.getUserDataByUID(targetUID),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox.shrink();

                  // Using dynamic map for user data as model might need update
                  final userMap = userSnapshot.data!;
                  final userName = userMap['user_name'] ?? 'Unknown';
                  final profileUrl = userMap['user_profile_image'] ?? '';

                  return GestureDetector(
                    onTap: () {
                      _goToProfile(targetUID);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profileUrl.isNotEmpty
                            ? NetworkImage(profileUrl)
                            : const AssetImage('assets/default_profile.png')
                                  as ImageProvider,
                      ),
                      title: Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (targetUID != widget.currentUID)
                            _buildFollowButton(targetUID),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFollowButton(String targetUID) {
    return FutureBuilder<bool>(
      future: _backendService.hasUserFollowed(targetUID, widget.currentUID),
      builder: (context, snapshot) {
        final isFollowing = snapshot.data ?? false;
        return TextButton(
          onPressed: () async {
            if (isFollowing) {
              await _backendService.unfollowUser(targetUID, widget.currentUID);
            } else {
              await _backendService.followUser(targetUID, widget.currentUID);
            }
            setState(() {
              _loadFollowList(); // Refresh list/button state
            });
          },
          child: Text(
            isFollowing ? "เลิกติดตาม" : "ติดตาม",
            style: TextStyle(
              color: isFollowing ? Colors.grey : Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  void _showMoreOptions(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text("รายงานผู้ใช้"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => ReportUserDialog(
                    reportedUID: user.uid,
                    reportedName: user.name,
                    postId: '',
                    label: 'report_user',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _goToProfile(String targetUID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pedometer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const Text(
                  '& Workout',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widgetColors.applicationMainTheme(),
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          body: ProfilePage(),
        ),
      ),
    );
  }
}