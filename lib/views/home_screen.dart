import 'dart:convert';
import 'package:teegg/app_theme.dart';
import 'package:teegg/app_theme_notifier.dart';
import 'package:teegg/utils/SizeConfig.dart';
import 'package:teegg/views/loading_screens.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  //ThemeData
  late ThemeData themeData;
  late CustomAppTheme customAppTheme;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  //Other Variables
  bool isInProgress = false;

  String avatarUrl = 'https://firebasestorage.googleapis.com/v0/b/teegg-bc644.appspot.com/o/avatar%2F1610421399085.jpg?alt=media&token=afa33897-201d-4ecf-8a44-cf986b1d5192';
  List<Hero> _heroes = [];

  List imgTeamsList = [
    'blacklisinternational.jpg?alt=media&token=fc82919d-14ef-4590-953e-2cbbb76e155a',
    'bren.jpg?alt=media&token=6e5b214e-b0b8-4991-8db7-6aaadb96d197',
    'smartomega.jpg?alt=media&token=3502f431-275a-472e-b3dd-28c322a12d4b',
    'echo.jpg?alt=media&token=3e2c1c78-7dd0-4cbc-b2ea-2816da5324af',
    'onic.jpg?alt=media&token=43719fa5-4161-44fe-867d-69565a2d9b05',
    'rsg.jpg?alt=media&token=cfc976ee-d3dd-4697-8958-4813de6c62e3',
    'tnc.jpg?alt=media&token=f3a66106-35fe-4664-84ef-fef29d613f8f',
    'nxpevox.jpg?alt=media&token=5001cd1c-fcf1-4e8d-9689-e2919f3cee2d',
  ];

  List nameTeamList = [
    'Blacklist International',
    'Bren Esports',
    'Omega Esports',
    'Echo',
    'Onic PH',
    'RSG PH',
    'TNC Pro',
    'Nexplay Evos',
  ];

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    _loadUserAvatar();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadUserAvatar() async {
    final url = await FirebaseStorage.instance.ref().child('avatar/jamesedwardbaldonadoii.jpg').getDownloadURL();

    if (mounted) {
      setState(() {
        avatarUrl = url;
      });
    }
  }

  Future<List<Hero>> fetchMlbbHeroes(http.Client client) async {
    final response = await http
        .get(Uri.parse('https://mapi.mobilelegends.com/hero/list'));

    if (response.statusCode == 200) {
      // then parse the JSON.
      return parseHero(response.body);
    } else {
      // then throw an exception.
      throw Exception('Failed to load heroes');
    }
  }

  List<Hero> parseHero(String responseBody) {
    final parsed = jsonDecode(responseBody)['data'].cast<Map<String, dynamic>>();
    return parsed.map<Hero>((json) => Hero.fromJson(json)).toList();
  }

  _loadHomeData() async {
    var response = await fetchMlbbHeroes(http.Client());
    List<Hero> heroes = response;

    setState(() {
      isInProgress = false;
      _heroes = heroes;
    });
  }

  Future<void> _refresh() async {

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
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: SafeArea(
              child: Scaffold(
                  backgroundColor: customAppTheme.bgLayer1,
                  body: RefreshIndicator(
                    onRefresh: _refresh,
                    backgroundColor: customAppTheme.bgLayer1,
                    color: themeData.colorScheme.primary,
                    key: _refreshIndicatorKey,
                    child: Column(
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
                        )
                      ],
                    ),
                  )),
            ));
      },
    );
  }

  _buildBody() {
    if (isInProgress) {
      return LoadingScreens.getHomeLoading(context, themeData, customAppTheme);
    } else if (!isInProgress) {
      return Container(
          padding: Spacing.only(left: 20, top: 20, right: 20),
          child: ListView(
            children: [
              _userProfile(),
              _sliderBanner(),
              _categoriesWidget(),
              _mlbbHeroes(),
            ],
          ));
    }
  }

  _userProfile() {
    String? name = '';

    if (FirebaseAuth.instance.currentUser != null) {
      name = FirebaseAuth.instance.currentUser?.displayName;
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              "Welcome",
              style: AppTheme.getTextStyle(
                themeData.textTheme.headline6,
              )),
          Text(
            name ?? '',
            style: AppTheme.getTextStyle(
                themeData.textTheme.headline6,
                color: themeData.colorScheme.primary, fontWeight: 700),
          ),
        ],
      ),
      InkWell(
        onTap: () {},
        child: ClipOval(
          child: Container(
            decoration: BoxDecoration(
                color: themeData.colorScheme.primary.withAlpha(20),
                border: Border.all(width: 1),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(avatarUrl),
                )),
            height: MySize.size54,
            width: MySize.size54,
          ),
        ),
      )
    ]);
  }

  _sliderBanner() {
    return Column(
      children: [
        CarouselSlider(
            options: CarouselOptions(
                viewportFraction: 1.2,
                aspectRatio: 2,
                enlargeCenterPage: true,
                autoPlay: true,
                scrollDirection: Axis.horizontal),
            items: [1, 2, 3, 4].map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    margin: Spacing.only(top: 10),
                    child: Image(
                      image: AssetImage('./assets/images/banners/$i.jpg'),
                    ),
                  );
                },
              );
            }).toList()),
      ],
    );
  }

  _mlbbHeroes(){
    List<Widget> list = [];

    if(_heroes.isEmpty) {
      return Container();
    }

    for (int i = 0; i < 8; i++) {
      if (_heroes[i].name.length <= 6) {
        list.add(
          InkWell(
              onTap: () {},
              child: Column(
                children: <Widget>[
                  Container(
                    width: MySize.getScaledSizeWidth(40),
                    height: MySize.getScaledSizeWidth(40),
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: Spacing.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image(
                        image: NetworkImage('https:${_heroes[i].key}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: MySize.size52,
                    padding: Spacing.top(8),
                    child: Text(
                      _heroes[i].name,
                      maxLines: 2,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                      style: AppTheme.getTextStyle(themeData.textTheme.caption,
                          fontWeight: 600, letterSpacing: 0),
                    ),
                  )
                ],
              )
          )
        );
      }
    }

    list.add(
      InkWell(
        onTap: () {
          // load all mlbb heroes
        },
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                Container(
                  width: MySize.getScaledSizeWidth(40),
                  height: MySize.getScaledSizeWidth(40),
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: Spacing.all(2),
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: Container(
                    width: MySize.getScaledSizeWidth(20),
                    height: MySize.getScaledSizeWidth(20),
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: Spacing.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image(
                        image: NetworkImage('https:${_heroes[23].key}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  child: Container(
                    width: MySize.getScaledSizeWidth(20),
                    height: MySize.getScaledSizeWidth(20),
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: Spacing.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image(
                        image: NetworkImage('https:${_heroes[29].key}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  child: Container(
                    width: MySize.getScaledSizeWidth(20),
                    height: MySize.getScaledSizeWidth(20),
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: Spacing.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image(
                        image: NetworkImage('https:${_heroes[72].key}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  child: Container(
                    width: MySize.getScaledSizeWidth(20),
                    height: MySize.getScaledSizeWidth(20),
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: Spacing.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image(
                        image: NetworkImage('https:${_heroes[27].key}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ]
            ),
            Container(
              width: MySize.size52,
              padding: Spacing.top(8),
              child: Text(
                'More...',
                maxLines: 2,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.center,
                style: AppTheme.getTextStyle(themeData.textTheme.caption,
                    fontWeight: 600, letterSpacing: 0),
              ),
            )
          ]
        )
      )
    );

    return Container(
      padding: Spacing.only(top: 30, bottom: 10),
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              'MLBB Heroes',
              overflow: TextOverflow.clip,
              textAlign: TextAlign.left,
              style: AppTheme.getTextStyle(
                  themeData.textTheme.headline6,
                  fontWeight: 700,
                  letterSpacing: 0,
                  color: themeData.colorScheme.secondary
              ),
            ),
          ),
          Container(
            padding: Spacing.only(top: 20),
            child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.center,
                children: list
            ),
          )
        ],
      ),
    );
  }

  _categoriesWidget() {
    List<Widget> list = [];
    for (int i = 0; i < imgTeamsList.length; i++) {
      list.add(InkWell(onTap: () {}, child: _singleCategory(i)));
      // list.add(SizedBox(width: MySize.size24));
    }

    // * Add Show All Categories Menu
    return Container(
      padding: Spacing.only(top: 20),
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        spacing: 5,
        children: list,
      ),
    );
  }

  _singleCategory(int index) {
    return Column(
      children: <Widget>[
        Container(
          width: MySize.getScaledSizeWidth(55),
          height: MySize.getScaledSizeWidth(55),
          decoration: BoxDecoration(
            color: themeData.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: Spacing.all(7),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image(
              image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/teegg-bc644.appspot.com/o/teams%2F${imgTeamsList[index]}'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          width: MySize.size76,
          padding: Spacing.top(8),
          child: Text(
            nameTeamList[index],
            maxLines: 2,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
            style: AppTheme.getTextStyle(themeData.textTheme.caption,
                fontWeight: 600, letterSpacing: 0),
          ),
        )
      ],
    );
  }
}

class Hero {
  final String name;
  final String heroid;
  final String key;

  const Hero({
    required this.name,
    required this.heroid,
    required this.key
  });

  factory Hero.fromJson(Map<String, dynamic> json) {
    return Hero(
      name: json['name'],
      heroid: json['heroid'],
      key: json['key'],
    );
  }
}