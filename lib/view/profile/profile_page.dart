import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woc/provider/user_provider.dart';
import 'package:woc/view/profile/edit_profile.dart';
import 'package:woc/model/community/post.dart';
import 'package:woc/model/user.dart';
import 'package:woc/view/profile/follow_list_page.dart';
import 'package:woc/theme/text_color.dart';
import 'package:woc/theme/widget_color.dart';
import 'package:woc/widget/community/create_post_card.dart';
import 'package:woc/service/backend_service.dart';
import 'package:woc/extension/number_format.dart';

enum ImageType { profile, background }

class ProfilePage extends StatefulWidget {
  final String? UID;
  final String? currentUserRole;
  const ProfilePage({ super.key, this.UID, this.currentUserRole });
  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final widgetColors = WidgetColor();
  final fontColor = TextColor();
  final BackendService _backendService = BackendService();
  late Future<dynamic> _userDataFuture;
  late Future<List<Post>> _userPostsFuture;

  @override
  void initState() {
    super.initState();
    _handleRefresh();
  }

  Future<void> _handleRefresh() async {
    final user = Provider.of<UserProvider>(context, listen: false).queryUser;
    final uid = widget.UID ?? user?.uid.toString();
    
    if (uid != null) {
      setState(() {
        _userDataFuture = _backendService.getUserDataByUID(uid);
        // Assuming there's a method for user posts
        _userPostsFuture = _backendService.getUserPosts(uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = Provider.of<UserProvider>(context, listen: true).queryUser;

    return Scaffold(
      body: FutureBuilder<dynamic>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("ไม่พบข้อมูลผู้ใช้"));
          }

          final userData = snapshot.data!;
          final currentUID = currentUser?.uid.toString() ?? '';
          final targetUID = widget.UID ?? currentUID;

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: Colors.orange,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 111, 52, 234),
                    Color.fromARGB(255, 121, 78, 239),
                    Color.fromARGB(255, 255, 108, 4),
                    Color.fromARGB(255, 255, 201, 163),
                  ],
                ),
              ),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: widgetColors.widgetShadow(),
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                      color: widgetColors.lightTheme(),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showFullImage(
                                  userData['user_background_image'] ?? '',
                                  ImageType.background,
                                );
                              },
                              child: ClipRRect(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 150,
                                  child:
                                      (userData['user_background_image'] != null &&
                                          userData['user_background_image'] != '')
                                      ? Image.network(
                                          userData['user_background_image'],
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/default_background.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  27,
                                  10,
                                  15,
                                  10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: targetUID == currentUID
                                          ? ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                backgroundColor: widgetColors
                                                    .confirmButton(),
                                              ),
                                              onPressed: () {
                                                // Assuming EditProfilePage exists and takes User model
                                                // Simplified navigation for this refactor
                                                _handleRefresh();
                                              },
                                              child: const Text(
                                                'แก้ไขโปรไฟล์',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                FutureBuilder<bool>(
                                                  future: _backendService
                                                      .hasUserFollowed(
                                                        targetUID,
                                                        currentUID,
                                                      ),
                                                  builder: (context, snapshot) {
                                                    final isFollowing =
                                                        snapshot.data ?? false;
                                                    return SizedBox(
                                                      height: 30,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              isFollowing
                                                              ? Colors.grey[200]
                                                              : widgetColors
                                                                    .followButton(),
                                                          elevation: 0,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 14,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          if (isFollowing) {
                                                            await _backendService
                                                                .unfollowUser(
                                                                  targetUID,
                                                                  currentUID,
                                                                );
                                                          } else {
                                                            await _backendService
                                                                .followUser(
                                                                  targetUID,
                                                                  currentUID,
                                                                );
                                                          }
                                                          _handleRefresh();
                                                        },
                                                        child: Text(
                                                          isFollowing
                                                              ? 'กำลังติดตาม'
                                                              : 'ติดตาม',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: isFollowing
                                                                ? Colors.black87
                                                                : Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: Text(
                                        userData['user_name'] ?? '',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        userData['user_bio'] ?? '',
                                        style: TextStyle(
                                          color: fontColor.textDark(),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          left: 25,
                          top: 90,
                          child: GestureDetector(
                            onTap: () {
                              _showFullImage(
                                userData['user_profile_image'] ?? '',
                                ImageType.profile,
                              );
                            },
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  197,
                                  197,
                                  197,
                                ),
                                backgroundImage: (userData['user_profile_image'] != null &&
                                        userData['user_profile_image'] != '')
                                    ? NetworkImage(userData['user_profile_image'])
                                    : const AssetImage(
                                            'assets/default_profile.png',
                                          )
                                          as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetails(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: fontColor.profilePageSubTitleDarkColor(),
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          value.toString(),
          style: TextStyle(
            color: fontColor.profilePageSubTitleLightColor(),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(User userData) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: widgetColors.boxShadowColor())],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBodyDetails('น้ำหนัก', userData.weight),
                _buildBodyDetails('ส่วนสูง', userData.height),
                _buildBodyDetails('อายุ', userData.age),
                _buildBodyDetails('BMI', userData.BMI),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildStatGrid(userData),
          const SizedBox(height: 15),
          _buildPostSection(),
        ],
      ),
    );
  }

  Widget _buildStatGrid(User userData) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      children: [
        _buildStatCard(
          Icons.directions_walk,
          'ก้าวทั้งหมด',
          userData.totalStep.toString(),
        ),
        _buildStatCard(
          Icons.local_fire_department,
          'แคลอรี่ทั้งหมด',
          userData.totalCalories.toString(),
        ),
        _buildStatCard(
          Icons.location_on,
          'ระยะทางทั้งหมด',
          userData.totalDistance.toString(),
        ),
        _buildStatCard(
          Icons.access_time,
          'ระยะเวลาทั้งหมด',
          userData.totalTime.timeHourFormatShort,
        ),
        _buildStatCard(
          Icons.menu_book,
          'จำนวนบทเรียน',
          userData.lessongComplete.toString(),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widgetColors.boxShadowColor(),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange, size: 22),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: fontColor.profilePageSubTitleLightColor(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: fontColor.textDark(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'โพสต์ทั้งหมด',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: fontColor.textDark(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildPosts(),
      ],
    );
  }

  Widget _buildPosts() {
    return FutureBuilder<List<Post>>(
      future: _userPostsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('ยังไม่มีโพสต์')),
          );
        }

        final posts = snapshot.data!;

        return ListView.builder(
          itemCount: posts.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
              children: [
                CreatePostCard(
                  post: posts[index],
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBodyDetails(String label, var value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 12,
            color: fontColor.profilePageSubTitleDarkColor(),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: fontColor.profilePageSubTitleLightColor(),
          ),
        ),
      ],
    );
  }

  void _showFullImage(String imageUrl, ImageType type) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              InteractiveViewer(
                child: Center(
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl)
                      : Image.asset(
                          type == ImageType.profile
                              ? 'assets/default_profile.png'
                              : 'assets/default_background.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}