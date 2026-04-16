import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 🟢 SENSOR DE PLATAFORMA

// --- NOVAS IMPORTAÇÕES DE BLINDAGEM ---
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart'; 

import 'main.dart'; // Acesso ao isStandbyMode
import 'diagnostico_screen.dart'; 

class VfcScannerScreen extends StatefulWidget {
  const VfcScannerScreen({super.key});
  @override
  State<VfcScannerScreen> createState() => _VfcScannerScreenState();
}

class _VfcScannerScreenState extends State<VfcScannerScreen> {
  CameraController? _cameraController;
  bool _isScanning = false;
  double _scanProgress = 0.0;
  int _vfcValue = 0;
  int _bpmValue = 0;
  
  double _compassHeading = 0.0;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  // 🟢 Controlador para a digitação manual no PWA
  final TextEditingController _webVfcController = TextEditingController();

  // 🛡️ VARIÁVEIS DO CARRASCO
  bool _isLoadingBloqueio = true;
  bool _isBloqueadoAnual = false;

  @override
  void initState() {
    super.initState();
    _verificarBloqueioTempo(); // Inicia a checagem de segurança antes de ligar os motores
    _initBussola();
    _initCamera();
  }

  // ==========================================================
  // 🛑 MOTOR DE TEMPO E BLOQUEIO VIP
  // ==========================================================
  Future<void> _verificarBloqueioTempo() async {
    final prefs = await SharedPreferences.getInstance();
    
    String? dataInicioStr = prefs.getString('data_inicio_protocolo');
    DateTime dataInicio;

    if (dataInicioStr == null) {
      dataInicio = DateTime.now();
      await prefs.setString('data_inicio_protocolo', dataInicio.toIso8601String());
    } else {
      dataInicio = DateTime.parse(dataInicioStr);
    }

    final diferenca = DateTime.now().difference(dataInicio).inDays;
    bool isVip = prefs.getBool('salvo_vip') ?? false;
    bool usuarioIsVip = AppConfig.isVitalicio || isVip;

    if (mounted) {
      setState(() {
        // Se passou de 365 dias E a ovelha NÃO tem a credencial VIP, ativa o bloqueio total
        _isBloqueadoAnual = diferenca > 365 && !usuarioIsVip;
        _isLoadingBloqueio = false;
      });
    }
  }

  void _initBussola() {
    _magnetometerSubscription = magnetometerEventStream().listen((event) {
      double heading = atan2(event.y, event.x);
      if (mounted) {
        setState(() {
          _compassHeading = heading;
        });
      }
    });
  }

