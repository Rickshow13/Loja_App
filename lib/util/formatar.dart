/// 1234.5 -> "R$ 1234,50"
String formatarPreco(double valor) =>
    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';