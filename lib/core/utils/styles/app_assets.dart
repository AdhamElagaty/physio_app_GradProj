class AppAssets {
  const AppAssets._();

  static const iconly = _Iconly();

  static const logo = _Logo();

  static const patternAndEffect = _PatternAndEffect();

  static List<String> getAllSvgAssets() {
    return [
      ..._Iconly._getAllSvgs(),
      ..._Logo._getAllSvgs(),
      ..._PatternAndEffect._getAllSvgs(),
    ];
  }
}

class _Iconly {
  const _Iconly();
  static const String _basePath = 'assets/images/icon';

  final bold = const _IconlyBold();
  final bulk = const _IconlyBulk();
  final stroke = const _IconlyStroke();

  static List<String> _getAllSvgs() {
    return [
      ..._IconlyBold._getAllSvgs(),
      ..._IconlyBulk._getAllSvgs(),
      ..._IconlyStroke._getAllSvgs(),
    ];
  }
}

class _IconlyBold {
  const _IconlyBold();
  static const String _basePath = '${_Iconly._basePath}/bold';

  final String arrowRightSquare = '$_basePath/arrow_right_square.svg';
  final String category = '$_basePath/category.svg';
  final String chat = '$_basePath/chat.svg';
  final String colorSchemeSwitch = '$_basePath/color_scheme_switch.svg';
  final String heart = '$_basePath/heart.svg';
  final String home = '$_basePath/home.svg';
  final String languageSwitch = '$_basePath/language_switch.svg';
  final String notification = '$_basePath/notification.svg';
  final String profile = '$_basePath/profile.svg';
  final String send = '$_basePath/send.svg';
  final String setting = '$_basePath/setting.svg';
  final String tickSquare = '$_basePath/tick_square.svg';
  final String timeCircle = '$_basePath/time_circle.svg';

  static List<String> _getAllSvgs() => [
        '$_basePath/arrow_right_square.svg',
        '$_basePath/category.svg',
        '$_basePath/chat.svg',
        '$_basePath/color_scheme_switch.svg',
        '$_basePath/heart.svg',
        '$_basePath/home.svg',
        '$_basePath/language_switch.svg',
        '$_basePath/notification.svg',
        '$_basePath/profile.svg',
        '$_basePath/send.svg',
        '$_basePath/setting.svg',
        '$_basePath/tick_square.svg',
        '$_basePath/time_circle.svg',
      ];
}

class _IconlyBulk {
  const _IconlyBulk();
  static const String _basePath = '${_Iconly._basePath}/bulk';

  final String arrowLeft = '$_basePath/arrow_left.svg';
  final String category = '$_basePath/category.svg';
  final String chat = '$_basePath/chat.svg';
  final String delete = '$_basePath/delete.svg';
  final String edit = '$_basePath/edit.svg';
  final String hide = '$_basePath/hide.svg';
  final String home = '$_basePath/home.svg';
  final String notification = '$_basePath/notification.svg';
  final String pauseCircle = '$_basePath/pause_circle.svg';
  final String playCircle = '$_basePath/play_circle.svg';
  final String plus = '$_basePath/plus.svg';
  final String search = '$_basePath/search.svg';
  final String send = '$_basePath/send.svg';
  final String setting = '$_basePath/setting.svg';
  final String show = '$_basePath/show.svg';
  final String swap = '$_basePath/swap.svg';
  final String tickSquare = '$_basePath/tick_square.svg';
  final String timeCircle = '$_basePath/time_circle.svg';

  static List<String> _getAllSvgs() => [
        '$_basePath/arrow_left.svg',
        '$_basePath/category.svg',
        '$_basePath/chat.svg',
        '$_basePath/delete.svg',
        '$_basePath/edit.svg',
        '$_basePath/hide.svg',
        '$_basePath/home.svg',
        '$_basePath/notification.svg',
        '$_basePath/pause_circle.svg',
        '$_basePath/play_circle.svg',
        '$_basePath/plus.svg',
        '$_basePath/search.svg',
        '$_basePath/send.svg',
        '$_basePath/setting.svg',
        '$_basePath/show.svg',
        '$_basePath/swap.svg',
        '$_basePath/tick_square.svg',
        '$_basePath/time_circle.svg',
      ];
}

class _IconlyStroke {
  const _IconlyStroke();
  static const String _basePath = '${_Iconly._basePath}/stroke';
  
  final String heart = '$_basePath/heart.svg';
  
  static List<String> _getAllSvgs() => ['$_basePath/heart.svg'];
}

class _Logo {
  const _Logo();
  static const String _basePath = 'assets/images/logo';

  final String physioAnimatedLogo = '$_basePath/physio_animated_logo.svg';
  final String physioAnimatedLogoTransparent = '$_basePath/physio_animated_logo_transparent.svg';
  final String physioLogoPng = '$_basePath/physio_logo.png';

  static List<String> _getAllSvgs() => [
        '$_basePath/physio_animated_logo.svg',
        '$_basePath/physio_animated_logo_transparent.svg',
      ];
}

class _PatternAndEffect {
  const _PatternAndEffect();
  static const String _basePath = 'assets/images/pattern_and_effect';

  final String blurEffectTopRight = '$_basePath/blur_effect_top_right.png';
  final String pattern = '$_basePath/pattern.svg';
  final String roundedPattern = '$_basePath/rounded_pattern.svg';

  static List<String> _getAllSvgs() => [
        '$_basePath/pattern.svg',
        '$_basePath/rounded_pattern.svg',
      ];
}
