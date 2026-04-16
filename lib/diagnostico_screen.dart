import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:shared_preferences/shared_preferences.dart'; // 🛡️ COFRE DE MEMÓRIA
import 'package:url_launcher/url_launcher.dart'; // 🔗 REDIRECIONAMENTO

import 'config.dart';

class DiagnosticoScreen extends StatefulWidget {
  final int vfcFinal; 
  const DiagnosticoScreen({super.key, required this.vfcFinal});
  
  @override
  State<DiagnosticoScreen> createState() => _DiagnosticoScreenState();
}

class _DiagnosticoScreenState extends State<DiagnosticoScreen> {
  late String _nivel;
  late Color _corNivel;
  late String _descricao;
  late String _arquivoTrilha;
  late String _arquivoVoz;
  
  String? _arquivoExtra1; 
  String? _nomeExtra1;
  String? _arquivoExtra2; 
  String? _nomeExtra2;

  bool _mostrarRitual = true; 
  final AudioPlayer _trilhaPlayer = AudioPlayer();
  final AudioPlayer _vozPlayer = AudioPlayer();
  bool _isVozPlaying = false;
  String _audioAtualAtivo = ""; 

  // 🛡️ MEMÓRIA VIP
  bool _usuarioIsVip = false;

  @override
  void initState() {
    super.initState();
    _verificarCredencialVip();
    _calcularDiagnostico();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() { _mostrarRitual = false; });
        _trilhaPlayer.setReleaseMode(ReleaseMode.loop);
        _trilhaPlayer.play(AssetSource('audio/$_arquivoTrilha'));
      }
    });
  }

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
    _trilhaPlayer.dispose();
    _vozPlayer.dispose();
    super.dispose();
  }

  void _calcularDiagnostico() {
    int vfc = widget.vfcFinal;
    if (vfc >= 50) {
      _nivel = "NÍVEL 1: VERDE // CONTROLE ABSOLUTO";
      _corNivel = const Color(0xFF00FF00); 
      _descricao = "Sistema nervoso parassimpático dominante. Você está no comando. \n\nDiretriz: Execute tarefas complexas. Domine o território.";
      _arquivoTrilha = "Beyond_the_Reach_of_Stars.mp3";
      _arquivoVoz = "Script1.mp3";
    } else if (vfc >= 35) {
      _nivel = "NÍVEL 2: AMARELO // ATENÇÃO TÁTICA";
      _corNivel = const Color(0xFFFFD700); 
      _descricao = "Atrito detectado. O sistema está em transição. \n\nDiretriz: Filtre as distrações. O inimigo está tentando roubar sua energia.";
      _arquivoTrilha = "Midnight_at_the_Vault.mp3";
      _arquivoVoz = "Script2-Robotic.mp3";
    } else if (vfc >= 15) {
      _nivel = "NÍVEL 3: LARANJA // MODO PRESA";
      _corNivel = const Color(0xFFFF5500); 
      _descricao = "Sobrecarga simpática. Você está reagindo como presa. \n\nAção Imediata: Protocolo Jason Bourne vs Casa. Execute a manobra de ancoragem agora.";
      _arquivoTrilha = "Safe_Distance.mp3";
      _arquivoVoz = "Script3.mp3";
      _arquivoExtra1 = "sleep_audio.mp3";
      _nomeExtra1 = "MODO CASA (DORMIR)";
      _arquivoExtra2 = "Ten_Metres_Down.mp3";
      _nomeExtra2 = "MODO RUA (BOURNE)";
    } else {
      _nivel = "NÍVEL 4: VERMELHO // ESGOTAMENTO TOTAL";
      _corNivel = const Color(0xFFFF0000); 
      _descricao = "Sistema frito. Nevoeiro mental absoluto. \n\nAção Imediata: Comando imperativo e militar. Volte a respirar imediatamente.";
      _arquivoTrilha = "Twelve_Seconds_Left.mp3";
      _arquivoVoz = "MarcusG1-script4.mp3";
    }
  }

  void _tocarVozPrincipal() async {
    await _trilhaPlayer.stop();
    if (_isVozPlaying && _audioAtualAtivo == _arquivoVoz) {
      await _vozPlayer.pause();
      setState(() => _isVozPlaying = false);
    } else {
      await _vozPlayer.play(AssetSource('audio/$_arquivoVoz'));
      setState(() { _isVozPlaying = true; _audioAtualAtivo = _arquivoVoz; });
    }
  }

  void _tocarExtra(String arquivo) async {
    await _trilhaPlayer.stop();
    if (_isVozPlaying && _audioAtualAtivo == arquivo) {
      await _vozPlayer.pause();
      setState(() => _isVozPlaying = false);
    } else {
      await _vozPlayer.play(AssetSource('audio/$arquivo'));
      setState(() { _isVozPlaying = true; _audioAtualAtivo = arquivo; });
    }
  }

  // 🕸️ A RATOEIRA DE VENDAS
  void _abrirPopupRatoeira(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Força a ovelha a clicar em um dos botões
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.amber, width: 2), borderRadius: BorderRadius.circular(15)),
        title: const Text("AMOSTRA DE RECONHECIMENTO", style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          "Você está operando na versão de reconhecimento.\n\nO resultado detalhado da sua biologia, as frequências de resgate neural e o protocolo de contenção estão criptografados.\n\nAcesse a Engrenagem Dourada para destrancar a sua base de dados.",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o Popup
              _trilhaPlayer.stop(); // Corta a tensão
              _vozPlayer.stop();
              Navigator.pop(context); // Ejeta a ovelha da tela de volta pra base
            }, 
            child: const Text("ABORTAR E RECUAR", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
               Navigator.pop(context); // Fecha o Popup
               _trilhaPlayer.stop(); // Corta a tensão
               _vozPlayer.stop();
               Navigator.pop(context); // Ejeta a ovelha pra base
               // 🟢 Tiro apontado para o Combo (Recrutas)
               launchUrl(Uri.parse(AppConfig.linkCheckoutCombo), mode: LaunchMode.externalApplication); 
            },
            child: const Text("ENGRENAGEM DOURADA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_mostrarRitual) {
      return Scaffold(
        backgroundColor: Colors.black, 
        body: Center(
          child: CustomPaint(
            painter: CarbonFiberPainter(), 
            child: const Center(
              child: Text(
                "PROCESSANDO...\nSILÊNCIO ABSOLUTO.", 
                textAlign: TextAlign.center, 
                style: TextStyle(color: Color(0xFF00FF00), fontSize: 16, letterSpacing: 3.0, fontFamily: 'ShareTechMono', shadows: [Shadow(color: Color(0xFF00FF00), blurRadius: 10)])
              )
            )
          )
        )
      );
    }

    // 🟢 LÓGICA DE DETECÇÃO DA ISCA
    final bool isIscaWeb = kIsWeb && !_usuarioIsVip;

    // 🛡️ A ARMADILHA DE SAÍDA (WillPopScope intercepta o botão nativo do Android)
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (isIscaWeb) {
          _abrirPopupRatoeira(context);
          return false; // Bloqueia a saída imediata
        }
        _trilhaPlayer.stop();
        _vozPlayer.stop();
        return true; // Deixa a ovelha VIP sair
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // FUNDO HARD LEVEL - Fibra de carbono
            Positioned.fill(
              child: CustomPaint(
                painter: CarbonFiberPainter(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.2),
                  radius: 1.2,
                  colors: [const Color(0xFF151515).withOpacity(0.9), Colors.black.withOpacity(0.95)],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. O COFRE DE DADOS (VISÍVEL PARA TODOS)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF222222), Color(0xFF111111)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: const Color(0xFF444444), width: 3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: _corNivel.withOpacity(0.15), blurRadius: 20, spreadRadius: 5),
                          const BoxShadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 5)),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Positioned(top: -5, left: -5, child: Icon(Icons.circle, size: 8, color: Colors.black)),
                          const Positioned(top: -5, right: -5, child: Icon(Icons.circle, size: 8, color: Colors.black)),
                          const Positioned(bottom: -5, left: -5, child: Icon(Icons.circle, size: 8, color: Colors.black)),
                          const Positioned(bottom: -5, right: -5, child: Icon(Icons.circle, size: 8, color: Colors.black)),
                          
                          Column(
                            children: [
                              Text(
                                "VFC REGISTRADO", 
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 13, letterSpacing: 3.0, fontWeight: FontWeight.bold)
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "${widget.vfcFinal} ms", 
                                style: TextStyle(
                                  color: _corNivel, 
                                  fontSize: 65, 
                                  fontWeight: FontWeight.w900, 
                                  shadows: [Shadow(color: _corNivel, blurRadius: 25)]
                                )
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // 2. NÍVEL DETECTADO (VISÍVEL PARA ASSUSTAR/VALIDAR)
                    Text(
                      _nivel, 
                      style: TextStyle(
                        color: _corNivel, 
                        fontSize: 17, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1.5,
                        shadows: [Shadow(color: _corNivel.withOpacity(0.5), blurRadius: 5)]
                      ), 
                      textAlign: TextAlign.center
                    ),
                    const SizedBox(height: 15),
                    
                    // 🛡️ 3. O CAMPO DE FORÇA TÁTICO (Envolve a Solução e o Áudio)
                    CadeadoTatico(
                      bloqueado: isIscaWeb,
                      onTapTrap: () => _abrirPopupRatoeira(context), // 🕸️ ACIONA A RATOEIRA PELO CLIQUE
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _descricao, 
                            style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14, height: 1.6, letterSpacing: 0.5), 
                            textAlign: TextAlign.center
                          ),
                          const SizedBox(height: 40),
                          
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text("// ARSENAL TÁTICO:", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 15),
                          
                          _construirBotaoPrincipal(),
                          const SizedBox(height: 15),
                          
                          if (_arquivoExtra1 != null && _arquivoExtra2 != null)
                            Row(
                              children: [
                                Expanded(child: _construirBotaoExtra(_arquivoExtra1!, _nomeExtra1!)),
                                const SizedBox(width: 15),
                                Expanded(child: _construirBotaoExtra(_arquivoExtra2!, _nomeExtra2!)),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // 4. BOTÃO VOLTAR (🕸️ A RATOEIRA DE FUGA)
                    GestureDetector(
                      onTap: () {
                        if (isIscaWeb) {
                          _abrirPopupRatoeira(context); // Bloqueia a fuga e sobe a oferta
                        } else {
                          _trilhaPlayer.stop();
                          _vozPlayer.stop();
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Color(0xFFE68A2E), Color(0xFFA65C17), Color(0xFF733E0B)], // Laranja/Âmbar
                          ),
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 5))],
                        ),
                        child: const Center(
                          child: Text(
                            "[ FECHAR RELATÓRIO ]", 
                            style: TextStyle(
                              color: Colors.black, 
                              fontSize: 15, 
                              letterSpacing: 2.0, 
                              fontWeight: FontWeight.w900,
                              shadows: [Shadow(color: Colors.white30, offset: Offset(-1,-1))]
                            )
                          )
                        )
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTÕES DO ARSENAL EM METAL ESCOVADO COM NEON
  Widget _construirBotaoPrincipal() {
    bool isThis = _isVozPlaying && _audioAtualAtivo == _arquivoVoz;
    return GestureDetector(
      onTap: _tocarVozPrincipal,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        decoration: BoxDecoration(
          color: isThis ? _corNivel.withOpacity(0.15) : const Color(0xFF151515), 
          border: Border.all(color: isThis ? _corNivel : const Color(0xFF444444), width: 2), 
          borderRadius: BorderRadius.circular(8),
          boxShadow: isThis ? [BoxShadow(color: _corNivel.withOpacity(0.3), blurRadius: 15)] : const [BoxShadow(color: Colors.black, blurRadius: 5)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(shape: BoxShape.circle, color: isThis ? _corNivel : Colors.transparent, border: Border.all(color: _corNivel)),
              child: Icon(isThis ? Icons.graphic_eq : Icons.play_arrow, color: isThis ? Colors.black : _corNivel, size: 20)
            ), 
            const SizedBox(width: 15), 
            Expanded(
              child: Text(
                isThis ? "[ TRANSMITINDO DIRETRIZ ]" : "REVELAR DEFESA", 
                style: TextStyle(color: isThis ? Colors.white : _corNivel, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.5)
              )
            )
          ]
        ),
      ),
    );
  }

  Widget _construirBotaoExtra(String arquivo, String nome) {
    bool isThis = _isVozPlaying && _audioAtualAtivo == arquivo;
    return GestureDetector(
      onTap: () => _tocarExtra(arquivo),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: isThis ? Colors.blue.withOpacity(0.15) : const Color(0xFF151515), 
          border: Border.all(color: isThis ? Colors.blue : const Color(0xFF444444), width: 2), 
          borderRadius: BorderRadius.circular(8),
          boxShadow: isThis ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15)] : const [BoxShadow(color: Colors.black, blurRadius: 5)],
        ),
        child: Column(
          children: [
            Icon(isThis ? Icons.graphic_eq : Icons.headphones, color: isThis ? Colors.blue : Colors.grey, size: 20), 
            const SizedBox(height: 8), 
            Text(
              nome,
              textAlign: TextAlign.center, 
              style: TextStyle(color: isThis ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0)
            )
          ]
        ),
      ),
    );
  }
}

