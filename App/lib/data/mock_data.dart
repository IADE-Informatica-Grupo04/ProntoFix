import '../models/mensagem.dart';
import '../models/pedido.dart';
import '../models/prestador.dart';
import '../models/servico.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';

/// Dados de exemplo (fictícios) usados em todo o protótipo.

const List<Servico> servicos = [
  Servico(
    nome: 'Canalização',
    icone: PFIcons.gota,
    corFundo: PFColors.tint,
  ),
  Servico(
    nome: 'Eletricidade',
    icone: PFIcons.raio,
    corFundo: PFColors.warningBg,
  ),
  Servico(
    nome: 'Serralharia',
    icone: PFIcons.chave,
    corFundo: PFColors.accentBg,
  ),
];

/// Prestador atribuído ao pedido ativo do cliente.
const Prestador prestadorAtribuido = Prestador(
  nome: 'Carlos Mendes',
  profissao: 'Canalizador',
  avaliacao: 4.8,
  numAvaliacoes: 126,
  servicos: 312,
  etaMinutos: 12,
);

/// Total do serviço concluído (mão de obra + material).
const String totalServico = '42,00 €';

// ---------------------------------------------------------------- Cliente

const List<Pedido> pedidosAtivosCliente = [
  Pedido(
    id: 1,
    titulo: 'Fuga na cozinha',
    categoria: 'Canalização',
    estado: EstadoPedido.aCaminho,
    contraparte: 'Carlos Mendes',
    data: 'Hoje, 11:40',
    preco: '35–50 €',
  ),
];

/// Sem pedidos agendados: mostra o estado vazio.
const List<Pedido> pedidosAgendadosCliente = [];

const List<Pedido> historicoCliente = [
  Pedido(
    id: 2,
    titulo: 'Fechadura encravada',
    categoria: 'Serralharia',
    estado: EstadoPedido.concluido,
    contraparte: 'Hugo Matos',
    data: 'Ontem, 19:15',
    preco: '42,00 €',
  ),
  Pedido(
    id: 3,
    titulo: 'Quadro elétrico a disparar',
    categoria: 'Eletricidade',
    estado: EstadoPedido.concluido,
    contraparte: 'Marta Silva',
    data: '18 out, 08:30',
    preco: '68,00 €',
  ),
  Pedido(
    id: 4,
    titulo: 'Torneira a pingar',
    categoria: 'Canalização',
    estado: EstadoPedido.concluido,
    contraparte: 'Carlos Mendes',
    data: '02 out, 21:05',
    preco: '30,00 €',
  ),
  Pedido(
    id: 5,
    titulo: 'Tomada sem corrente',
    categoria: 'Eletricidade',
    estado: EstadoPedido.cancelado,
    contraparte: 'Marta Silva',
    data: '25 set, 10:20',
    preco: '0,00 €',
  ),
];

// -------------------------------------------------------------- Prestador

const List<Pedido> pedidosAtivosPrestador = [];

const List<Pedido> pedidosAgendadosPrestador = [
  Pedido(
    id: 21,
    titulo: 'Torneira a pingar',
    categoria: 'Canalização',
    estado: EstadoPedido.atribuido,
    contraparte: 'Ana Costa',
    data: 'Hoje, 15:30',
    preco: '30–40 €',
  ),
  Pedido(
    id: 22,
    titulo: 'Autoclismo avariado',
    categoria: 'Canalização',
    estado: EstadoPedido.atribuido,
    contraparte: 'Pedro Lopes',
    data: 'Hoje, 18:00',
    preco: '40–55 €',
  ),
];

const List<Pedido> historicoPrestador = [
  Pedido(
    id: 31,
    titulo: 'Fuga no lava-loiça',
    categoria: 'Canalização',
    estado: EstadoPedido.concluido,
    contraparte: 'Sofia Reis',
    data: 'Hoje, 09:10',
    preco: '45,00 €',
  ),
  Pedido(
    id: 32,
    titulo: 'Esquentador sem água quente',
    categoria: 'Canalização',
    estado: EstadoPedido.concluido,
    contraparte: 'Carlos Dias',
    data: 'Ontem, 20:40',
    preco: '60,00 €',
  ),
];

// ------------------------------------------------------------------- Chat

const List<Mensagem> mensagensIniciais = [
  Mensagem(
    texto: 'Olá! Já estou a caminho. Chego dentro de 12 minutos.',
    minha: false,
    hora: '11:42',
  ),
  Mensagem(
    texto: 'Obrigada. A porta é no 2.º andar, à esquerda.',
    minha: true,
    hora: '11:43',
  ),
  Mensagem(
    texto: 'Combinado. Se puder, feche a torneira geral até eu chegar.',
    minha: false,
    hora: '11:44',
  ),
];
