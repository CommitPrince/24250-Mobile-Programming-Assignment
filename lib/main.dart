import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services/connectivity_service.dart';

import 'pages/sign_up_page.dart';
import 'pages/login_page.dart';
import 'pages/calculator_page.dart';
import 'pages/settings_page.dart';
import 'pages/contact_page.dart';
import 'pages/contact_list_page.dart';
import 'providers/theme_provider.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode = prefs.getString('language') ?? 'en';
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(languageCode: languageCode),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String languageCode;

  MyApp({required this.languageCode});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.languageCode);
  }

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          locale: _locale,
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode &&
                  supportedLocale.countryCode == locale?.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: Builder(
            builder: (context) => DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(S.of(context)?.calculator ?? 'Calculator'),
                  bottom: TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.person), text: S.of(context)?.sign_up ?? 'Sign Up'),
                      Tab(icon: Icon(Icons.login), text: S.of(context)?.login ?? 'Login'),
                      Tab(icon: Icon(Icons.calculate), text: S.of(context)?.calculator ?? 'Calculator'),
                    ],
                  ),
                ),
                drawer: MyDrawer(),
                body: TabBarView(
                  children: [
                    SignUpPage(),
                    LoginPage(),
                    CalculatorPage(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final ImagePicker _picker = ImagePicker();
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profileImagePath');
    });
  }

  Future<void> _saveProfileImage(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profileImagePath', path);
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      await _saveProfileImage(pickedFile.path);
      setState(() {
        _profileImagePath = pickedFile.path;
      });
      Fluttertoast.showToast(msg: 'Picked image: ${pickedFile.path}');
    }
  }

  Future<void> _requestPermission(Permission permission, Function onGranted) async {
    final status = await permission.request();
    if (status.isGranted) {
      Fluttertoast.showToast(msg: 'Permission granted');
      onGranted();
    } else if (status.isDenied) {
      Fluttertoast.showToast(msg: 'Permission denied');
    } else if (status.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: 'Permission permanently denied, please enable it in settings');
      openAppSettings();
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text(S.of(context)?.select_from_gallery ?? 'Select from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _requestPermission(Permission.storage, () {
                    _pickImage(context, ImageSource.gallery);
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(S.of(context)?.take_a_picture ?? 'Take a Picture'),
                onTap: () async {
                  Navigator.pop(context);
                  await _requestPermission(Permission.camera, () {
                    _pickImage(context, ImageSource.camera);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange[400]!, Colors.orange[700]!],
              ),
            ),
            accountName: Text(''),
            accountEmail: Text(''),
            currentAccountPicture: GestureDetector(
              onTap: () => _showImageSourceActionSheet(context),
              child: CircleAvatar(
                backgroundImage: _profileImagePath != null && _profileImagePath!.isNotEmpty
                    ? FileImage(File(_profileImagePath!))
                    : AssetImage('assets/default_profile_picture.png') as ImageProvider,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 12.0,
                    child: Icon(
                      Icons.camera_alt,
                      size: 15.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(S.of(context)?.sign_up ?? 'Sign Up'),
                  onTap: () {
                    Navigator.pop(context);
                    DefaultTabController.of(context)?.animateTo(0);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.login),
                  title: Text(S.of(context)?.login ?? 'Login'),
                  onTap: () {
                    Navigator.pop(context);
                    DefaultTabController.of(context)?.animateTo(1);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calculate),
                  title: Text(S.of(context)?.calculator ?? 'Calculator'),
                  onTap: () {
                    Navigator.pop(context);
                    DefaultTabController.of(context)?.animateTo(2);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.contacts),
                  title: Text(S.of(context)?.sync_contacts ?? 'Sync Contacts'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text(S.of(context)?.contact_list ?? 'Contact List'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContactListPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(S.of(context)?.settings_account ?? 'Settings & Account'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
