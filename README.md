# Clima Flutter ⛅

*README gerado por IA*

Aplicativo meteorológico completo desenvolvido em **Flutter/Dart** com null safety, consumindo a API gratuita e sem chave da **Open-Meteo** e ícones climáticos oficiais do **OpenWeatherMap**.

O app conta com autenticação e cadastro locais, catálogo de cidades paginado em grade, geocodificação/busca de localidades, tela de detalhes com previsão de 7 dias e métricas climáticas completas, gerenciamento global de favoritos e cidades consultadas com persistência isolada por usuário via `SharedPreferences`, e acessibilidade completa (conformidade WCAG / TalkBack / VoiceOver).

---

## 🛠️ Stack Tecnológica

- **Flutter** & **Dart** (Null safety habilitado)
- **Gerenciamento de Estado**: `provider` (`MultiProvider`, `ChangeNotifier`, `ChangeNotifierProxyProvider`, `Consumer`, `context.watch`)
- **Comunicação HTTP**: `http` (com timeout resiliente e tratamento de exceções customizadas)
- **Persistência Local**: `shared_preferences` (dados serializados em JSON e chaves isoladas por e-mail do usuário)
- **Segurança**: `crypto` (hashing SHA-256 para senhas de usuários)

---

## 📋 Mapeamento de Requisitos Funcionais (RF01 – RF10)

| Requisito | Descrição | Arquivos de Implementação |
|---|---|---|
| **Login / Baseline** | Cadastro (nome, e-mail, senha, cidade de origem), login com validação, hash SHA-256, persistência de sessão ativa e navegação condicional. | [`lib/screens/login_screen.dart`](lib/screens/login_screen.dart)<br>[`lib/screens/register_screen.dart`](lib/screens/register_screen.dart)<br>[`lib/providers/auth_provider.dart`](lib/providers/auth_provider.dart)<br>[`lib/services/storage_service.dart`](lib/services/storage_service.dart)<br>[`lib/main.dart`](lib/main.dart) |
| **RF01 – Tela Principal** | Grade (`GridView`) com nome, país, temperatura atual e ícone oficial. A cidade de origem do usuário aparece sempre em 1º lugar. Paginação em lotes de 10 cidades com botão "Carregar Mais". Tratamento resiliente de imagens (`loadingBuilder` e `errorBuilder`). AppBar com atalhos para Favoritos, Consultadas e Logout. | [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart)<br>[`lib/providers/cities_provider.dart`](lib/providers/cities_provider.dart)<br>[`lib/widgets/city_card.dart`](lib/widgets/city_card.dart)<br>[`lib/widgets/weather_icon_widget.dart`](lib/widgets/weather_icon_widget.dart)<br>[`lib/utils/default_cities.dart`](lib/utils/default_cities.dart) |
| **RF02 – Navegação** | Transição fluida para a Tela de Detalhes via `Navigator.push(MaterialPageRoute)`. | [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart)<br>[`lib/screens/favorites_screen.dart`](lib/screens/favorites_screen.dart)<br>[`lib/screens/consumed_screen.dart`](lib/screens/consumed_screen.dart) |
| **RF03 – Tela de Detalhes** | Segunda requisição para previsão estendida: ícone grande, temperatura atual, sensação térmica, descrição textual, umidade, vento, pressão atmosférica, índice UV, horários de nascer e pôr do sol, e lista com previsão dos próximos 7 dias (mín/máx, condição, chuva em mm). | [`lib/screens/details_screen.dart`](lib/screens/details_screen.dart)<br>[`lib/widgets/stat_card.dart`](lib/widgets/stat_card.dart)<br>[`lib/widgets/daily_forecast_tile.dart`](lib/widgets/daily_forecast_tile.dart)<br>[`lib/services/weather_api_service.dart`](lib/services/weather_api_service.dart) |
| **RF04 – Favoritos com Provider** | Botão de estrela (`IconButton`) na Tela de Detalhes para favoritar/desfavoritar. `FavoritesProvider` (`ChangeNotifier`) registrado globalmente no `MultiProvider`. | [`lib/providers/favorites_provider.dart`](lib/providers/favorites_provider.dart)<br>[`lib/screens/details_screen.dart`](lib/screens/details_screen.dart)<br>[`lib/main.dart`](lib/main.dart) |
| **RF05 – Tela de Favoritos** | Tela dedicada listando cidades favoritas via `context.watch<FavoritesProvider>()`. Remoção direta da lista, toque para detalhes e estado vazio amigável. | [`lib/screens/favorites_screen.dart`](lib/screens/favorites_screen.dart) |
| **RF06 – Persistência** | Salvamento de favoritos e cidades consultadas em JSON no `SharedPreferences`, segregado por usuário logado (`favorites_{email}` e `consumed_{email}`). | [`lib/services/storage_service.dart`](lib/services/storage_service.dart)<br>[`lib/providers/favorites_provider.dart`](lib/providers/favorites_provider.dart)<br>[`lib/providers/consumed_provider.dart`](lib/providers/consumed_provider.dart) |
| **RF07 – Consultadas** | Marcação de cidade como "Consultada" na Tela de Detalhes via `SwitchListTile`. Tela dedicada "Cidades Consultadas" com remoção direta e persistência (`ConsumedProvider`). | [`lib/screens/consumed_screen.dart`](lib/screens/consumed_screen.dart)<br>[`lib/providers/consumed_provider.dart`](lib/providers/consumed_provider.dart)<br>[`lib/screens/details_screen.dart`](lib/screens/details_screen.dart) |
| **RF08 – Busca Direta** | Campo de busca (`TextField` + `TextEditingController` + botão "Buscar") na Tela Principal que consulta o endpoint de geocodificação e navega diretamente para os detalhes da cidade encontrada, com tratamento de erros. | [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart)<br>[`lib/services/weather_api_service.dart`](lib/services/weather_api_service.dart) |
| **RF09 – Feedback de UI** | Indicadores de progresso (`CircularProgressIndicator`) no login, cadastro, busca, carregamento inicial, "Carregar Mais" e detalhes. Tratamento de quedas de conexão ou timeout com `ErrorView` e botão "Tentar novamente". | [`lib/widgets/error_view.dart`](lib/widgets/error_view.dart)<br>[`lib/screens/home_screen.dart`](lib/screens/home_screen.dart)<br>[`lib/screens/details_screen.dart`](lib/screens/details_screen.dart)<br>[`lib/services/weather_api_service.dart`](lib/services/weather_api_service.dart) |
| **RF10 – Acessibilidade** | Rótulos semânticos (`Semantics`, `semanticLabel`), contraste com `ColorScheme`, áreas de toque mínimas de 48x48 dp e resiliência ao aumento da escala de fontes (`MediaQuery.textScaler`). | [`lib/utils/app_theme.dart`](lib/utils/app_theme.dart)<br>[`lib/widgets/city_card.dart`](lib/widgets/city_card.dart)<br>[`lib/widgets/weather_icon_widget.dart`](lib/widgets/weather_icon_widget.dart)<br>[`lib/widgets/stat_card.dart`](lib/widgets/stat_card.dart)<br>[`lib/widgets/daily_forecast_tile.dart`](lib/widgets/daily_forecast_tile.dart) |

