# ProntoFix — Protótipo Flutter

Protótipo visual da aplicação **ProntoFix**: pedidos de reparações urgentes ao domicílio
(Canalização, Eletricidade e Serralharia), com cliente e prestador.
Trabalho de grupo de Programação de Dispositivos Móveis (PDM) — "Protótipo da Aplicação Final".

## Grupo 04

| Nome | N.º de aluno |
|---|---|
| Emanuel Jacinto | 20251741 |
| Paulo Tibúrcio | 20252415 |
| Márcio Nhanga | 20252075 |
| Narciso Correia | 20251969 |

## Tema

ProntoFix liga quem tem uma avaria doméstica urgente a prestadores verificados:
o cliente pede ajuda em poucos toques, vê o preço estimado antes de confirmar,
acompanha o prestador no mapa, paga e avalia.

O visual segue o **ProntoFix Style Guide** (cores, Inter, ícones Lucide, grelha de 8 px,
margem de 20 px, alvos de toque de 44 px, estados dos componentes) e os requisitos do
**Relatório da Fase 1** (RF04, RF25–RF32, RU01–RU10, RM01–RM07).

## Como executar

A app fala com o servidor Node.js do ProntoFix (pasta `backend/` do repositório,
ramo `feat-api`). Primeiro liga-se o servidor, depois a app.

### 1. Base de dados e servidor

```bash
cd backend
mysql -u root -p < sql/create.sql
mysql -u root -p prontofix < sql/alter_app.sql
mysql -u root -p prontofix < sql/populate.sql
cp .env.example .env      # pôr o utilizador e a palavra-passe do MySQL
npm install
npm run dev               # http://localhost:3000/api
```

### 2. App

Requisitos: Flutter 3.22 ou superior (Dart 3).

```bash
flutter pub get
flutter run                                   # emulador Android (usa 10.0.2.2)
flutter run --dart-define=API_URL=http://192.168.1.20:3000/api   # telemóvel: IP do PC na mesma rede Wi-Fi
```

A pasta `android/` já vem incluída. Para iOS, execute antes `flutter create .` (não altera `lib/` nem `pubspec.yaml`).

### Contas de demonstração (palavra-passe `prontofix123`)

| Conta | Perfil |
|---|---|
| joao@email.com | Cliente (Lisboa) |
| ana@email.com | Cliente |
| carlos@email.com | Prestador · Canalização |
| rui@email.com | Prestador · Eletricidade |
| marta@email.com | Prestador · Serralharia |

### Testar o fluxo completo (segue a Documentação da API REST)

1. **Cliente** (joao@email.com): Novo pedido → escolher a categoria → a app pede
   a estimativa (`POST /pedidos/estimativa`) → Confirmar (`POST /pedidos`).
   O servidor atribui logo o prestador livre mais próximo da categoria.
2. **Prestador** (ex.: carlos@email.com para Canalização): ao abrir o painel a app
   envia a localização e a disponibilidade. O pedido aparece como *atribuído* →
   "Aceitar e ir a caminho" (`POST /pedidos/:id/aceitar`) → aparece o **QR**.
3. **Cliente**: no acompanhamento, "Confirmar chegada (QR)" → introduzir/colar o
   código (`POST /pedidos/:id/chegada`) → estado *no local*.
   (No mesmo telemóvel: o prestador toca em "Copiar código", sai e entra o cliente, que toca em "Colar código".)
4. **Prestador**: "Começar serviço" (`em_curso`) → "Concluir serviço" com o preço final.
5. **Cliente**: paga (simulado na app) e avalia (`POST /pedidos/:id/avaliacao`).

O ecrã do cliente atualiza a cada 3 s e o painel do prestador a cada 4 s.

### O que vem do servidor e o que continua simulado

Vem do servidor: login/registo (JWT), categorias, estimativa, criar/cancelar pedido,
atribuição automática, estado em tempo real, confirmação de chegada por QR,
mudança de estado pelo prestador, preço final, avaliação, disponibilidade e
localização do prestador.

