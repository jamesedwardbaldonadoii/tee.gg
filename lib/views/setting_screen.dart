import 'package:teegg/utils/SizeConfig.dart';
import 'package:teegg/views/select_theme_dialog.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:teegg/views/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_theme.dart';
import '../app_theme_notifier.dart';
import 'about_app_dialog.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  //ThemeData
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //Other Variables
  bool isInProgress = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);

        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeData,
            home: Scaffold(
                key: _scaffoldKey,
                backgroundColor: customAppTheme.bgLayer1,
                appBar: AppBar(
                  backgroundColor: themeData.colorScheme.primary,
                  elevation: 0,
                  centerTitle: true,
                  title: Text("Setting",
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme?.headline6,
                          fontWeight: 600,
                          color: themeData.colorScheme.onPrimary)),
                ),
                body: Column(
                  children: [
                    SizedBox(
                      height: MySize.size3,
                      child: isInProgress
                          ? LinearProgressIndicator(
                              minHeight: MySize.size3,
                            )
                          : Container(
                              height: MySize.size3,
                            ),
                    ),
                    Expanded(
                      child: _buildBody(),
                    ),
                  ],
                )));
      },
    );
  }

  _buildBody() {
    String? name = '';

    if (FirebaseAuth.instance.currentUser != null) {
      name = FirebaseAuth.instance.currentUser?.displayName;
    }

    return ListView(
      children: <Widget>[
        Padding(
          padding: Spacing.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              ClipOval(
                child: Container(
                  decoration: BoxDecoration(
                      color: themeData.colorScheme.primary.withAlpha(20),
                      border: Border.all(width: 1),
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                          "./assets/images/person.jpg",
                        ),
                      )),
                  height: MySize.size68,
                  width: MySize.size68,
                ),
              ),
              SizedBox(width: MySize.size18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name ?? '',
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.headline6,
                      )),
                  Text("Flutter Developer",
                      style: AppTheme.getTextStyle(
                        themeData.textTheme.caption,
                        fontWeight: 500,
                      )),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        _menuItem(
            title: "Themes",
            icon: MdiIcons.lightbulb,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => const SelectThemeDialog());
            }),
        _menuItem(title: "Dashboard", icon: MdiIcons.home, onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const HomeScreen(),
            ),
          );
        }),
        _menuItem(
            title: "Help & Support",
            icon: MdiIcons.frequentlyAskedQuestions,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => const AboutAppDialog());
            }),
        _menuItem(title: "Logout", icon: MdiIcons.account, onTap: () {
          FirebaseAuth.instance.signOut();
        }),
      ],
    );
  }

  _menuItem({String? title, IconData? icon, required Function onTap}) {
    return InkWell(
        onTap: () { onTap(); },
        child: Container(
            padding: Spacing.fromLTRB(30, 20, 20, 20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: themeData.colorScheme.secondary,
                  size: MySize.size28,
                ),
                SizedBox(width: MySize.size24),
                Text(title!,
                    style: AppTheme.getTextStyle(
                      themeData.textTheme.subtitle1,
                      fontWeight: 600,
                    ))
              ],
            )));
  }
}
