import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wtqrscan/api/auth_service.dart';
import 'package:wtqrscan/api/checkInternet.dart';
import 'package:wtqrscan/class/checkAppVersion.dart';
import 'package:wtqrscan/class/share.dart';
import 'package:wtqrscan/screens/form_checkstock.dart';
import 'package:wtqrscan/screens/form_instock.dart';
import 'package:wtqrscan/screens/form_main.dart';
import 'package:wtqrscan/screens/form_login.dart';
import 'package:wtqrscan/screens/form_outstock.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // ล็อกให้ใช้ในแนวตั้งเท่านั้น
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WT QR Scan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// SplashScreen: ใช้ในการเช็ค Cookie เพื่อเปลี่ยนหน้า
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService authService = AuthService();
  final checkInternet = CheckInternet();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInternetAndVersion(context);
    });
  }

  Future<void> _checkInternetAndVersion(BuildContext context) async {
    // ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
    await checkInternet.checkInternetAndProceed_WithTry(context, () async {
      // สร้างอินสแตนซ์ของ AppVersionChecker
      checkAppVersion versionChecker = checkAppVersion(context);

      // เรียกใช้การตรวจสอบเวอร์ชัน
      bool isVersionValid = await versionChecker.checkVersion(
        onVersionLoaded: (version) {
          // อัปเดตเวอร์ชันใน state
          //setState(() {
          //  this.version = version;
          //});
        },
      );

      if (isVersionValid) {
        // หากเวอร์ชันถูกต้อง ให้ดำเนินการตรวจสอบการเข้าสู่ระบบ
        _checkLoginStatus();
      }
    });
  }

  // ตรวจสอบสถานะการล็อกอิน
  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = await authService.checkAuthStatus();
    Map<String, String?> loginData = await authService.getLoginData();

    if (isLoggedIn && loginData['username'] != null) {
      Share.Uname = loginData['username'] ?? '';
      Share.Name = loginData['name'] ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } else if (loginData['username'] != null) {
      Share.Uname = loginData['username'] ?? '';
      Share.Name = loginData['name'] ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Gradient colors for each tab
  final List<List<Color>> _tabGradients = [
    [Colors.blue.shade200, Colors.blue.shade400], // HOME
    [Colors.yellow.shade200, Colors.yellow.shade400], // IN
    [Colors.green.shade200, Colors.green.shade400], // OUT
    [Colors.orange.shade200, Colors.orange.shade400], // STOCK
  ];

  // Indicator colors for each tab
  final List<Color> _indicatorColors = [
    Colors.blue, // HOME
    Colors.yellow, // IN
    Colors.green, // OUT
    Colors.orange, // STOCK
  ];

  double _animationValue = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Update animation value when tab changes
    _tabController.animation!.addListener(() {
      setState(() {
        _animationValue = _tabController.animation!.value;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate current and next tab indices
    int currentIndex = _animationValue.floor();
    int nextIndex = (_animationValue.ceil() < _tabGradients.length)
        ? _animationValue.ceil()
        : currentIndex;

    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 360 ? 24.0 : 26.0;

    // Blend gradient colors and indicator color
    double transitionProgress = _animationValue - currentIndex;
    List<Color> blendedGradient = [
      Color.lerp(_tabGradients[currentIndex][0], _tabGradients[nextIndex][0],
          transitionProgress)!,
      Color.lerp(_tabGradients[currentIndex][1], _tabGradients[nextIndex][1],
          transitionProgress)!,
    ];
    Color blendedIndicatorColor = Color.lerp(_indicatorColors[currentIndex],
        _indicatorColors[nextIndex], transitionProgress)!;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: blendedGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: TabBarView(
            controller: _tabController,
            children: const [
              MainScreen(),
              InStock(),
              OutStock(),
              CheckStock(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: blendedGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: blendedIndicatorColor,
            unselectedLabelColor: Colors.white70,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 7.0,
                color: blendedIndicatorColor,
              ),
              insets: const EdgeInsets.symmetric(horizontal: 20.0),
            ),
            tabs: [
              Tab(icon: Icon(Icons.home, size: iconSize), text: "HOME"),
              Tab(
                  icon: Icon(Icons.add_circle_outline, size: iconSize),
                  text: "IN"),
              Tab(
                  icon: Icon(Icons.remove_circle_outline, size: iconSize),
                  text: "OUT"),
              Tab(
                  icon: Icon(Icons.inventory_2_outlined, size: iconSize),
                  text: "STOCK"),
            ],
            onTap: (index) {
              // Animate to the selected tab index
              _tabController.animateTo(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
      ),
    );
  }
}
