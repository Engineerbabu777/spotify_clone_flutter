import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static MaterialPageRoute route() => MaterialPageRoute(
    builder: (context) {
      return HomeScreen();
    },
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
