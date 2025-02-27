import 'dart:io';

import 'package:mason/mason.dart';

void run(HookContext context) async {
  context.logger.info('Post generation started');

  context.logger.progress('Installing flutter packages');

  final hasFirebase = context.vars['use_firebase'] as bool;
  final hasSentry = context.vars['use_sentry'] as bool;
  final depprogress =
      context.logger.progress('Installing general dependencies');

  /// Run `Add dependencies` after generation.
  final deps = <String>[
    'intl',
    'flash',
    'flutter_svg',
    'clock',
    'photo_view',
    'shimmer',
    'auto_size_text_plus',
    'go_router',
    'qr_flutter',
    'mobile_scanner',
    'quick_actions',
    'permission_handler',
    'flutter_displaymode',
    'internet_connection_checker',
    'shared_preferences',
    'flutter_secure_storage',
    'hooks_riverpod',
    'url_launcher',
    'force_update_helper',
    'in_app_review',
    'dio',
    if (hasSentry) 'sentry_flutter',
    if (hasSentry) 'sentry_dio',
    'feedback',
    'feedback_sentry',
    'package_info_plus',
    'platform_info',
    if (hasFirebase) 'mixpanel_flutter',
    if (hasFirebase) 'firebase_core',
    if (hasFirebase) 'firebase_auth',
    if (hasFirebase) 'firebase_analytics',
    if (hasFirebase) 'firebase_remote_config',
    'cached_network_image',
    'riverpod_annotation',
    'freezed_annotation',
    'json_annotation',
    'equatable',
  ];
  try {
    await Process.run(
      'dart',
      ['pub', 'add', ...deps],
      runInShell: true,
    );
    depprogress.complete('All general dependencies added');
  } catch (e) {
    depprogress.cancel();
    depprogress.fail(e.toString());
  }
  final devdepprogress = context.logger.progress('Installing dev dependencies');

  /// Run `Add dev dependencies` after generation.
  final devdeps = <String>[
    'flutter_lints',
    'go_router_builder',
    'build_runner',
    'json_serializable',
    'freezed',
    'riverpod_generator',
    'custom_lint',
    'riverpod_lint',
    'flutter_flavorizr',
    if (hasSentry) 'sentry_dart_plugin',
    'mocktail',
  ];
  try {
    await Process.run(
      'dart',
      ['pub', 'add', '--dev', ...devdeps],
      runInShell: true,
    );
    devdepprogress.complete('All dev dependencies added');
  } catch (e) {
    devdepprogress.cancel();
    devdepprogress.fail(e.toString());
  }

  final projectName = context.vars['project_name'] as String;

  final packageprogress =
      context.logger.progress('Installing flutter packages');

  /// Run `flutter packages get` after generation.
  try {
    await Process.run(
      'flutter',
      [
        'packages',
        'get',
        '--directory=$projectName',
      ],
      runInShell: true,
    );
    packageprogress.complete('Got all flutter packages');
  } catch (e) {
    packageprogress.cancel();
    packageprogress.fail(e.toString());
  }

  /// Run `flutter pub get` after generation.
  final additionalpackageprogress =
      context.logger.progress('Installing dart packages');
  try {
    await Process.run(
      'dart',
      ['pub', 'get'],
      runInShell: true,
    );
    additionalpackageprogress.complete('Got dart packages');
  } catch (e) {
    additionalpackageprogress.cancel();
    additionalpackageprogress.fail(e.toString());
  }

  /// Run `Remove flutter_gen` after generation.
  final fluttergenprogress =
      context.logger.progress('Removing conflicting packages');
  try {
    await Process.run(
      'dart',
      ['pub', 'remove', 'flutter_gen'],
      runInShell: true,
    );
    fluttergenprogress.complete('Removed conflicting packages');
  } catch (e) {
    fluttergenprogress.cancel();
    fluttergenprogress.fail(e.toString());
  }

  /// Run `flutter pub run build_runner` after generation.
  final codegenprogress =
      context.logger.progress('Generating localization and routes ');

  try {
    await Process.run(
      'flutter',
      ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      runInShell: true,
    );
    codegenprogress.complete();
  } catch (e) {
    codegenprogress.cancel();
    codegenprogress.fail(e.toString());
  }

  /// Run `flutter pub get` after generation.
  final lpackageprogress =
      context.logger.progress('Checking updation of pubspec');
  try {
    await Process.run(
      'dart',
      ['pub', 'get'],
      runInShell: true,
    );
    lpackageprogress.complete('pubspec updation compelete');
  } catch (e) {
    lpackageprogress.cancel();
    additionalpackageprogress.fail(e.toString());
  }
  context.logger.info('Post generation completed');

  // Some imports are relative to the user specified package name, hence
  // we try to fix the import directive ordering after the template has
  // been generated.
  //
  // We only fix for the [directives_ordering](https://dart.dev/tools/linter-rules/directives_ordering)
  // linter rules, as the other rule should be tackled by the template itself.
  final codefixprogress = context.logger.progress('Fixing & Updating code');

  try {
    await Process.run(
      'dart',
      ['fix', projectName, '--apply', '--code=directives_ordering'],
      runInShell: true,
      workingDirectory: Directory.current.path,
    );
    codefixprogress.complete();
  } catch (e) {
    codefixprogress.cancel();
    codefixprogress.fail(e.toString());
  }

  /// Run `mason upgrade -g` for additional updates for mason
  final masonpackageupgrade = context.logger.progress('Upgrading mason');

  try {
    await Process.run(
      'mason',
      ['upgrade', '-g'],
      runInShell: true,
    );
    masonpackageupgrade.complete('Upgraded mason');
  } catch (e) {
    masonpackageupgrade.cancel();
    masonpackageupgrade.fail(e.toString());
  }

  /// Run `Remove flutter_gen` after generation.
  final coverageprogress = context.logger.progress('Generating coverage');
  try {
    await Process.run(
      'flutter',
      ['test', '--coverage'],
      runInShell: true,
    );
    coverageprogress.complete('Coverage file generate');
  } catch (e) {
    coverageprogress.cancel();
    coverageprogress.fail(e.toString());
  }
  //flutter test --coverage
  context.logger.info(
      """\n\n 🎉 Congratulations on generating your code using the provided template! with version
      \n 🚀 You've built an impressive library with powerful features.
      \n 💪 Utilize Riverpod for efficient state management,
      \n Go Router for seamless navigation, and Dio for API requests.
      \n 🌐📥 With velocity_x, create stunning UIs, while flex_color_scheme provides theming and persistence.
      \n 🎨💾 Flash enables engaging alerting UIs, and Hive with storage provider facilitates efficient database usage.
      \n 🗄️💡 Localize and internationalize your app using l18n.
      \n 🌍🌐 Handle scenarios like no internet connection and app locale selection with internet_connection_checker's default UIs.
      \n 🌐🚫 Ensure responsiveness across devices with responsive_framework.\n 📱💻 And use talker_flutter for logging and debugging.
      \n 🗣️🐛 Keep up the great work! Happy coding! 💻✨
      \n Please uncomment custom lint option in analysis_options.yaml to enable riverpod lint
      \n\n Love Flutter from Edilson Matola! do visit https://github.com/edilsonmatola ❤️🔥\n\n""");
}
