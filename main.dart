import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // Gerenciamento de URLs limpas
import 'providers/auth_provider.dart';
import 'providers/usuario_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Garante a inicialização dos bindings do Flutter antes de operações assíncronas
  WidgetsFlutterBinding.ensureInitialized();

  // Remove o '#' da URL no navegador para um comportamento de sistema Web real
  usePathUrlStrategy();

  // Inicializa o provider de autenticação e tenta recuperar sessão existente[cite: 1]
  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();

  runApp(
    MultiProvider(
      providers: [
        // Usamos .value para o authProvider que já foi instanciado e inicializado acima
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
      ],
      child: const BoasPraticasApp(),
    ),
  );
}

class BoasPraticasApp extends StatelessWidget {
  const BoasPraticasApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color corPrimaria = Color(0xFFC51D34);
    const Color corTextoEscuro = Color(0xFF2E2E30);

    // Escuta as mudanças no AuthProvider para redirecionamento automático
    final auth = Provider.of<AuthProvider>(context);

    return MaterialApp(
      title: 'Boas Práticas Corp - Grupo Dass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: corPrimaria,
        colorScheme: ColorScheme.fromSeed(
          seedColor: corPrimaria,
          primary: corPrimaria,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: corPrimaria,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: corTextoEscuro),
          bodyMedium: TextStyle(color: corTextoEscuro),
        ),
      ),
      // Lógica de Rota Inicial: Se estiver autenticado, abre a Home. Caso contrário, Login.
      home: auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        // Proteção simples de rota: impede acesso à Home via URL se não estiver logado
        '/home': (context) =>
            auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
      },
    );
  }
}
