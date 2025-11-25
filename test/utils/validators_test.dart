import 'package:flutter_test/flutter_test.dart';
import 'package:tcc2025_leanatan/utils/validators.dart';

void main() {
  group('Validators - validarTextoObrigatorio', () {
    test('deve retornar erro quando o texto estiver vazio', () {
      expect(
        Validators.validarTextoObrigatorio(''),
        equals('Este campo é obrigatório'),
      );
      expect(
        Validators.validarTextoObrigatorio(null),
        equals('Este campo é obrigatório'),
      );
      expect(
        Validators.validarTextoObrigatorio('   '),
        equals('Este campo é obrigatório'),
      );
    });

    test('deve retornar null quando o texto for válido', () {
      expect(Validators.validarTextoObrigatorio('Texto válido'), isNull);
      expect(Validators.validarTextoObrigatorio('ABC'), isNull);
    });

    test('deve validar tamanho mínimo', () {
      expect(
        Validators.validarTextoObrigatorio('AB', minLength: 3),
        equals('Mínimo de 3 caracteres'),
      );
      expect(
        Validators.validarTextoObrigatorio('ABC', minLength: 3),
        isNull,
      );
    });

    test('deve validar tamanho máximo', () {
      expect(
        Validators.validarTextoObrigatorio('ABCDEFGHIJ', maxLength: 5),
        equals('Máximo de 5 caracteres'),
      );
      expect(
        Validators.validarTextoObrigatorio('ABCDE', maxLength: 5),
        isNull,
      );
    });

    test('deve usar mensagem customizada', () {
      expect(
        Validators.validarTextoObrigatorio('', mensagem: 'Campo obrigatório!'),
        equals('Campo obrigatório!'),
      );
    });
  });

  group('Validators - validarValor', () {
    test('deve aceitar valores com vírgula', () {
      expect(Validators.validarValor('10,50'), isNull);
      expect(Validators.validarValor('1.234,56'), isNull);
    });

    test('deve aceitar valores com ponto', () {
      expect(Validators.validarValor('10.50'), isNull);
      expect(Validators.validarValor('1234.56'), isNull);
    });

    test('deve rejeitar valores inválidos', () {
      expect(
        Validators.validarValor('abc'),
        equals('Valor inválido. Use apenas números'),
      );
      expect(
        Validators.validarValor('10,50,30'),
        equals('Valor inválido. Use apenas números'),
      );
      expect(
        Validators.validarValor('R\$ 10'),
        equals('Valor inválido. Use apenas números'),
      );
    });

    test('deve validar valor mínimo', () {
      expect(
        Validators.validarValor('5', minValue: 10),
        equals('Valor mínimo: R\$ 10.00'),
      );
      expect(
        Validators.validarValor('10', minValue: 10),
        isNull,
      );
      expect(
        Validators.validarValor('15', minValue: 10),
        isNull,
      );
    });

    test('deve validar valor máximo', () {
      expect(
        Validators.validarValor('150', maxValue: 100),
        equals('Valor máximo: R\$ 100.00'),
      );
      expect(
        Validators.validarValor('100', maxValue: 100),
        isNull,
      );
      expect(
        Validators.validarValor('50', maxValue: 100),
        isNull,
      );
    });

    test('deve aceitar campo vazio quando não obrigatório', () {
      expect(Validators.validarValor('', obrigatorio: false), isNull);
      expect(Validators.validarValor(null, obrigatorio: false), isNull);
    });

    test('deve rejeitar campo vazio quando obrigatório', () {
      expect(Validators.validarValor(''), equals('Digite o valor'));
      expect(Validators.validarValor(null), equals('Digite o valor'));
    });
  });

  group('Validators - validarInteiro', () {
    test('deve aceitar números inteiros válidos', () {
      expect(Validators.validarInteiro('1'), isNull);
      expect(Validators.validarInteiro('10'), isNull);
      expect(Validators.validarInteiro('100'), isNull);
    });

    test('deve rejeitar valores não numéricos', () {
      expect(
        Validators.validarInteiro('abc'),
        equals('Número inválido'),
      );
      expect(
        Validators.validarInteiro('10.5'),
        equals('Número inválido'),
      );
    });

    test('deve validar valor mínimo', () {
      expect(
        Validators.validarInteiro('5', minValue: 10),
        equals('Valor mínimo: 10'),
      );
      expect(Validators.validarInteiro('10', minValue: 10), isNull);
    });

    test('deve validar valor máximo', () {
      expect(
        Validators.validarInteiro('15', maxValue: 10),
        equals('Valor máximo: 10'),
      );
      expect(Validators.validarInteiro('10', maxValue: 10), isNull);
    });
  });

  group('Validators - validarPrioridade', () {
    test('deve aceitar valores entre 1 e 10', () {
      expect(Validators.validarPrioridade('1'), isNull);
      expect(Validators.validarPrioridade('5'), isNull);
      expect(Validators.validarPrioridade('10'), isNull);
    });

    test('deve rejeitar valores fora do intervalo', () {
      expect(
        Validators.validarPrioridade('0'),
        equals('Valor mínimo: 1'),
      );
      expect(
        Validators.validarPrioridade('11'),
        equals('Valor máximo: 10'),
      );
      expect(
        Validators.validarPrioridade('-1'),
        equals('Valor mínimo: 1'),
      );
    });
  });

  group('Validators - validarEmail', () {
    test('deve aceitar emails válidos', () {
      expect(Validators.validarEmail('teste@exemplo.com'), isNull);
      expect(Validators.validarEmail('usuario.nome@dominio.com.br'), isNull);
      expect(Validators.validarEmail('teste123@email.co'), isNull);
    });

    test('deve rejeitar emails inválidos', () {
      expect(Validators.validarEmail(''), equals('Digite seu email'));
      expect(Validators.validarEmail('invalido'), equals('Email inválido'));
      expect(Validators.validarEmail('sem@dominio'), equals('Email inválido'));
      expect(Validators.validarEmail('@dominio.com'), equals('Email inválido'));
      expect(Validators.validarEmail('teste@'), equals('Email inválido'));
    });
  });

  group('Validators - validarSenha', () {
    test('deve aceitar senhas válidas', () {
      expect(Validators.validarSenha('123456'), isNull);
      expect(Validators.validarSenha('senhaforte123'), isNull);
    });

    test('deve rejeitar senhas vazias', () {
      expect(Validators.validarSenha(''), equals('Digite sua senha'));
      expect(Validators.validarSenha(null), equals('Digite sua senha'));
    });

    test('deve validar tamanho mínimo', () {
      expect(
        Validators.validarSenha('123', minLength: 6),
        equals('Senha deve ter no mínimo 6 caracteres'),
      );
      expect(Validators.validarSenha('123456', minLength: 6), isNull);
    });

    test('deve validar complexidade quando solicitado', () {
      expect(
        Validators.validarSenha('senhafraca', verificarComplexidade: true),
        equals('Senha deve conter maiúsculas, minúsculas e números'),
      );
      expect(
        Validators.validarSenha('SenhaForte123', verificarComplexidade: true),
        isNull,
      );
    });
  });

  group('Validators - parseValor', () {
    test('deve fazer parsing correto de valores', () {
      expect(Validators.parseValor('10'), equals(10.0));
      expect(Validators.parseValor('10.5'), equals(10.5));
      expect(Validators.parseValor('10,5'), equals(10.5));
      expect(Validators.parseValor('1.234,56'), equals(1234.56));
      expect(Validators.parseValor('  10.5  '), equals(10.5));
    });

    test('deve retornar 0 para valores inválidos', () {
      expect(Validators.parseValor('abc'), equals(0.0));
      expect(Validators.parseValor(''), equals(0.0));
      expect(Validators.parseValor('R\$ 10'), equals(0.0));
    });
  });

  group('Validators - parseInt', () {
    test('deve fazer parsing correto de inteiros', () {
      expect(Validators.parseInt('10'), equals(10));
      expect(Validators.parseInt('123'), equals(123));
      expect(Validators.parseInt('  5  '), equals(5));
    });

    test('deve retornar 0 para valores inválidos', () {
      expect(Validators.parseInt('abc'), equals(0));
      expect(Validators.parseInt('10.5'), equals(0));
      expect(Validators.parseInt(''), equals(0));
    });
  });

  group('Validators - formatarValor', () {
    test('deve formatar valores corretamente', () {
      expect(Validators.formatarValor(10.0), equals('R\$ 10,00'));
      expect(Validators.formatarValor(10.5), equals('R\$ 10,50'));
      expect(Validators.formatarValor(1234.56), equals('R\$ 1234,56'));
      expect(Validators.formatarValor(0.99), equals('R\$ 0,99'));
    });
  });
}