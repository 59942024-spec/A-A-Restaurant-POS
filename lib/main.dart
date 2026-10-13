import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/access_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const ServeEaseApp());
}

class ServeEaseApp extends StatefulWidget {
  const ServeEaseApp({super.key});

  @override
  State<ServeEaseApp> createState() => _ServeEaseAppState();
}

class _ServeEaseAppState extends State<ServeEaseApp> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A & A Restaurant POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AccessScreen(),
    );
  }
}
