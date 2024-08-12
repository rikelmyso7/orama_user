class Descartavel {
  final String name;
  final String type; // "numeric", "fractional", "text"

  Descartavel({required this.name, required this.type});
}

// Lista de descartáveis com tipos definidos
final List<Descartavel> descartaveis = [
  Descartavel(name: 'ÁLCOOL LÍQUIDO', type: 'fractional'),
  Descartavel(name: 'DETERGENTE', type: 'fractional'),
  Descartavel(name: 'ESPONJA', type: 'numeric'),
  Descartavel(name: 'ÁLCOOL EM GEL', type: 'fractional'),
  Descartavel(name: 'COPO ISOPOR 180ML (EMBALAGENS FECHADAS)', type: 'quantity'),
  Descartavel(name: 'COPO ISOPOR 120ML (EMBALAGENS FECHADAS)', type: 'quantity'),
  Descartavel(name: 'COPO ORAMA 180ML (EMBALAGENS FECHADAS)', type: 'quantity'),
  Descartavel(name: 'GIZ LIQUIDO', type: 'numeric'),
  Descartavel(name: 'ISOPOR VIAGENS', type: 'numeric'),
  Descartavel(name: 'GUARDANAPO (EMBALAGENS FECHADAS)', type: 'quantity'),
  Descartavel(name: 'LUVAS (PARES)', type: 'quantity'),
  Descartavel(name: 'PAPEL FILME', type: 'text'),
  Descartavel(name: 'PÁ DE MADEIRA AMOSTRA', type: 'fractional'),
  Descartavel(name: 'PÁ DE MADEIRA GRANDE', type: 'fractional'),
  Descartavel(name: 'PERFLEX', type: 'numeric'),
  Descartavel(name: 'PANOS BRANCOS', type: 'numeric'),
  Descartavel(name: 'BARBANTE', type: 'numeric'),
  Descartavel(name: 'FITA PVC', type: 'numeric'),
  Descartavel(name: 'PLAQUINHAS DE SABORES', type: 'quantity'),
  Descartavel(name: 'SACOLAS BRANCAS LIXO', type: 'text'),
  Descartavel(name: 'SACO DE LIXO 30L PRETO', type: 'text'),
  Descartavel(name: 'SACO DE LIXO 100L PRETO', type: 'text'),
  Descartavel(name: 'SACOLAS PAPEL PARDO', type: 'numeric'),
  Descartavel(name: 'VEJA MULTIUSO', type: 'fractional'),
  Descartavel(name: 'AVENTAL', type: 'numeric'),
  Descartavel(name: 'TOUCAS DESCARTAVEIS', type: 'numeric'),
  Descartavel(name: 'TOUCAS DE TECIDO', type: 'numeric'),
  Descartavel(name: 'BLUSAS UNIFORME', type: 'numeric'),
  Descartavel(name: 'BALDE DE ÁGUA', type: 'numeric'),
  Descartavel(name: 'BOLEADOR AÇO', type: 'numeric'),
  Descartavel(name: 'ESPATULA AÇO', type: 'numeric'),
  Descartavel(name: 'ESPATULA BORRACHA', type: 'numeric'),
  Descartavel(name: 'MOLDE DE CASQUINHA', type: 'numeric'),
  Descartavel(name: 'PEGADOR CASQUINHA', type: 'numeric'),
  Descartavel(name: 'FACA DE SERRA', type: 'numeric'),
  Descartavel(name: 'MAQUINA DE CARTÃO', type: 'numeric'),
  Descartavel(name: 'CARREGADOR', type: 'numeric'),
  Descartavel(name: 'BOBINA MÁQUINA CARTÃO', type: 'numeric'),
  Descartavel(name: 'PANOS CHITA TECIDO', type: 'numeric'),
  Descartavel(name: 'EXPOSITOR DE CASQUINHAS', type: 'numeric'),
  Descartavel(name: 'POTE DE MANTEIGA', type: 'fractional'),
];
