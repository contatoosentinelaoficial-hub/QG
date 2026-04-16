import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb; // 🟢 SENSOR DE PLATAFORMA
import 'package:shared_preferences/shared_preferences.dart'; // 🛡️ COFRE DE MEMÓRIA

import 'vfc_scanner.dart';
import 'missoes_screen.dart'; 
import 'config.dart';        
import 'card_zero.dart';     

// GATILHO GLOBAL: Sincroniza a Matrix e o Scanner
final ValueNotifier<bool> isStandbyMode = ValueNotifier<bool>(true);

void main() async {
  // 🟢 GARANTE QUE O MOTOR FLUTTER LIGOU ANTES DA INJEÇÃO
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- ANTENA DO QG: RASTREIO DE CREDENCIAL BIFURCADA ---
  final prefs = await SharedPreferences.getInstance();
  
  if (kIsWeb) {
    String? p = Uri.base.queryParameters['p']?.toLowerCase();
    
    if (p == 'v') {
      await prefs.setBool('salvo_vip', true);
      await prefs.setString('tipo_plano', 'vitalicio');
    } else if (p == 'a') {
      await prefs.setBool('salvo_vip', true);
      await prefs.setString('tipo_plano', 'anual');
    }
  }
  // ------------------------------------------------

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const QGDigitalApp());
  });
}

class QGDigitalApp extends StatelessWidget {
  const QGDigitalApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, 
        scaffoldBackgroundColor: Colors.black, 
        fontFamily: 'ShareTechMono',
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Color(0xFF00FF00))),
      ),
      home: const CardZeroScreen(), 
    );
  }
}

class BaseTaticaScreen extends StatefulWidget {
  const BaseTaticaScreen({super.key});
  @override
  State<BaseTaticaScreen> createState() => _BaseTaticaScreenState();
}

class _BaseTaticaScreenState extends State<BaseTaticaScreen> with SingleTickerProviderStateMixin {
  int _indiceAtual = 0;
  late AnimationController _gearController;
  bool _usuarioIsVip = false; // 🛡️ DETECTOR REAL DE STATUS
  String _tipoPlano = ''; // 🟢 NOVA VARIÁVEL DE RASTREIO DA ETIQUETA

