import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/utils/app_orientation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppOrientation.instance.portrait();
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Nunito'], license);
  });
  runApp(const ProviderScope(child: OynikaApp()));
}