Continua simulado, porque a API não tem rota para isso: **pagamento**, notificações,
histórico do prestador e chat. Sem GPS na app, a localização usada é fixa em Lisboa
(`latitudeDemo`/`longitudeDemo` em `lib/services/api_service.dart`). O cliente
escreve ou cola o código do QR (a leitura com a câmara pode ser acrescentada com o
pacote `mobile_scanner`).

## Ecrãs (16)

| # | Ecrã | Ficheiro |
|---|---|---|
| 1 | Inicial | `splash_screen.dart` |
| 2 | Login (Cliente / Prestador) | `login_screen.dart` |
| 3 | Registo | `registo_screen.dart` |
| 4 | Estrutura com barra inferior (Início, Pedidos, Histórico, Perfil) | `main_shell.dart` |
| 5 | Início do cliente | `home_cliente_screen.dart` |
| 6 | Painel do prestador | `painel_prestador_screen.dart` |
| 7 | Pedidos (Ativos / Agendados) | `pedidos_screen.dart` |
| 8 | Histórico (carregamento, pesquisa, vazio) | `historico_screen.dart` |
| 9 | Perfil | `perfil_screen.dart` |
| 10 | Ajuda (FAQ) | `ajuda_screen.dart` |
| 11 | Novo pedido — passo 1 | `novo_pedido_screen.dart` |
| 12 | Localização e estimativa — passo 2 | `localizacao_orcamento_screen.dart` |
| 13 | Acompanhamento ao vivo | `acompanhamento_screen.dart` |
| 14 | Chat | `chat_screen.dart` |
| 15 | Pagamento — passo 3 | `pagamento_screen.dart` |
| 16 | Avaliação | `avaliacao_screen.dart` |

## Fluxos para testar

- **Pedido rápido (≤ 5 toques, RU01):** Início → "Pedir ajuda já" → descrever → "Continuar" → "Confirmar pedido".
- **Acompanhamento:** procura (2,5 s) → atribuído → a caminho → no local → concluído (toque em "Simular: …" para avançar) → "Pagar 42,00 €" → avaliação.
- **Cancelar:** no acompanhamento, "Cancelar pedido" pede confirmação.
- **Prestador:** no login escolha "Prestador" (qualquer email válido e palavra-passe de 6+ caracteres).
- **Sem barra inferior no pedido (RU03):** os ecrãs do pedido abrem por cima da estrutura principal.

## Estrutura

```
lib/
  main.dart            arranque e tema
  app_routes.dart      rotas com nome
  theme/               cores, espaçamentos, tipografia (app_theme.dart) e ícones Lucide (pf_icons.dart)
  models/              Servico, Prestador, Pedido, Mensagem, DadosPedido
  data/mock_data.dart  dados de exemplo
  widgets/             componentes reutilizáveis (PFButton, PFTextField, PFCard, PFChip/PFTag,
                       PFTabs, PFBottomNav, PFTopBar, PedidoCard, PrestadorCard, MapaPlaceholder, ...)
  screens/             os 16 ecrãs
assets/fonts/          Inter e Lucide (com licenças)
```

Coleções dinâmicas: `ListView.builder` (pedidos, histórico, chat, agenda do prestador),
`ListView` com `for` e `Wrap`/`Row` (serviços, métodos de pagamento).

## O que é simulado

- Sem base de dados, API ou autenticação: login e registo aceitam dados válidos e entram.
- Os dados são fictícios (`lib/data/mock_data.dart`).
- O mapa é um desenho (sem Google Maps); o GPS e a câmara são simulados.
- O QR é só um botão ("QR disponível") com uma mensagem simulada; o chat responde com mensagens automáticas.
- Pagamento e avaliação não guardam nada.
- Ações ainda não implementadas mostram uma mensagem (SnackBar).

## Licenças

Tipo de letra **Inter** (SIL Open Font License) e ícones **Lucide** (licença ISC);
os textos das licenças estão em `assets/fonts/`.
