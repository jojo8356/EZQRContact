import 'package:qr_code_app/providers/darkmode.dart';
import 'package:qr_code_app/colors.dart';

// ⚙️ Singleton pour éviter plusieurs instances
final DarkModeProvider darkProv = DarkModeProvider();

// 🌓 Méthode pour récupérer le thème et les couleurs à jour
ThemeModeType get currentTheme =>
    darkProv.isDarkMode ? ThemeModeType.blackMode : ThemeModeType.whiteMode;

get currentColors => appColorsEnum[currentTheme]!;
