import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_orientation.dart';

final whoOrientationProvider = Provider<AppOrientation>(
  (ref) => AppOrientation.instance,
);
