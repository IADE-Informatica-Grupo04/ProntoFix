// Estimativa do tempo de chegada do prestador por simulação de Monte Carlo.
// 
// Modelo (tempo total, em minutos), repetido N vezes com valores aleatórios:
//
//     T = arranque + (distância_em_linha_reta × circuidade / velocidade) × 60 + atraso
//
//   arranque    ~ Uniforme(2, 8) min          tempo até o prestador sair
//   circuidade  ~ Uniforme(1.2, 1.5)          a estrada é mais longa do que a linha reta
//   velocidade  ~ Normal(30, 8) km/h, truncada a [10, 60]   (trânsito urbano)
//   atraso      = 0 em 85 % dos casos; nos restantes 15 %, Exponencial(média 8 min)
//                 (trânsito pesado, estacionamento, incidente)
//
// Estimativa devolvida: mediana (P50) e intervalo P10–P90.
// Estes parâmetros são PRESSUPOSTOS (ainda não há dados reais):Com dados reais podem ser calibrados a partir dos tempos medidos.

const PARAMETROS = Object.freeze({
  simulacoes: 5000,
  arranque: Object.freeze({ min: 2, max: 8 }),
  circuidade: Object.freeze({ min: 1.2, max: 1.5 }),
  velocidade: Object.freeze({ media: 30, desvio: 8, min: 10, max: 60 }),
  atraso: Object.freeze({ probabilidade: 0.15, media: 8 }),
  minimoMin: 5, 
});

// ── Gerador pseudoaleatório com semente (mulberry32) ─────────────────
// Com a mesma semente dá sempre a mesma sequência: a estimativa mostrada ao
// cliente é igual à que fica guardada no pedido, e os testes são repetíveis.
function mulberry32(semente) {
  let a = semente | 0;
  return function () {
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Semente a partir da distância (arredondada a 100 m): FNV-1a de 32 bits.
function sementeDe(distanciaKm) {
  const texto = String(Math.round(distanciaKm * 10));
  let h = 0x811c9dc5;
  for (let i = 0; i < texto.length; i++) {
    h ^= texto.charCodeAt(i);
    h = Math.imul(h, 0x01000193);
  }
  return h >>> 0;
}

// ── Distribuições ────────────────────────────────────────────────────
const uniforme = (rng, min, max) => min + (max - min) * rng();

function normalPadrao(rng) { // Box–Muller
  let u = 0;
  while (u === 0) u = rng();
  return Math.sqrt(-2 * Math.log(u)) * Math.cos(2 * Math.PI * rng());
}

function normalTruncada(rng, { media, desvio, min, max }) { // por rejeição
  for (let i = 0; i < 100; i++) {
    const x = media + desvio * normalPadrao(rng);
    if (x >= min && x <= max) return x;
  }
  return media;
}

const exponencial = (rng, media) => -media * Math.log(1 - rng());

// ── Simulação ────────────────────────────────────────────────────────
function juntarParametros(extra = {}) {
  const p = { ...PARAMETROS };
  for (const k of Object.keys(extra)) {
    p[k] = typeof PARAMETROS[k] === 'object' ? { ...PARAMETROS[k], ...extra[k] } : extra[k];
  }
  return p;
}

/** N tempos de chegada simulados (minutos). */
function simularAmostras(distanciaKm, { simulacoes, semente, parametros } = {}) {
  if (!Number.isFinite(distanciaKm) || distanciaKm < 0) {
    throw new RangeError('distanciaKm tem de ser um número >= 0');
  }
  const p = juntarParametros(parametros);
  const n = simulacoes ?? p.simulacoes;
  const rng = mulberry32(semente ?? sementeDe(distanciaKm));

  const amostras = new Float64Array(n);
  for (let i = 0; i < n; i++) {
    const arranque = uniforme(rng, p.arranque.min, p.arranque.max);
    const estradaKm = distanciaKm * uniforme(rng, p.circuidade.min, p.circuidade.max);
    const velocidade = normalTruncada(rng, p.velocidade);
    const atraso = rng() < p.atraso.probabilidade ? exponencial(rng, p.atraso.media) : 0;
    amostras[i] = arranque + (estradaKm / velocidade) * 60 + atraso;
  }
  return amostras;
}

function percentil(ordenado, q) { // interpolação linear
  const pos = (ordenado.length - 1) * q;
  const i = Math.floor(pos);
  const f = pos - i;
  return i + 1 < ordenado.length ? ordenado[i] * (1 - f) + ordenado[i + 1] * f : ordenado[i];
}

/**
 * Resumo da simulação, em minutos.
 * mediana/p10/p90 vêm em minutos inteiros (com o mínimo aplicado);
 * media/desvio são decimais (1 casa), úteis para o relatório.
 */
function simularChegada(distanciaKm, opcoes = {}) {
  const amostras = simularAmostras(distanciaKm, opcoes);
  const n = amostras.length;
  const minimo = juntarParametros(opcoes.parametros).minimoMin;

  let soma = 0;
  for (const x of amostras) soma += x;
  const media = soma / n;
  let somaQuad = 0;
  for (const x of amostras) somaQuad += (x - media) ** 2;
  const desvio = Math.sqrt(somaQuad / (n - 1));

  amostras.sort(); // Float64Array ordena numericamente
  const arredonda = (x) => Math.max(minimo, Math.round(x));
  return {
    simulacoes: n,
    media: Math.round(media * 10) / 10,
    desvio: Math.round(desvio * 10) / 10,
    mediana: arredonda(percentil(amostras, 0.5)),
    p10: arredonda(percentil(amostras, 0.1)),
    p90: arredonda(percentil(amostras, 0.9)),
  };
}

module.exports = { PARAMETROS, simularAmostras, simularChegada };