// ==========================================
// PINTOR DA TEXTURA DE FIBRA DE CARBONO 
// ==========================================
class CarbonFiberPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = const Color(0xFF151515)..strokeWidth = 2;
    final paint2 = Paint()..color = const Color(0xFF0A0A0A)..strokeWidth = 2;
    
    for (double i = -size.height; i < size.width; i += 6) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint1);
      canvas.drawLine(Offset(i + 6, 0), Offset(i + size.height + 6, size.height), paint2);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// 🟢 O CAMPO DE FORÇA TÁTICO (Atualizado com Acionador de Ratoeira)
// ==========================================
class CadeadoTatico extends StatelessWidget {
  final Widget child;
  final bool bloqueado;
  final VoidCallback onTapTrap; // Recebe o comando da ratoeira

  const CadeadoTatico({super.key, required this.child, required this.bloqueado, required this.onTapTrap});

  @override
  Widget build(BuildContext context) {
    if (!bloqueado) return child;

    return GestureDetector(
      onTap: onTapTrap, // Dispara o PopUp na cara da Ovelha
      child: AbsorbPointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🌫️ A NÉVOA NÍVEL 12 E FILTRO DE SATURAÇÃO
            ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                  child: Opacity(
                    opacity: 0.5,
                    child: child,
                  ),
                ),
              ),
            ),
            // 🔒 O ÍCONE DE CADEADO BRILHANTE
            const Icon(
              Icons.lock_person_rounded, 
              color: Colors.amber, 
              size: 55, 
              shadows: [Shadow(color: Colors.black, blurRadius: 15, offset: Offset(0, 2))],
            ),
          ],
        ),
      ),
    );
  }
}