---

## 📱 Permissões Nativas de Internet

### Android
No arquivo [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml), a permissão de rede foi adicionada como filha direta de `<manifest>`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <application ...>
        ...
    </application>
</manifest>
```

### iOS
No arquivo [`ios/Runner/Info.plist`](ios/Runner/Info.plist), conexões HTTPS (utilizadas por `api.open-meteo.com` e `openweathermap.org`) já são permitidas nativamente pelo App Transport Security (ATS) da Apple. Para suporte a redirecionamentos irrestritos, pode-se assegurar:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

---

## 🚀 Como Executar o Projeto

1. **Instalar as dependências**:
   ```bash
   flutter pub get
   ```

2. **Verificar a integridade do código**:
   ```bash
   flutter analyze
   flutter test
   ```

3. **Executar no emulador ou dispositivo conectado**:
   ```bash
   flutter run
   ```

---

## ♿ Roteiro de Teste de Acessibilidade (TalkBack / VoiceOver)

Para validar a acessibilidade com leitores de tela:

### 1. Ativação
- **Android (TalkBack)**: Acesse *Configurações > Acessibilidade > TalkBack* e ative o serviço (ou pressione os dois botões de volume por 3 segundos caso o atalho esteja configurado).
- **iOS (VoiceOver)**: Acesse *Ajustes > Acessibilidade > VoiceOver* e ative (ou clique três vezes no botão lateral).

### 2. Fluxo de Verificação
1. **Tela de Login / Cadastro**:
   - Navegue por gestos de deslize (swipe para a direita).
   - Verifique se os campos de e-mail, senha, nome e cidade anunciam claramente sua finalidade e requisitos (ex.: "Campo de texto para digitar sua senha com no mínimo 6 caracteres").
   - O botão "Entrar" deve anunciar: *"Botão para autenticar e entrar no aplicativo"*.
2. **Tela Principal (Catálogo)**:
   - Deslize pelos cards da grade. O leitor anunciará o resumo completo: *"Cidade: São Paulo, Brasil. Temperatura: 24 graus Celsius. Condição: Parcialmente nublado. Toque para ver detalhes"*.
   - Se for a cidade de origem cadastrada pelo usuário, o leitor anunciará explicitamente: *"Sua cidade de origem"*.
   - A barra de busca e o botão "Buscar" possuem rótulos claros para leitura.
   - O botão "Carregar Mais" anuncia *"Carregar mais cidades no catálogo"*.
3. **Tela de Detalhes**:
   - O botão de estrela anuncia o estado atual: *"Adicionar [Cidade] aos favoritos"* ou *"Remover [Cidade] dos favoritos"*.
   - A chave de seleção anuncia *"Marcar como Consultada"*.
   - Cada métrica (Umidade, Vento, Pressão, UV, Sol) e os 7 dias de previsão anunciam valores e datas descritivas de forma natural e contextualizada.
4. **Escala de Texto Ampliada**:
   - Acesse *Configurações > Tela > Tamanho da Fonte* e ajuste para o nível máximo.
   - Abra o app e verifique que os textos da grade, cabeçalhos e listas se adaptam sem corte ou overflow gráfico (`RenderFlex overflowed`).