  Future<void> _initCamera() async {
    // 🛑 SE FOR WEB (PWA), BLOQUEIA A TENTATIVA DE ABRIR CÂMERA
    if (kIsWeb) return; 

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _cameraController = CameraController(cameras.first, ResolutionPreset.low, enableAudio: false);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Erro na câmera: $e");
    }
  }

  // ==========================================================
  // ⚡ LÓGICA DE SCAN NATIVO (CÂMERA)
  // ==========================================================
  void _iniciarScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    isStandbyMode.value = false; 
    setState(() { _isScanning = true; _scanProgress = 0.0; _vfcValue = 0; _bpmValue = 0; });
    
    try { await _cameraController!.setFlashMode(FlashMode.torch); } catch (e) {}

    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _scanProgress += 0.01;
        _vfcValue = 20 + Random().nextInt(40); 
        _bpmValue = 60 + Random().nextInt(40);
      });
      if (_scanProgress >= 1.0) { timer.cancel(); _finalizarScan(); }
    });
  }

  void _finalizarScan() async {
    try { await _cameraController!.setFlashMode(FlashMode.off); } catch (e) {}
    
    isStandbyMode.value = true; 
    setState(() { 
      _isScanning = false; 
      _scanProgress = 1.0; 
      _vfcValue = 15 + Random().nextInt(50); 
      _bpmValue = 65 + Random().nextInt(20); 
    });
    
    if (mounted) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DiagnosticoScreen(vfcFinal: _vfcValue)));
      });
    }
  }

  // ==========================================================
  // 🌐 LÓGICA DE SCAN WEB (MANUAL OVERRIDE PARA APPLE/PWA)
  // ==========================================================
  void _iniciarScanWeb() {
    int parsedVfc = int.tryParse(_webVfcController.text) ?? 0;
    if (parsedVfc <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Insira um valor de VFC válido para sincronizar.", style: TextStyle(fontFamily: 'ShareTechMono', color: Colors.amber)),
        backgroundColor: Colors.black87,
      ));
      return;
    }
    
    FocusScope.of(context).unfocus(); // Recolhe o teclado do iPhone
    isStandbyMode.value = false; 
    
    setState(() { 
      _isScanning = true; 
      _scanProgress = 0.0; 
      _vfcValue = parsedVfc; 
      _bpmValue = 60 + Random().nextInt(20); 
    });

    // Simula o tempo de processamento de dados para gerar atrito e autoridade
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() { _scanProgress += 0.02; });
      if (_scanProgress >= 1.0) { 
        timer.cancel(); 
        
        isStandbyMode.value = true; 
        setState(() { _isScanning = false; });
        
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DiagnosticoScreen(vfcFinal: parsedVfc)));
        });
      }
    });
  }

  @override
  void dispose() {
    _magnetometerSubscription?.cancel();
    _cameraController?.setFlashMode(FlashMode.off);
    _cameraController?.dispose();
    _webVfcController.dispose();
    super.dispose();
  }

  // ==========================================================
  // 💀 A TELA DA MORTE (BLOQUEIO 365 DIAS)
  // ==========================================================
  Widget _construirTelaDaMorte() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 80),
              const SizedBox(height: 20),
              const Text("SCANNER BLOQUEADO", style: TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 15),
              const Text(
                "O seu protocolo de 12 meses expirou. O motor biométrico e o fluxo PPG foram desativados por segurança.\n\nRenove o acesso para retomar o controle.",
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                onPressed: () => launchUrl(Uri.parse(AppConfig.linkCheckout), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.settings, color: Colors.black),
                label: const Text("ENGRENAGEM DOURADA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingBloqueio) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    // 🛑 SE A GUILHOTINA DESCEU, ABORTA A RENDERIZAÇÃO DA CÂMERA
    if (_isBloqueadoAnual) {
      return _construirTelaDaMorte();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),

        // 🧭 1. A BÚSSOLA TÁTICA
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/images/aro_bussola.png', width: 210), 
            Transform.rotate(
              angle: _compassHeading,
              child: Image.asset('assets/images/bussola_disco1.png', width: 135), 
            ),
          ],
        ),
        
        const SizedBox(height: 25), 
        
        // Texto de instrução que se adapta à plataforma
        Text(
          _isScanning 
              ? (kIsWeb ? "PROCESSANDO DADOS BIOMÉTRICOS..." : "LENDO FLUXO PPG... MANTENHA O DEDO NO FLASH")
              : (kIsWeb ? "INSIRA O SEU VFC ATUAL PARA SINCRONIZAR" : "POSICIONE O DEDO SOBRE A CÂMERA E O FLASH"),
          style: TextStyle(color: kIsWeb ? Colors.amber : const Color(0xFF00FF00), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 15),

        // 📺 2. O VISOR CENTRAL (BIFURCADO AUTOMATICAMENTE)
        kIsWeb ? _buildWebVisor() : _buildNativeVisor(),

        const SizedBox(height: 20),

        // ⚡ 3. O RASTRO DO LASER (HACK ECG)
        SizedBox(
          height: 70, 
          width: 320, 
          child: _isScanning ? const LaserPulseMotor() : null,
        ),

        const Spacer(),

        // 🔘 4. O EJETOR MATRIX (BLINDADO PARA WEB PWA)
        GestureDetector(
          behavior: HitTestBehavior.opaque, // 🛡️ CAMPO DE FORÇA: Impede que cliques vazem
          onTap: () async { 
            // ROTA DE FUGA PWA: Ejetar da aba jogando para o Google
            await launchUrl(Uri.parse('https://www.google.com'), mode: LaunchMode.externalApplication);
          },
          child: Container(
            // Almofada invisível para garantir o clique mesmo que o dedo seja largo
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), 
            child: Image.asset('assets/images/matrix.png', width: 140, fit: BoxFit.contain),
          ),
        ),

        const Spacer(),

        // ⚖️ 5. O DISCLAIMER JURÍDICO 
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "O SCANNER VFC NÃO SUBSTITUI DIAGNÓSTICO MÉDICO PROFISSIONAL.",
            style: TextStyle(color: Colors.white30, fontSize: 8, letterSpacing: 1.0),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // 💻 CONSTRUTOR DE VISOR NATIVO (ANDROID APK)
  // ==========================================================
  Widget _buildNativeVisor() {
    return GestureDetector(
      onTap: _isScanning ? null : _iniciarScan,
      child: Container(
        width: 360, 
        height: 200, 
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/moldura_visor_VFC.png'), fit: BoxFit.fill),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _scanProgress == 0.0 ? "--" : "$_vfcValue",
                  style: const TextStyle(fontSize: 75, fontWeight: FontWeight.bold, color: Color(0xFF00FF00), shadows: [Shadow(color: Color(0xFF00FF00), blurRadius: 10)]),
                ),
                const SizedBox(width: 5),
                const Text("ms", style: TextStyle(color: Color(0xFF00FF00), fontSize: 26)),
                const SizedBox(width: 30), 
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("BPM:", style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.0)),
                    Text(_scanProgress == 0.0 ? "--" : "$_bpmValue", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ],
            ),
            if (_isScanning || _scanProgress == 1.0)
              Positioned(bottom: 30, left: 40, right: 40, child: LinearProgressIndicator(value: _scanProgress, backgroundColor: Colors.black54, color: const Color(0xFF00FF00), minHeight: 4)),
            if (!_isScanning && _scanProgress == 0.0)
              const Positioned(bottom: 30, child: Text("[ TOQUE PARA INICIAR ]", style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 2.0))),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // 🌐 CONSTRUTOR DE VISOR WEB (MANUAL OVERRIDE PWA)
  // ==========================================================
  Widget _buildWebVisor() {
    return Container(
      width: 360, 
      height: 200, 
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/moldura_visor_VFC.png'), fit: BoxFit.fill),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!_isScanning && _scanProgress == 0.0) ...[
            // MODO DE ENTRADA DE DADOS
            const Positioned(
              top: 35,
              child: Text("TELEMETRIA EXTERNA", style: TextStyle(color: Colors.amber, fontSize: 11, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
            ),
            const Positioned(
              top: 52,
              child: Text("(Apple Health / Garmin / Smartwatch)", style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1.0)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _webVfcController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 3,
                    style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.amber, shadows: [Shadow(color: Colors.amberAccent, blurRadius: 10)]),
                    decoration: const InputDecoration(
                      counterText: "",
                      hintText: "00",
                      hintStyle: TextStyle(color: Colors.white12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                const Text("ms", style: TextStyle(color: Colors.amber, fontSize: 26)),
              ],
            ),
            Positioned(
              bottom: 25,
              child: GestureDetector(
                onTap: _iniciarScanWeb,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(border: Border.all(color: Colors.amber), color: Colors.amber.withOpacity(0.1)),
                  child: const Text("[ PROCESSAR DADOS ]", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
              ),
            ),
          ] else ...[
            // MODO DE PROCESSAMENTO (Animação igual ao nativo)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "$_vfcValue",
                  style: const TextStyle(fontSize: 75, fontWeight: FontWeight.bold, color: Colors.amber, shadows: [Shadow(color: Colors.amberAccent, blurRadius: 10)]),
                ),
                const SizedBox(width: 5),
                const Text("ms", style: TextStyle(color: Colors.amber, fontSize: 26)),
                const SizedBox(width: 30), 
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("BPM:", style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.0)),
                    Text("$_bpmValue", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 30, left: 40, right: 40, 
              child: LinearProgressIndicator(value: _scanProgress, backgroundColor: Colors.black54, color: Colors.amber, minHeight: 4)
            ),
          ]
        ],
      ),
    );
  }
}

