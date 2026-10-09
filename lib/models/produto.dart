/// Entidade imutável: um produto do catálogo.
class Produto {
  final String sku;     // código único do produto (chave de identificação)
  final String nome;
  final double preco;
  final int estoque;    // quantas unidades existem

  // const: permite criar produtos "constantes", resolvidos já na compilação.
  // required: todo parâmetro nomeado é obrigatório.
  const Produto({
    required this.sku,
    required this.nome,
    required this.preco,
    required this.estoque,
  });
}