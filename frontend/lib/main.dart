import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/api_client.dart';
import 'core/app_router.dart';
import 'core/config.dart';
import 'core/repository.dart';
import 'core/theme.dart';
import 'features/auth/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  if (AppConfig.hasSupabase) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  runApp(const XaneeApp());
}

class XaneeApp extends StatefulWidget {
  const XaneeApp({super.key});

  @override
  State<XaneeApp> createState() => _XaneeAppState();
}

class _XaneeAppState extends State<XaneeApp> {
  late final AuthService _auth = AuthService();
  late final ApiClient _api = ApiClient(_auth);
  late final DataRepository _repo = DataRepository(_api);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _auth),
        Provider.value(value: _repo),
      ],
      child: MaterialApp.router(
        title: 'XANEE',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        routerConfig: buildRouter(_auth),
      ),
    );
  }
}
