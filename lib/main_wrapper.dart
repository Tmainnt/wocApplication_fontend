import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woc/provider/user_provider.dart';
import 'package:woc/service/token_service.dart';
import 'package:woc/theme/text_color.dart';
import 'package:woc/theme/widget_color.dart';
import 'package:woc/view/activity/pedometer_page.dart';
import 'package:woc/view/authentication/login_form.dart';
import 'package:woc/view/community/chat_page.dart';
import 'package:woc/view/home_page.dart';
import 'package:woc/service/cache_service.dart';
import 'package:woc/view/profile/profile_page.dart';
import 'package:woc/widget/navbar/bottom_navbar.dart';
import 'package:woc/widget/appbar/top_appbar.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {

  WidgetColor widgetColor = WidgetColor();
  TextColor textColor = TextColor();
  int currentIndex = 0;
  final List<Widget> pages = [
    HomePage(),
    PedometerPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context){
    CacheService().setUserProvider();
    return FutureBuilder(
      future: TokenService.getAccessToken(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: TopAppbar(
        centerText: centerTextCreate(),
        leadingContent: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              barrierColor: Colors.black87,
              builder: (context) {
                return ListView(
                  padding: EdgeInsets.only(left: 10, top: 60),
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      child: Row(   
                        mainAxisAlignment:  MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.home,
                            size: 25,
                            color: widgetColor.iconWithBlackBackground(),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Home",
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor.subText(),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Provider.of<UserProvider>(context, listen: false).clearUser();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginForm()),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.logout,
                            size: 25,
                            color: widgetColor.iconWithBlackBackground(),
                          ),

                          SizedBox(width: 10),

                          Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor.subText(),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.cancel,
                            size: 25,
                            color: widgetColor.iconWithBlackBackground(),
                          ),

                          SizedBox(width: 10),

                          Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor.subText(),
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
          icon: Icon(Icons.menu),
        ),
        trailingContent: IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatPage()),
            );
          },
        ),
      ),
            body: pages[currentIndex],
            bottomNavigationBar: BottomNavbar(
              index: currentIndex,
              onTap: (index){
                setState(() {
                  currentIndex = index;
                });
              }
            ),
          );
        }
        return LoginForm();
      },
    );
  }

  Widget centerTextCreate() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Workout",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          "& Community",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}