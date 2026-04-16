import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'main.dart'; 

class CardZeroScreen extends StatefulWidget {
  const CardZeroScreen({super.key});

  @override
  State<CardZeroScreen> createState() => _CardZeroScreenState();
}

class _CardZeroScreenState extends State<CardZeroScreen> with SingleTickerProviderStateMixin {
  // MOTORES DE ÁUDIO
  final AudioPlayer _bootPlayer = AudioPlayer();
  final AudioPlayer _dossiePlayer = AudioPlayer(); 

  // CONTROLADORES DE ESTADO E ANIMAÇÃO
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  
  bool _mostrandoVerso = false;
  bool _botaoLiberado = false;
  int _contador = 10;
  bool _audioTocou = false;

  @override
  void initState() {
    super.initState();
    _iniciarBoot();

    // Configurando a Animação do Flip
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );

    _iniciarContagemFrente();
  }

  void _iniciarBoot() async {
    // Mantém o Identity_Confirmed tocando na entrada
    await _bootPlayer.play(AssetSource('audio/Identity_Confirmed.mp3'));
  }

  void _iniciarContagemFrente() async {
    for (int i = 10; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && !_mostrandoVerso) {
        setState(() {
          _contador = i - 1;
        });
      }
    }
  }

  void _girarCard() {
    if (_mostrandoVerso) return;
    
    // 🔴 CORTE CIRÚRGICO: Para o áudio da frente instantaneamente
    _bootPlayer.stop(); 
    
    // Dispara a animação 3D
    _flipController.forward();
    
    setState(() {
      _mostrandoVerso = true;
      _botaoLiberado = false; 
    });

    _dispararAudioDossie();
    _iniciarContagemVerso();
  }

  void _dispararAudioDossie() async {
    if (!_audioTocou) {
      // Dispara a narração pesada no momento do flip
      await _dossiePlayer.play(AssetSource('audio/audio_dossie.mp3'));
      _audioTocou = true;
    }
  }

  void _iniciarContagemVerso() async {
    int tempoLeitura = 15; 
    for (int i = tempoLeitura; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {});
      }
    }
    if (mounted) {
      setState(() {
        _botaoLiberado = true;
      });
    }
  }

  @override
  void dispose() {
    _bootPlayer.dispose();
    _dossiePlayer.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "FILTRO TÁTICO // DIRETRIZ ZERO",
                style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // O CARD 3D MODO HARD
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      bool isUnder = _flipAnimation.value > pi / 2;
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) 
                          ..rotateY(_flipAnimation.value),
                        alignment: Alignment.center,
                        child: isUnder 
                            ? Transform( 
                                transform: Matrix4.identity()..rotateY(pi),
                                alignment: Alignment.center,
                                child: _construirBaseMetalica(_construirVersoDossie())
                              )
                            : _construirBaseMetalica(_construirFrenteManifesto()),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              const Text(
                "AVISO LEGAL: O Sistema de Leitura PPG opera com tecnologia óptica biométrica analítica. Estes dados possuem caráter tático e informacional. Não substitui laudo médico.",
                style: TextStyle(color: Colors.white30, fontSize: 9, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CHASSI DE METAL PARA O CARD (Para os dois lados)
  // ==========================================
  Widget _construirBaseMetalica(Widget conteudo) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A), // Fundo base escuro
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF444444), width: 3), // Borda de aço
        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Stack(
        children: [
          // O Conteúdo (Frente ou Verso)
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: conteudo,
          ),

          // PARAFUSOS TÁTICOS (Mecânica de precisão)
          const Positioned(top: 6, left: 6, child: Icon(Icons.circle, size: 8, color: Colors.black)),
          Positioned(top: 7, left: 7, child: Icon(Icons.circle, size: 6, color: Colors.grey.shade600)),
          
          const Positioned(top: 6, right: 6, child: Icon(Icons.circle, size: 8, color: Colors.black)),
          Positioned(top: 7, right: 7, child: Icon(Icons.circle, size: 6, color: Colors.grey.shade600)),
          
          const Positioned(bottom: 6, left: 6, child: Icon(Icons.circle, size: 8, color: Colors.black)),
          Positioned(bottom: 7, left: 7, child: Icon(Icons.circle, size: 6, color: Colors.grey.shade600)),
          
          const Positioned(bottom: 6, right: 6, child: Icon(Icons.circle, size: 8, color: Colors.black)),
          Positioned(bottom: 7, right: 7, child: Icon(Icons.circle, size: 6, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  // ==========================================
  // FACE A (O MANIFESTO VERDE BRILHANTE)
  // ==========================================
  Widget _construirFrenteManifesto() {
    bool podeGirar = _contador == 0;

    return Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "A DOENÇA DO IMEDIATISMO.\n\n"
            "A maioria das pessoas sofre de uma preguiça patológica de pensar e agir. Elas buscam o botão mágico. O atalho. A pílula.\n\n"
            "Este sistema não é para os fracos. A varredura biométrica exige paciência. As missões exigem sacrifício. O silêncio exige confronto.\n\n"
            "Leia este manifesto. O sistema só abrirá quando você provar que consegue esperar a fricção.",
            style: TextStyle(
              color: Color(0xFF00FF00), 
              fontSize: 15, 
              height: 1.6, 
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Color(0x8800FF00), blurRadius: 4)],
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 40),
          _construirBotaoLaranja(
            podeGirar ? "INICIAR DOSSIÊ" : "BLOQUEADO... [ $_contador s ]", 
            podeGirar, 
            podeGirar ? _girarCard : null
          ),
        ],
      ),
    );
  }

  // ==========================================
  // FACE B (O ENCAPUZADO E O DOSSIÊ DESCIDO)
  // ==========================================
  Widget _construirVersoDossie() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/encapuzado_verso.jpg'), // IMAGEM DE FUNDO
          fit: BoxFit.cover,
          alignment: Alignment.topCenter, // Foca no rosto/olhos no topo
        ),
      ),
      child: Stack(
        children: [
          // OVERLAY INTELIGENTE: Transparente em cima (mostra a arte), escuro embaixo (lê o texto)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1), // Topo limpo para ver os olhos azuis
                  Colors.black.withOpacity(0.85), // Meio escurecendo
                  Colors.black.withOpacity(0.95), // Base preta para leitura
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          
          // CONTEÚDO DESCIDO
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 70), // EMPURRA O TEXTO PARA BAIXO, LIVRANDO O ROSTO
                
                const Center(
                  child: Text(
                    "⚙️ MANUAL DE OPERAÇÃO",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                  ),
                ),
                const Divider(color: Color(0xFF555555), height: 25, thickness: 1),

                const Text("[ TECNOLOGIA BIOMÉTRICA PPG ]", style: TextStyle(color: Color(0xFF0088FF), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
                const SizedBox(height: 3),
                const Text(
                  "Este sistema opera com Fotopletismografia (PPG). O Flash atua como emissor, a lente captura microflutuações do fluxo.",
                  style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 11, height: 1.3),
                ),
                const SizedBox(height: 12),

                const Text("[ DIAGNÓSTICO DE CORTISOL ]", style: TextStyle(color: Color(0xFF0088FF), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
                const SizedBox(height: 3),
                const Text(
                  "Rastreamos os milissegundos entre as batidas. VFC engessada prova cérebro sob ataque crônico de estresse.",
                  style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 11, height: 1.3),
                ),
                const SizedBox(height: 12),

                const Text("[ PROTOCOLO DE LEITURA ]", style: TextStyle(color: Color(0xFF0088FF), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.0)),
                const SizedBox(height: 5),
                _itemAlerta("ALVO", "Cubra a lente e o flash simultaneamente."),
                _itemAlerta("PRESSÃO", "Toque leve. Esmagar invalida o teste."),
                _itemAlerta("ESTÁTICA", "Silêncio absoluto e sem movimentos."),

                const SizedBox(height: 12),

                const Text(
                  "[ ENGENHARIA ACÚSTICA ]", 
                  style: TextStyle(
                    color: Color(0xFF0088FF),
                    fontWeight: FontWeight.bold, 
                    fontSize: 12, 
                    letterSpacing: 1.0
                  )
                ),
                const SizedBox(height: 5),
                const Text(
                  "Todas as trilhas deste sistema são forjadas com Tecnologia Neuro-Hack Binaural. O uso de fones de ouvido é diretriz tática obrigatória para controle de cortisol.",
                  style: TextStyle(
                    color: Color(0xFFCCCCCC), 
                    fontSize: 11, 
                    height: 1.3
                  )
                ),

                const Spacer(),

                // BOTÃO FINAL LARANJA TÁTICO
                _construirBotaoLaranja(
                  _botaoLiberado ? "EU ACEITO O ATRITO" : "LENDO DIRETRIZES...", 
                  _botaoLiberado, 
                  _botaoLiberado ? () {
                    _dossiePlayer.stop(); // Corta a narração ao entrar no app
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const BaseTaticaScreen()),
                    );
                  } : null
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTÃO PREMIUM: LARANJA TÁTICO / ÂMBAR
  // ==========================================
  Widget _construirBotaoLaranja(String texto, bool ativo, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: ativo 
                ? [const Color(0xFFE68A2E), const Color(0xFFA65C17), const Color(0xFF733E0B)] 
                : [const Color(0xFF444444), const Color(0xFF222222), const Color(0xFF111111)],
          ),
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(6),
          boxShadow: ativo 
              ? [const BoxShadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 6))] 
              : [],
        ),
        child: Center(
          child: Text(
            texto,
            style: TextStyle(
              color: ativo ? Colors.black : Colors.grey,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: 2.0,
              shadows: ativo ? [Shadow(color: Colors.white.withOpacity(0.3), offset: const Offset(-1, -1))] : [],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemAlerta(String titulo, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontFamily: 'ShareTechMono', fontSize: 11, height: 1.3),
          children: [
            TextSpan(text: "• $titulo: ", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            TextSpan(text: texto, style: const TextStyle(color: Color(0xFFCCCCCC))),
          ],
        ),
      ),
    );
  }
}