  @override
  void initState() {
    super.initState();
    _verificarCredencialVip();
    _gearController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  // Puxa da memória se o usuário tem o passaporte VIP e qual é o plano
  Future<void> _verificarCredencialVip() async {
    final prefs = await SharedPreferences.getInstance();
    bool isVip = prefs.getBool('salvo_vip') ?? false;
    String plano = prefs.getString('tipo_plano') ?? '';
    
    if (mounted) {
      setState(() {
        _usuarioIsVip = AppConfig.isVitalicio || isVip;
        _tipoPlano = plano;
      });
    }
  }

  @override
  void dispose() { 
    _gearController.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 INJEÇÃO DE RESPONSIVIDADE: Medindo a tela do soldado
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom; // Lê a margem de segurança do celular

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),

          // 🟢 CHUVA MATRIX
          Positioned.fill(
            child: ValueListenableBuilder<bool>(
              valueListenable: isStandbyMode,
              builder: (context, active, _) => AnimatedOpacity(
                duration: const Duration(milliseconds: 1000),
                opacity: active ? 0.50 : 0.0,
                child: const MatrixRainBackground(),
              ),
            ),
          ),

          // 🎯 ÁREA CENTRAL 
          Positioned.fill(
            child: Padding(
              // Empurra o conteúdo central para não bater nas engrenagens
              padding: const EdgeInsets.only(top: 60, bottom: 150), 
              child: _indiceAtual == 0 ? const VfcScannerScreen() : const MissoesScreen(),
            ),
          ),

          // ⚙️ ENGRENAGENS TÁTICAS (Agora responsivas e protegidas pela SafeArea)
          Positioned(
            bottom: bottomPadding + 15, // Adapta se o celular tem barra de navegação embaixo
            left: 0, 
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(3, (i) => Expanded(child: _buildGear(i, screenWidth))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGear(int i, double screenWidth) {
    List<String> imgs = ['gear_bronze.png', 'gear_prata.png', 'gear_ouro.png'];
    
    // 🟢 RÓTULO INTELIGENTE
    String labelGear = 'UPGRADE';
    if (_usuarioIsVip) {
      labelGear = (_tipoPlano == 'anual') ? 'ANUAL' : 'VITALÍCIO';
    }
    List<String> labels = ['SCANNER', 'MISSÕES', labelGear];
    
    // 🟢 CÁLCULO DINÂMICO
    double gearSize = screenWidth * 0.22; 
    if (gearSize > 90) gearSize = 90; 

    return GestureDetector(
      onTap: () async {
        if (i == 2) {
          // 🟢 A BIFURCAÇÃO TÁTICA E UPSELL
          if (!_usuarioIsVip || _tipoPlano == 'anual') {
            if (kIsWeb) {
              _abrirPainelElite(context); 
            } else {
              // Tiro direto do APK Nativo
              String linkAlvo = (_tipoPlano == 'anual') ? AppConfig.linkCheckoutVitalicio : AppConfig.linkCheckoutCombo;
              launchUrl(Uri.parse(linkAlvo), mode: LaunchMode.externalApplication);
            }
          }
        } else { 
          setState(() => _indiceAtual = i); 
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _gearController,
            builder: (_, child) => Transform.rotate(
              angle: (i == 1 ? -_gearController.value : _gearController.value) * 2 * pi,
              child: child,
            ),
            child: Opacity(
              opacity: (_indiceAtual == i || i == 2) ? 1.0 : 0.4, 
              child: Image.asset('assets/images/${imgs[i]}', width: gearSize)
            ),
          ),
          const SizedBox(height: 5),
          Text(
            labels[i], 
            style: TextStyle(
              color: i == 2 ? Colors.amber : ( _indiceAtual == i ? const Color(0xFF00FF00) : Colors.grey), 
              fontSize: 11, // Fonte levemente reduzida para telas finas
              fontWeight: FontWeight.bold, 
              letterSpacing: 1.0
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🛡️ O BOTTOMSHEET DE CONVERSÃO TÁTICA (Agora com Scroll Anti-Travamento)
  void _abrirPainelElite(BuildContext context) {
    
    // 🟢 DEFINE O TEXTO E O LINK BASEADO NA ETIQUETA DO SOLDADO
    String textoExplicativo = "Você está operando no Modo de Reconhecimento. O diagnóstico profundo, a Terapia de Choque e as rotas de fuga da sua procrastinação estão protegidos sob criptografia. Para romper essa barreira e forjar disciplina real, adquira o Arsenal Completo:";
    String textoBotao = "SAIA DA MATRIX. DESBLOQUEIO AGORA!";
    String linkEjetor = AppConfig.linkCheckoutCombo;

    if (_tipoPlano == 'anual') {
       textoExplicativo = "O seu acesso atual é de 12 meses. O verdadeiro controle exige compromisso perpétuo. Quebre as correntes do tempo e garanta seu passe Vitalício para o QG Digital.";
       textoBotao = "FORJAR ACESSO VITALÍCIO";
       linkEjetor = AppConfig.linkCheckoutVitalicio;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.95),
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Colors.amber, width: 0.5),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24, 30, 24, MediaQuery.of(context).padding.bottom + 20), 
        // 🟢 SINGLE CHILD SCROLL VIEW: Garante que nada fique inoperante se a tela for pequena
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "⚠️ ACESSO RESTRITO: PROTOCOLO ELITE",
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'ShareTechMono'),
              ),
              const SizedBox(height: 15),
              Text(
                textoExplicativo, // Texto Inteligente
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              _itemRecurso(Icons.radar, "APP SCANNER VFC (Elite)", "Desbloqueio das 28 Missões e Áudios Táticos."),
              _itemRecurso(Icons.psychology, "A MÁQUINA DA ILUSÃO", "Reprogramação mental e quebra de desculpas."),
              _itemRecurso(Icons.biotech, "MANUAL BIO-HACK", "Hackeie sua biologia e baixe o cortisol."),
              const Divider(color: Colors.white24, height: 30),
              const Text("⚙️ LOGÍSTICA DO SISTEMA:", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("🤖 Android: App nativo (APK) para biometria profunda.", style: TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 3),
              const Text("🍎 Apple (iOS): Acesso VIP a este Sistema Web (Sincronização PWA).", style: TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 30),
              
              // 🟢 O BOTÃO DE AÇO ESCOVADO MATRIX (Livre para clique)
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); 
                  launchUrl(Uri.parse(linkEjetor), mode: LaunchMode.externalApplication); // Link Inteligente
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[800]!, 
                        Colors.grey[500]!, 
                        Colors.grey[300]!, 
                        Colors.grey[500]!, 
                        Colors.grey[800]!, 
                      ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0], 
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1),
                    boxShadow: [
                      BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 10, spreadRadius: 1), 
                    ],
                  ),
                  child: Center(
                    child: Text(
                      textoBotao, // Botão Inteligente
                      style: const TextStyle(
                        color: Color(0xFF00FF00), 
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'ShareTechMono', 
                        letterSpacing: 1.0,
                        shadows: [Shadow(color: Colors.greenAccent, blurRadius: 6)], 
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemRecurso(IconData icon, String titulo, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🟢 COMPONENTE: O CÓDIGO CAINDO (SISTEMA BINÁRIO REAL E CINEMATOGRÁFICO)
class MatrixRainBackground extends StatefulWidget {
  const MatrixRainBackground({super.key});
  @override
  State<MatrixRainBackground> createState() => _MatrixRainBackgroundState();
}
class _MatrixRainBackgroundState extends State<MatrixRainBackground> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  
  @override
  void initState() { 
    super.initState(); 
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(); 
  }
  
  @override
  void dispose() { 
    _ctrl.dispose(); 
    super.dispose(); 
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => CustomPaint(painter: MatrixPainter(_ctrl.value)),
    );
  }
}

class MatrixPainter extends CustomPainter {
  final double progress;
  MatrixPainter(this.progress);
  
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); 

    for (int i = 0; i < 32; i++) {
      double x = random.nextDouble() * size.width;
      double speed = random.nextDouble() * 2.0 + 0.5; 
      
      double baseY = (size.height * ((progress * speed) % 1.0));
      int tailLength = random.nextInt(6) + 5; 

      for (int j = 0; j < tailLength; j++) {
        double currentY = baseY - (j * 18); 
        if (currentY < 0 || currentY > size.height) continue;

        int charSeed = (i * 100 + j + (progress * 40).toInt());
        String char = (charSeed % 2 == 0) ? "0" : "1";

        double opacity = (1.0 - (j / tailLength)).clamp(0.0, 1.0);
        
        Color color = j == 0 
            ? Colors.white.withOpacity(0.9) 
            : const Color(0xFF00FF00).withOpacity(opacity * 0.70);

        final textPainter = TextPainter(
          text: TextSpan(
            text: char,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontFamily: 'ShareTechMono',
              fontWeight: FontWeight.bold,
              shadows: j == 0 ? [const Shadow(color: Colors.greenAccent, blurRadius: 8)] : null,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, currentY));
      }
    }
  }
  
  @override 
  bool shouldRepaint(old) => true;
}
