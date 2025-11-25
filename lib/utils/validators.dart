/// Helper com validações reutilizáveis para formulários
class Validators {
  /// Valida campo de texto obrigatório
  static String? validarTextoObrigatorio(
    String? value, {
    String mensagem = 'Este campo é obrigatório',
    int? minLength,
    int? maxLength,
  }) {
    if (value == null || value.trim().isEmpty) {
      return mensagem;
    }

    final texto = value.trim();

    if (minLength != null && texto.length < minLength) {
      return 'Mínimo de $minLength caracteres';
    }

    if (maxLength != null && texto.length > maxLength) {
      return 'Máximo de $maxLength caracteres';
    }

    return null;
  }

  /// Valida campo de valor monetário
  /// Aceita vírgula e ponto como separador decimal
  static String? validarValor(
    String? value, {
    double? minValue,
    double? maxValue,
    bool obrigatorio = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return obrigatorio ? 'Digite o valor' : null;
    }

    // Remove espaços e substitui vírgula por ponto
    final valorLimpo = value.trim().replaceAll(' ', '').replaceAll(',', '.');

    // Tenta fazer o parsing
    final valor = double.tryParse(valorLimpo);

    if (valor == null) {
      return 'Valor inválido. Use apenas números';
    }

    if (minValue != null && valor < minValue) {
      return 'Valor mínimo: R\$ ${minValue.toStringAsFixed(2)}';
    }

    if (maxValue != null && valor > maxValue) {
      return 'Valor máximo: R\$ ${maxValue.toStringAsFixed(2)}';
    }

    return null;
  }

  /// Valida campo de número inteiro
  static String? validarInteiro(
    String? value, {
    int? minValue,
    int? maxValue,
    bool obrigatorio = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return obrigatorio ? 'Digite um número' : null;
    }

    final numero = int.tryParse(value.trim());

    if (numero == null) {
      return 'Número inválido';
    }

    if (minValue != null && numero < minValue) {
      return 'Valor mínimo: $minValue';
    }

    if (maxValue != null && numero > maxValue) {
      return 'Valor máximo: $maxValue';
    }

    return null;
  }

  /// Valida prioridade (1-10)
  static String? validarPrioridade(String? value) {
    return validarInteiro(
      value,
      minValue: 1,
      maxValue: 10,
      obrigatorio: true,
    );
  }

  /// Valida email
  static String? validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Digite seu email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email inválido';
    }

    return null;
  }

  /// Valida senha
  static String? validarSenha(
    String? value, {
    int minLength = 6,
    bool verificarComplexidade = false,
  }) {
    if (value == null || value.isEmpty) {
      return 'Digite sua senha';
    }

    if (value.length < minLength) {
      return 'Senha deve ter no mínimo $minLength caracteres';
    }

    if (verificarComplexidade) {
      bool temMaiuscula = value.contains(RegExp(r'[A-Z]'));
      bool temMinuscula = value.contains(RegExp(r'[a-z]'));
      bool temNumero = value.contains(RegExp(r'[0-9]'));

      if (!temMaiuscula || !temMinuscula || !temNumero) {
        return 'Senha deve conter maiúsculas, minúsculas e números';
      }
    }

    return null;
  }

  /// Parse de valor monetário seguro
  static double parseValor(String value) {
    final valorLimpo = value.trim().replaceAll(' ', '').replaceAll(',', '.');
    return double.tryParse(valorLimpo) ?? 0.0;
  }

  /// Parse de inteiro seguro
  static int parseInt(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  /// Formata valor monetário para exibição
  static String formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}