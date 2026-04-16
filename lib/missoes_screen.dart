import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:audioplayers/audioplayers.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import 'config.dart'; 

class MissoesScreen extends StatefulWidget {
  const MissoesScreen({super.key});

  @override
  State<MissoesScreen> createState() => _MissoesScreenState();
}

class _MissoesScreenState extends State<MissoesScreen> {
  int _diasAtivos = 0;
  bool _isLoading = true;
  bool _usuarioIsVip = false; 

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _iniciarMotorDoTempoEBlindagem();
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); 
    super.dispose();
  }

  Future<void> _iniciarMotorDoTempoEBlindagem() async {
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

    setState(() {
      _diasAtivos = diferenca; 
      _usuarioIsVip = AppConfig.isVitalicio || isVip; 
      _isLoading = false; 
    });
  }

  void _tocarAudioTatico(int diaDaMissao) async {
    await _audioPlayer.stop(); 
    _audioPlayer.setReleaseMode(ReleaseMode.loop); 

    String audioPath = '';
    
    if (diaDaMissao == 0) { 
      audioPath = 'audio/(D0)Blackout_Protocol.mp3'; // Lembre-se de colocar esse audio na pasta se for usar!
    } else if (diaDaMissao >= 1 && diaDaMissao <= 7) {
      audioPath = 'audio/(semana1)Midnight_Perimeter.mp3';
    } else if (diaDaMissao >= 8 && diaDaMissao <= 14) {
      audioPath = 'audio/(semana2)The_Ledger_Of_Secrets.mp3';
    } else if (diaDaMissao >= 15 && diaDaMissao <= 21) {
      audioPath = 'audio/(semana3)Before_the_Perimeter.mp3';
    } else {
      audioPath = 'audio/(semana4)The_Iron_Threshold.mp3';
    }

    await _audioPlayer.play(AssetSource(audioPath));
  }

  // --- O ARSENAL COMPLETO DE 28 DIAS ---
  final List<Map<String, String>> _missoes = [
    {
      'titulo': 'O FANTASMA SOCIAL',
      'conteudo': 'A Ilusão: "Preciso de estímulo constante para não me sentir sozinho."\n\nA Verdade: Você perdeu a capacidade de existir no silêncio. O seu celular é uma muleta emocional.\n\nDiretriz Tática: Vá a um local público (café, praça, fila). Sente-se. Não leve fones de ouvido. Não puxe o celular. Apenas observe, de cabeça erguida, a multidão de zumbis com os pescoços curvados para baixo. Sinta a superioridade biológica de estar presente no momento.'
    },
    {
      'titulo': 'O ATAQUE ANALÓGICO',
      'conteudo': 'A Ilusão: "Mandar uma mensagem de texto é mais prático."\n\nA Verdade: O texto é o refúgio dos covardes. Ele evita o tom de voz, o confronto e a emoção real.\n\nDiretriz Tática: Você tem um problema ou assunto pendente com alguém (trabalho ou família). Em vez de mandar um áudio ou texto e esperar a resposta confortavelmente, você vai ligar. Voz com voz. Resolva a pendência em 90 segundos reais. Suporte a fricção da comunicação humana.'
    },
    {
      'titulo': 'O CONTATO VISUAL LETAL',
      'conteudo': 'A Ilusão: "Olhar para baixo evita problemas."\n\nA Verdade: A submissão física treina o seu cérebro para a submissão psicológica.\n\nDiretriz Tática: Ao caminhar na rua hoje, mantenha a cabeça erguida. Quando alguém cruzar o seu caminho, estabeleça contato visual. Não seja agressivo, seja presente. Não desvie o olhar até que a outra pessoa o faça primeiro. Reivindique o seu espaço no mundo físico.'
    },
    {
      'titulo': 'A CONVERSA INÚTIL',
      'conteudo': 'A Ilusão: "Não devo incomodar estranhos."\n\nA Verdade: A hiperconectividade digital destruiu a tribo local. Ninguém olha na cara de quem serve o café.\n\nDiretriz Tática: Puxe assunto com um estranho hoje. O garçom, o motorista do Uber, a pessoa no elevador. Sem telas no meio. Faça uma pergunta real, ouça a resposta e sorria. Lembre ao seu sistema nervoso como os humanos operavam há vinte anos.'
    },
    {
      'titulo': 'A REJEIÇÃO VOLUNTÁRIA',
      'conteudo': 'A Ilusão: "Ouvir um \'não\' é uma ameaça à minha sobrevivência."\n\nA Verdade: O seu ego foi inflado por algoritmos que só te mostram o que você quer ver. O medo da rejeição te paralisa.\n\nDiretriz Tática: Peça algo hoje sabendo que a resposta será "não". Peça um desconto absurdo em um café, ou peça para passar na frente em uma fila sem motivo. Sinta a vergonha térmica bater no peito. Ouça o "não". Agradeça e saia. Perceba que você não morreu. O seu ego não é o seu mestre.'
    },
    {
      'titulo': 'O SILÊNCIO DESCONFORTÁVEL',
      'conteudo': 'A Ilusão: "Preciso preencher todas as pausas em uma conversa."\n\nA Verdade: O silêncio só é desconfortável para quem tem a mente caótica. A calma no silêncio é sinal de poder.\n\nDiretriz Tática: Durante uma conversa hoje, quando o assunto morrer, não tente ressuscitá-lo imediatamente e não pegue no celular. Deixe o silêncio durar 5 longos segundos. Respire. Olhe a pessoa nos olhos. Deixe que o outro sinta a pressão de falar.'
    },
    {
      'titulo': 'O OBSERVADOR FÍSICO',
      'conteudo': 'A Ilusão: "Eu conheço a minha própria cidade."\n\nA Verdade: Você conhece apenas o trajeto que o GPS manda, olhando para uma tela brilhante.\n\nDiretriz Tática: Deixe o celular em casa. Saia para caminhar por 30 minutos sem rumo definido. Memorize três detalhes da arquitetura local, da natureza ou das ruas que você nunca tinha notado. Force a sua mente a mapear a realidade analógica.'
    },
    {
      'titulo': 'A ROTA PRIMITIVA',
      'conteudo': 'A Ilusão: "O Waze otimiza o meu tempo."\n\nA Verdade: O GPS atrofiou o seu hipocampo (memória espacial). Você está terceirizando a sua orientação geográfica a um satélite.\n\nDiretriz Tática: Dirija ou caminhe hoje para um compromisso sem usar aplicativos de navegação. Olhe para o sol, estude um mapa antes de sair, preste atenção aos nomes das ruas e pontos de referência. Confie no seu instinto de navegação.'
    },
    {
      'titulo': 'O ESFORÇO BIOLÓGICO',
      'conteudo': 'A Ilusão: "Pedir comida pelo iFood é o prêmio de um dia duro."\n\nA Verdade: É a terceirização da sua biologia. A Matrix entrega calorias baratas na sua porta para te manter sedentário e domesticado.\n\nDiretriz Tática: Sem aplicativos de entrega hoje. Se tem fome, levante-se. Caminhe até o restaurante para buscar a comida ou, melhor ainda, cozinhe a sua própria refeição a partir de ingredientes crus. Coloque a mão na matéria.'
    },
    {
      'titulo': 'O CLIMA IMPLACÁVEL',
      'conteudo': 'A Ilusão: "O ar condicionado e o aquecimento são direitos básicos."\n\nA Verdade: O conforto térmico constante enfraquece o seu sistema imunológico e a sua resiliência mental.\n\nDiretriz Tática: Vá para a rua e enfrente o clima por 15 minutos sem proteção excessiva. Se estiver chovendo, deixe a água bater. Se estiver frio, sinta os tremores. Se estiver um sol rachando, transpire. Deixe o seu corpo lutar para regular a própria temperatura.'
    },
    {
      'titulo': 'A GRAVIDADE CONSTANTE',
      'conteudo': 'A Ilusão: "Vou poupar os joelhos usando o elevador."\n\nA Verdade: A civilização removeu a gravidade do seu dia a dia. Você está ficando frágil.\n\nDiretriz Tática: Proibido o uso de elevadores e escadas rolantes pelas próximas 24 horas. Independentemente do andar, suba as escadas. Sinta a queimação nos tendões, o pulmão expandindo e o peso real do seu próprio corpo.'
    },
    {
      'titulo': 'A LUZ ANALÓGICA',
      'conteudo': 'A Ilusão: "Preciso das luzes de teto ligadas para ficar acordado à noite."\n\nA Verdade: Você está enganando a sua biologia e fritando a sua glândula pineal com iluminação artificial intensa.\n\nDiretriz Tática: A partir das 20h de hoje, desligue TODAS as luzes principais (de teto) da sua casa. Use apenas um abajur fraco de canto ou uma vela. Sobreviva à noite na penumbra. Movimente-se no escuro. Deixe a biologia ditar o seu cansaço.'
    },
    {
      'titulo': 'O DESCONFORTO POSTURAL',
      'conteudo': 'A Ilusão: "O sofá é o meu lugar de descanso."\n\nA Verdade: O mobiliário macio e ergonômico encurtou os flexores do seu quadril e encurvou a sua coluna.\n\nDiretriz Tática: Hoje, quando for relaxar à noite, não sente no sofá. Sente-se no chão. Estique as pernas, cruze-as, mude de posição. O desconforto do chão duro forçará o seu corpo a se reajustar e a fortalecer a musculatura estabilizadora das costas.'
    },
    {
      'titulo': 'A BÚSSOLA INTERNA',
      'conteudo': 'A Ilusão: "O relógio controla o meu dia."\n\nA Verdade: Você está viciado em quantificar o tempo em frações exatas, gerando ansiedade crônica com atrasos invisíveis.\n\nDiretriz Tática: Esconda o seu relógio de pulso e remova o ícone do relógio da tela inicial do celular. Tente passar metade do dia adivinhando as horas pela posição do sol, pela luz e pelos seus próprios sinais de fome. Recupere o ritmo circadiano.'
    },
    {
      'titulo': 'O SANGRAMENTO FÍSICO',
      'conteudo': 'A Ilusão: "O Pix e a aproximação facilitam a vida."\n\nA Verdade: O dinheiro virtual anestesia a dor do gasto. Eles removeram a fricção para que você não sinta o seu recurso escorrer pelo ralo.\n\nDiretriz Tática: Vá a um caixa eletrônico e saque R\$ 100 em notas físicas. Hoje e amanhã, pague tudo (café, almoço, padaria) exclusivamente com dinheiro de papel. Sinta a fricção tátil. Veja o papel sair da sua mão e não voltar. Recalibre o peso psicológico do seu dinheiro.'
    },
    {
      'titulo': 'O ABSTINENTE DE CONSUMO',
      'conteudo': 'A Ilusão: "Preciso comprar coisas pequenas para manter o ânimo alto."\n\nA Verdade: O microconsumo é um band-aid de dopamina para cobrir o vazio existencial.\n\nDiretriz Tática: Dia de Gasto Zero. Nas próximas 24 horas, não compre absolutamente nada. Nem um café, nem um chiclete, nem um app de R\$ 4,90. Consuma apenas a comida e a água que já estão dentro da sua casa. Congele o impulso de passar o cartão.'
    },
    {
      'titulo': 'O INTERROGATÓRIO DE COMPRA',
      'conteudo': 'A Ilusão: "É só entrar na loja, olhar e levar."\n\nA Verdade: A pressão social te obriga a comprar coisas que você não quer só porque o vendedor foi "simpático".\n\nDiretriz Tática: Entre em uma loja física hoje. Olhe um produto caro. Chame o vendedor, faça três perguntas difíceis e técnicas sobre o produto. Faça-o gastar 5 minutos te explicando. No final, olhe nos olhos dele, diga: "Obrigado, não vou levar", vire as costas e saia de mãos vazias. Treine a sua imunidade à pressão de vendas.'
    },
    {
      'titulo': 'A AUDITORIA BRUTAL',
      'conteudo': 'A Ilusão: "São apenas R\$ 19,90 por mês, não faz diferença."\n\nA Verdade: As corporações se alimentam do seu esquecimento. A assinatura contínua invisível é o câncer do seu fluxo de caixa.\n\nDiretriz Tática: Pare o que está fazendo. Abra o aplicativo do seu banco. Cancele hoje, agora mesmo, uma assinatura (streaming, aplicativo, revista) que você usa menos de duas vezes por mês. Estanque a hemorragia silenciosa.'
    },
    {
      'titulo': 'O VALOR DO SUOR',
      'conteudo': 'A Ilusão: "Esse tênis custa 500 Reais."\n\nA Verdade: As coisas não custam dinheiro. Custam as horas irrecuperáveis da sua vida que você teve que sacrificar no trabalho para ganhar esse dinheiro.\n\nDiretriz Tática: Olhe para o objeto mais caro do cômodo em que você está. Calcule quantas horas de trabalho duro foram necessárias para comprá-lo, com base no seu ganho por hora atual. Avalie o peso da sua vida trocada por matéria morta.'
    },
    {
      'titulo': 'A RECUSA DO DESCONTO',
      'conteudo': 'A Ilusão: "Eu dou o meu CPF e ganho 10% de desconto na farmácia."\n\nA Verdade: Se o produto tem desconto em troca de cadastro, a mercadoria é você. Os seus dados de saúde e consumo valem ouro na Matrix.\n\nDiretriz Tática: Da próxima vez que o caixa da loja ou farmácia te pedir o CPF, celular ou e-mail para "fazer o cliente fidelidade", diga um "NÃO" seco. Pague o preço inteiro. Mantenha o seu anonimato tático e proteja os seus dados do sistema.'
    },
    {
      'titulo': 'O INVENTÁRIO DO VAZIO',
      'conteudo': 'A Ilusão: "Um dia eu vou usar isso."\n\nA Verdade: A desordem física gera desordem mental. Objetos acumulados são monumentos de promessas falhas e dopamina velha.\n\nDiretriz Tática: Encontre 5 objetos na sua casa que você comprou em um pico de empolgação e que não usa há mais de seis meses. Coloque-os em um saco. Doe ou jogue no lixo hoje. Liberte o seu perímetro de bagunça estagnada.'
    },
    {
      'titulo': 'O TREINO INVISÍVEL',
      'conteudo': 'A Ilusão: "Se eu não gravei e postei o treino, não teve efeito."\n\nA Verdade: A necessidade de aplausos destrói a disciplina bruta. O verdadeiro soldado treina na sombra.\n\nDiretriz Tática: Faça um treino intenso hoje (corrida, peso, flexões até a falha). A regra de ouro: Não use Apple Watch, não marque no Strava, não ouça podcast e NÃO poste uma única foto no espelho. Deixe o suor ser o seu único prêmio silencioso.'
    },
    {
      'titulo': 'O JEJUM DE OPINIÃO',
      'conteudo': 'A Ilusão: "Eu preciso corrigir essa pessoa e provar o meu ponto."\n\nA Verdade: Discutir com mentes programadas é desperdiçar energia biológica preciosa.\n\nDiretriz Tática: Hoje, alguém vai dizer algo estupidamente errado na sua frente. A sua missão: Não corrigir. Não argumentar. Não se justificar. Apenas diga "Hmmm, entendi" e mude de assunto. Pela primeira vez, preserve a sua energia e deixe a ignorância do outro queimar sozinha.'
    },
    {
      'titulo': 'O DESVIO DE ROTA',
      'conteudo': 'A Ilusão: "Eu conheço o melhor e mais rápido caminho para casa."\n\nA Verdade: A rotina e a repetição colocaram o seu cérebro no piloto automático. Você não está mais vivendo, está apenas reproduzindo um script.\n\nDiretriz Tática: Na volta do trabalho ou de um compromisso hoje, pegue um caminho completamente diferente e mais longo. Passe por ruas que você nunca entrou. O cérebro no piloto automático encolhe; a novidade geográfica força as suas sinapses a acordarem para mapear o território.'
    },
    {
      'titulo': 'O SEGREDO BLINDADO',
      'conteudo': 'A Ilusão: "A vitória só é real quando é compartilhada e validada pelos outros."\n\nA Verdade: A validação externa dilui a força interior. O orgulho silencioso é forjado no aço.\n\nDiretriz Tática: Cumpra um objetivo, supere uma meta difícil ou receba uma excelente notícia hoje. E conte isso a exatamente ZERO pessoas. Engula a vitória. Sinta o poder de carregar um triunfo que é inteira e exclusivamente seu.'
    },
    {
      'titulo': 'A IMERSÃO NO DESCONFORTO',
      'conteudo': 'A Ilusão: "Eu preciso de um colchão ortopédico para descansar o meu corpo cansado."\n\nA Verdade: O excesso de superfícies macias amoleceu o seu hardware. A biologia humana foi forjada no chão duro das cavernas.\n\nDiretriz Tática: Tire o luxo. Hoje, você vai dormir no chão. Estique um tapete de yoga ou um cobertor fino no piso do quarto e use apenas um travesseiro. O desconforto absoluto vai quebrar o seu ego e te lembrar que você é um animal que sobrevive a qualquer terreno.'
    },
    {
      'titulo': 'O ANTI-ESCAPISMO',
      'conteudo': 'A Ilusão: "Estou estressado, preciso comer um doce, ouvir música ou ver um vídeo para relaxar."\n\nA Verdade: Você foi treinado para nunca processar uma emoção negativa. Você foge da dor usando a dopamina como anestesia.\n\nDiretriz Tática: Hoje, quando você sentir uma emoção crua (tristeza, raiva, tédio ou frustração), não fuja. Não pegue o celular, não abra a geladeira, não ligue o Spotify. Sente-se em silêncio. Sinta a emoção queimar no peito por 10 minutos ininterruptos. Encare o monstro de frente até ele perder o poder sobre você.'
    },
    {
      'titulo': 'O ARQUITETO DO DESTINO',
      'conteudo': 'A Ilusão: "Cheguei ao fim do ciclo de 28 dias. O meu treino acabou."\n\nA Verdade: A guerra contra a Engenharia da Ilusão é permanente. A Matrix será sempre mais rápida, mais brilhante e mais viciante amanhã.\n\nDiretriz Tática: Pegue uma folha de papel. Escreva, à mão, os três "Decretos de Soberania" inegociáveis para a sua vida a partir de hoje (Ex: "O celular não entra no quarto", "Não negocio o meu sono"). Assine o papel e cole na parede. O Operador agora é o Arquiteto. A partir de hoje, você escreve o seu próprio código.'
    }
  ];

  // --- O MANUAL BIO-HACK D0 ---
  final List<Map<String, String>> _dossieD0 = [
    { 'titulo': 'DIRETRIZ ALPHA: CONTENÇÃO DE FREQUÊNCIA', 'conteudo': 'A radiação EMF sabota a biologia da sua glândula pineal e enfraquece seu escudo imune. Imponha \'Modo Avião Tático\' e mantenha o dispositivo fora de um raio de 2 metros do seu perímetro cerebral durante o sono.' },
    { 'titulo': 'DIRETRIZ BETA: BLOQUEIO DE ESPECTRO AZUL', 'conteudo': 'A radiação azul esteriliza a produção de melatonina, destruindo sua recuperação noturna. Equipe lentes de filtro âmbar 120 minutos antes do repouso para blindar seu sono REM.' },
    { 'titulo': 'DIRETRIZ GAMA: BLINDAGEM ENDÓCRINA', 'conteudo': 'A fricção térmica e as ondas de rádio (EMF) do aparelho no bolso incineram sua testosterona. Afaste transmissores do perímetro reprodutor. Celular no bolso é castração digital.' },
    { 'titulo': 'DIRETRIZ DELTA: DESCOMPRESSÃO VAGAL', 'conteudo': 'A postura de submissão (olhar para baixo para telas) colapsa o seu nervo vago e injeta ansiedade química no seu sangue. Erga o crânio. Fixe o horizonte. Resete a máquina.' },
    { 'titulo': 'DIRETRIZ ÉPSILON: QUARENTENA DE ATENÇÃO', 'conteudo': 'Algoritmos operam para parasitar a sua primeira hora do dia. Não negocie com a máquina. Imponha silêncio digital absoluto (zero telas) nos primeiros 60 minutos após o despertar.' },
    { 'titulo': 'DIRETRIZ ZETA: ISOLAMENTO ELETROMAGNÉTICO', 'conteudo': 'Para descompressão celular de nível militar, adote o Protocolo Blackout. Confine o dispositivo móvel em uma Bolsa Faraday para garantir blindagem total durante o seu ciclo noturno.' },
    { 'titulo': 'DIRETRIZ ETA: CALIBRAÇÃO OCULAR (20-20-20)', 'conteudo': 'Rompa a hipnose digital primitiva. A cada 20 minutos sob fogo visual cruzado (telas), desvie o seu foco para um objeto a 20 pés (6 metros) de distância por 20 segundos.' },
    { 'titulo': 'DIRETRIZ TETA: CORTE DE TRANSMISSÃO', 'conteudo': 'O sinal Wi-Fi fragmenta e invade as suas ondas neurais noturnas sem que você perceba. Aborte a energia do roteador da sua base antes de entrar em repouso. O blackout deve ser total.' },
    { 'titulo': 'DIRETRIZ IOTA: SINCRONIZAÇÃO CIRCADIANA', 'conteudo': 'Hackeie o seu relógio biológico. Exponha a sua retina à luz solar natural (direta, sem bloqueio de janelas) nos primeiros 30 minutos do dia para resetar o cortisol a seu favor.' },
    { 'titulo': 'DIRETRIZ KAPPA: INDUÇÃO BINAURAL', 'conteudo': 'Sofrendo de \'Brain Fog\' (Névoa Mental)? Injete frequências sonoras Alfa e Teta diretamente no cérebro. Use áudio binaural tático para forçar o foco extremo e induzir calma química sob pressão.' },
  ];

  void _abrirPainelMissao(BuildContext context, int diaIndex, String titulo, String conteudo) {
    _tocarAudioTatico(diaIndex + 1); 
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D120D), 
            border: Border.all(color: const Color(0xFF333333), width: 3), 
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 30, offset: Offset(0, -10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.circle, size: 8, color: Colors.grey),
                  Icon(Icons.circle, size: 8, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "DIA ${diaIndex + 1} // $titulo",
                style: const TextStyle(color: Color(0xFF00FF00), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                textAlign: TextAlign.center,
              ),
              const Divider(color: Color(0xFF333333), thickness: 2, height: 30),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    conteudo,
                    style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 15, height: 1.6, letterSpacing: 0.5),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _audioPlayer.stop(); // 🔇 CALAR A MÚSICA AO FECHAR
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF333333), Color(0xFF111111)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 5, offset: Offset(0, 3))],
                  ),
                  child: const Center(
                    child: Text(
                      "[ FECHAR DIRETRIZ ]",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _abrirPainelDossieD0(BuildContext context) {
    _tocarAudioTatico(0); 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D120D),
            border: Border.all(color: const Color(0xFF333333), width: 3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const Text("D0 // MANUAL BIO-HACK", style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const Divider(color: Colors.redAccent, thickness: 1, height: 20),
              
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.red.withOpacity(0.5))),
                child: const Text(
                  "[ ENGENHARIA ACÚSTICA ]\nTodas as trilhas deste sistema são forjadas com Tecnologia Neuro-Hack Binaural. O uso de fones de ouvido é diretriz tática obrigatória.",
                  style: TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 15),

              Expanded(
                child: ListView.builder(
                  itemCount: _dossieD0.length + 1, 
                  itemBuilder: (context, index) {
                    if (index == _dossieD0.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "AVISO LEGAL: O conteúdo deste dossiê possui caráter estritamente informativo. Ao aplicar as diretrizes, você assume o comando absoluto da sua própria biologia. Não substitui laudo médico.\n\nFIM DA TRANSMISSÃO.",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final item = _dossieD0[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border(left: BorderSide(color: Colors.green.shade900, width: 4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['titulo']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(item['conteudo']!, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              GestureDetector(
                onTap: () {
                  _audioPlayer.stop(); // 🔇 CALAR A MÚSICA AO FECHAR
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  color: Colors.redAccent.withOpacity(0.2),
                  child: const Center(child: Text("[ ABORTAR LEITURA ]", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _construirTelaDaMorte() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 80),
              const SizedBox(height: 20),
              const Text("ACESSO EXPIROU", style: TextStyle(color: Colors.redAccent, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 15),
              const Text(
                "O seu protocolo de 12 meses chegou ao fim. A base de dados e o VFC foram bloqueados. Renove o acesso para retomar o controle biológico.",
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
                // 🟢 Tiro ajustado para o Vitalício
                onPressed: () => launchUrl(Uri.parse(AppConfig.linkCheckoutVitalicio), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.settings, color: Colors.black),
                label: const Text("FORJAR ACESSO VITALÍCIO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.green));

    if (_diasAtivos > 365 && !_usuarioIsVip) {
      return _construirTelaDaMorte();
    }
    
    final bool isIscaWeb = kIsWeb && !_usuarioIsVip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A2A2A), Color(0xFF111111)],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 5))],
          ),
          child: Column(
            children: [
              const Text(
                "PROTOCOLO 28 DIAS",
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 3.0,
                  shadows: [Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1))],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "DIAS DE ATRITO: $_diasAtivos",
                style: const TextStyle(color: Color(0xFF00FF00), fontSize: 14, letterSpacing: 1.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: _missoes.length + 1, 
            itemBuilder: (context, index) {
              
              if (index == 0) {
                return GestureDetector(
                  onTap: () => _abrirPainelDossieD0(context),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    height: 120, 
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/mockup_biohack.png'), // A IMAGEM QUE VOCÊ SUBIU
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                      ),
                    ),
                    child: const Center(
                      child: Text("D0 // MANUAL BIO-HACK", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                  ),
                );
              }

              final missaoIndex = index - 1;
              final missao = _missoes[missaoIndex];
              final diaDaMissao = missaoIndex + 1; 
              final bool estaLiberado = _diasAtivos >= diaDaMissao;
              
              final bool deveBloquearNoGratis = isIscaWeb && missaoIndex > 0; 

              return CadeadoTatico(
                bloqueado: deveBloquearNoGratis, 
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: estaLiberado 
                          ? [const Color(0xFF222222), const Color(0xFF0F0F0F)] 
                          : [const Color(0xFF110505), const Color(0xFF000000)], 
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: estaLiberado ? const Color(0xFF3A3A3A) : const Color(0xFF330000), width: 2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "DIA ${missaoIndex + 1} // ${missao['titulo']}",
                              style: TextStyle(
                                color: estaLiberado ? const Color(0xFF00FF00) : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                fontSize: 14,
                                shadows: estaLiberado ? const [Shadow(color: Color(0x6600FF00), blurRadius: 4)] : [],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            estaLiberado ? Icons.lock_open : Icons.lock,
                            color: estaLiberado ? const Color(0xFF00FF00) : const Color(0xFFAA0000),
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      estaLiberado
                          ? _construirBotaoTaticoAmbar(() => _abrirPainelMissao(context, missaoIndex, missao['titulo']!, missao['conteudo']!))
                          : Center(
                              child: Text(
                                "BLOQUEADO // LIBERA EM ${diaDaMissao - _diasAtivos} DIA(S)",
                                style: const TextStyle(color: Color(0xFFAA0000), fontSize: 12, letterSpacing: 1.0, fontWeight: FontWeight.bold),
                              )
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ]
    );
  }

  Widget _construirBotaoTaticoAmbar(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE68A2E), Color(0xFFA65C17), Color(0xFF733E0B)], 
          ),
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 5, offset: Offset(0, 3))],
        ),
        child: const Center(
          child: Text(
            "ACESSAR DIRETRIZ",
            style: TextStyle(
              color: Colors.black, 
              fontWeight: FontWeight.w900, 
              letterSpacing: 2.0,
              shadows: [Shadow(color: Colors.white30, offset: Offset(-1, -1))],
            ),
          ),
        ),
      ),
    );
  }
}

class CadeadoTatico extends StatelessWidget {
  final Widget child;
  final bool bloqueado;

  const CadeadoTatico({super.key, required this.child, required this.bloqueado});

  @override
  Widget build(BuildContext context) {
    if (!bloqueado) return child;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF111111),
            shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.amber, width: 2), borderRadius: BorderRadius.circular(15)),
            title: const Text("AMOSTRA DE RECONHECIMENTO", style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
            content: const Text(
              "Você está utilizando uma amostra de reconhecimento do Artefato.\n\nDevido a altos custos operacionais de servidor e tecnologia da base de dados, o desbloqueio completo das 28 fases e trilhas de áudio é exclusivo do Comando Nível 2.\n\nAcesse a Engrenagem Dourada para destrancar a base.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text("RECUAR", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () {
                   Navigator.pop(context);
                   // 🟢 Tiro ajustado para o Combo (Recrutas)
                   launchUrl(Uri.parse(AppConfig.linkCheckoutCombo), mode: LaunchMode.externalApplication);
                },
                child: const Text("ENGRENAGEM DOURADA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              )
            ],
          )
        );
      },
      child: AbsorbPointer(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: ColorFiltered(colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation), child: Opacity(opacity: 0.5, child: child)),
              ),
            ),
            const Icon(Icons.lock_person_rounded, color: Colors.amber, size: 55, shadows: [Shadow(color: Colors.black, blurRadius: 15)]),
          ],
        ),
      ),
    );
  }
}
