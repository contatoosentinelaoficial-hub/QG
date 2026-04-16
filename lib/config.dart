class AppConfig {
  // A CHAVE DE BIFURCAÇÃO: 
  // Mude para 'true' quando for gerar o APK Vitalício. 
  // Deixe 'false' para gerar o APK Anual ou o PWA Isca Web.
  static const bool isVitalicio = false;

  // 🎯 LINK 1: ALVO NOVATO (Amostra Grátis) -> Oferta do Combo
  static const String linkCheckoutCombo = 'https://pay.kiwify.com.br/evuxf9d';

  // 🎯 LINK 2: ALVO VETERANO (Plano Anual) -> Oferta de Upgrade Direto
  static const String linkCheckoutVitalicio = 'https://pay.kiwify.com.br/3YkOUBk';
}
