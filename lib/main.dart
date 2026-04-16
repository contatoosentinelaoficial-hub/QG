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
  
  // --- ANTENA DO QG: RASTREIO DE CREDENCIAL VIP ---
  final prefs = await SharedPreferences.getInstance();
  
  // Se estiver na Web (PWA) e a URL tiver "?p=v", salva o acesso VIP
  if (kIsWeb) {
    if (Uri.base.queryParameters['p'] == 'v') {
      await prefs.setBool('salvo_vip', true);
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
  bool _usuarioIsVip = false; // 🛡️ DETECTOR REAL DE STATUS (Lê Web e APK)

  @override
  void initState() {
    super.initState();
    _verificarCredencialVip();
    _gearController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
  }

  // Puxa da memória se o usuário tem o passaporte VIP
  Future<void> _verificarCredencialVip() async {
    final prefs = await SharedPreferences.getInstance();
    bool isVip = prefs.getBool('salvo_vip') ?? false;
    if (mounted) {
      setState(() {
        _usuarioIsVip = AppConfig.isVitalicio || isVip;
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
              padding: const EdgeInsets.only(top: 110, bottom: 200), 
              child: _indiceAtual == 0 ? const VfcScannerScreen() : const MissoesScreen(),
            ),
          ),

          // ⚙️ ENGRENAGENS TÁTICAS
          Positioned(
            bottom: 75, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(3, (i) => _buildGear(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGear(int i) {
    List<String> imgs = ['gear_bronze.png', 'gear_prata.png', 'gear_ouro.png'];
    // 🛡️ Agora a engrenagem lê a variável que cruza os dados da Web e do APK
    List<String> labels = ['SCANNER', 'MISSÕES', _usuarioIsVip ? 'VITALÍCIO' : 'UPGRADE'];
    
    return GestureDetector(
      onTap: () async {
        if (i == 2) {
          // 🟢 A BIFURCAÇÃO TÁTICA (Só bloqueia se não for VIP real)
          if (!_usuarioIsVip) {
            if (kIsWeb) {
              _abrirPainelElite(context); // Se for Isca Web, sobe o Funil
            } else {
              // Se for Isca APK, atira direto pro link
              launchUrl(Uri.parse(AppConfig.linkCheckout), mode: LaunchMode.externalApplication);
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
            child: Opacity(opacity: (_indiceAtual == i || i == 2) ? 1.0 : 0.4, child: Image.asset('assets/images/${imgs[i]}', width: 115)),
          ),
          const SizedBox(height: 5),
          Text(labels[i], style: TextStyle(color: i == 2 ? Colors.amber : ( _indiceAtual == i ? const Color(0xFF00FF00) : Colors.grey), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  // 🛡️ O BOTTOMSHEET DE CONVERSÃO TÁTICA
  void _abrirPainelElite(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.95),
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: Colors.amber, width: 0.5),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 40), 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⚠️ ACESSO RESTRITO: PROTOCOLO ELITE",
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'ShareTechMono'),
            ),
            const SizedBox(height: 15),
            const Text(
              "Você está operando no Modo de Reconhecimento. O diagnóstico profundo, a Terapia de Choque e as rotas de fuga da sua procrastinação estão protegidos sob criptografia. Para romper essa barreira e forjar disciplina real, adquira o Arsenal Completo:",
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
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
            
            // 🟢 O BOTÃO DE AÇO ESCOVADO MATRIX
            GestureDetector(
              onTap: () {
                Navigator.pop(context); 
                launchUrl(Uri.parse(AppConfig.linkCheckout), mode: LaunchMode.externalApplication);
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
                  border: BorderSide(color: Colors.greenAccent.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 10, spreadRadius: 1), 
                  ],
                ),
                child: const Center(
                  child: Text(
                    "SAIA DA MATRIX. DESBLOQUEIO AGORA!",
                    style: TextStyle(
                      color: Color(0xFF00FF00), 
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'ShareTechMono', 
                      letterSpacing: 1.0,
                      shadows: [Shadow(color: Colors.greenAccent, blurRadius: 6)], 
                    ),
                  ),
                ),
              ),
            ),
          ],
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