// ============================================================================
// 🟢 O MOTOR LASER (INTACTO)
// ============================================================================
class LaserPulseMotor extends StatefulWidget {
  const LaserPulseMotor({super.key});
  @override
  State<LaserPulseMotor> createState() => _LaserPulseMotorState();
}

class _LaserPulseMotorState extends State<LaserPulseMotor> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  
  @override
  void initState() { 
    super.initState(); 
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(); 
  }
  
  @override
  void dispose() { 
    _c.dispose(); 
    super.dispose(); 
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c, 
      builder: (context, _) => CustomPaint(painter: LaserPainter(_c.value))
    );
  }
}

class LaserPainter extends CustomPainter {
  final double p;
  LaserPainter(this.p);
  
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()..color = Colors.cyanAccent..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final core = Paint()..color = Colors.white;
    final tail = Paint()..strokeWidth = 2.5..style = PaintingStyle.stroke;

    double x = size.width * p;
    double y = (size.height / 2) + sin(p * 18) * 20;

    Path tPath = Path();
    for (double i = 0; i < 0.15; i += 0.01) {
      double t = p - i; 
      if (t < 0) t += 1.0;
      
      double tx = size.width * t;
      double ty = (size.height / 2) + sin(t * 18) * 20;
      
      if (i == 0) tPath.moveTo(tx, ty); 
      else tPath.lineTo(tx, ty);
      
      tail.color = Colors.cyanAccent.withOpacity((1.0 - (i * 7)).clamp(0, 1));
      canvas.drawPath(tPath, tail);
    }
    
    canvas.drawCircle(Offset(x, y), 6, glow);
    canvas.drawCircle(Offset(x, y), 2, core);
  }
  
  @override 
  bool shouldRepaint(old) => true;
}          
