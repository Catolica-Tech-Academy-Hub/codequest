# Guia de Desenvolvimento: Clean Architecture + DDD

## Objetivo

Padronizar decisões de arquitetura para que time humano e agentes de IA mantenham o mesmo núcleo estrutural ao longo da evolução do projeto.

## Regras de Arquitetura

- Cada feature deve ter camadas: domain, data, providers, presentation.
- Domínio não importa Firebase, Flutter, ou detalhes de infra.
- Casos de uso orquestram regras de negócio e usam contratos.
- Data implementa contratos e converte DTO <-> Entidade.
- Presentation apenas renderiza estado e dispara intenções.

## SOLID na Prática

### S - Single Responsibility Principle

Cada classe deve ter um único motivo para mudar.

Errado (mistura UI, regra e infra):

```dart
class LoginController {
	Future<void> login(String email, String password) async {
		final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
			email: email,
			password: password,
		);

		if (cred.user != null) {
			await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
				'lastLogin': DateTime.now().toIso8601String(),
			});
		}
	}
}
```

Certo (cada camada com responsabilidade clara):

```dart
abstract class AuthRepositoryContract {
	Future<UserSession> signIn(EmailAddress email, Password password);
}

class SignInUseCase {
	SignInUseCase(this._authRepository);

	final AuthRepositoryContract _authRepository;

	Future<UserSession> call(EmailAddress email, Password password) {
		return _authRepository.signIn(email, password);
	}
}
```

### O - Open/Closed Principle

Classes devem ser abertas para extensão e fechadas para modificação.

Exemplo: para novo método de login, criar novo use case (ex.: SignInWithGoogleUseCase) sem alterar SignInUseCase já estável.

### L - Liskov Substitution Principle

Implementações concretas devem respeitar o contrato.

Errado: contrato promete retornar sessão válida e implementação retorna null silenciosamente.

```dart
class FirebaseAuthRepository implements AuthRepositoryContract {
	@override
	Future<UserSession> signIn(EmailAddress email, Password password) async {
		return UserSession.anonymous();
	}
}
```

Certo: implementação lança falha de domínio quando não autentica.

```dart
class FirebaseAuthRepository implements AuthRepositoryContract {
	@override
	Future<UserSession> signIn(EmailAddress email, Password password) async {
		final user = await _gateway.signIn(email.value, password.value);
		if (user == null) {
			throw AuthFailure.invalidCredentials();
		}
		return UserSession.authenticated(userId: user.uid);
	}
}
```

### I - Interface Segregation Principle

Prefira interfaces pequenas, orientadas por caso de uso.

```dart
abstract class SessionReader {
	Stream<UserSession> observeSession();
}

abstract class SessionWriter {
	Future<void> signOut();
}
```

### D - Dependency Inversion Principle

Camada de aplicação depende de abstração, não de Firebase.

Errado:

```dart
class RegisterUserUseCase {
	Future<void> call(String email, String password) {
		return FirebaseAuth.instance.createUserWithEmailAndPassword(
			email: email,
			password: password,
		);
	}
}
```

Certo:

```dart
class RegisterUserUseCase {
	RegisterUserUseCase(this._repository);

	final AuthRepositoryContract _repository;

	Future<void> call(EmailAddress email, Password password, DisplayName name) {
		return _repository.signUp(email, password, name);
	}
}
```

## Regras Objetivas para IA Evitar Código Porco

- Não escrever regras de negócio em widgets.
- Não fazer provider acessar Firebase diretamente quando já existir repositório.
- Não usar Map<String, dynamic> como modelo de domínio.
- Não criar métodos com nomes genéricos (ex.: processData, handleStuff).
- Não misturar exceções de infraestrutura com erros de domínio sem tradução.
- Preferir funções pequenas, nomes explícitos e contratos tipados.

## Checklist de Revisão para IA

- Esta classe tem apenas uma responsabilidade?
- O domínio depende de abstrações e não de frameworks?
- O caso de uso pode ser testado sem Flutter/Firebase?
- Existe boundary clara entre entidade de domínio e DTO?
- A API pública da classe está coesa e pequena?

## Regras DDD (Tático)

- Entidades: possuem identidade e invariantes de negócio.
- Value Objects: encapsulam validações (ex.: Email, PasswordPolicy).
- Serviços de domínio: regras que não pertencem a uma única entidade.
- Repositórios: contratos orientados ao domínio, não ao banco.
- Linguagem ubíqua: nomes alinhados ao produto (Usuário, Sessão, Liga, Trilha).

## Regras para Agents de IA

- Nunca criar atalhos fora das camadas para "acelerar" entrega.
- Nunca mover regra de negócio para widget ou provider sem justificativa.
- Sempre propor contratos antes da implementação concreta.
- Sempre preservar padrões já existentes no projeto.
- Se houver conflito entre velocidade e arquitetura, priorizar arquitetura.

## Definição de Pronto (DoD)

- Código compila sem erros.
- Lints críticos resolvidos.
- Testes essenciais da camada de aplicação criados.
- Documentação da feature atualizada em docs/.
- PR explica impacto arquitetural.

## Links de Referência

- Flutter architecture: https://docs.flutter.dev/app-architecture
- Riverpod docs: https://riverpod.dev/
- DDD reference: https://www.domainlanguage.com/ddd/
- Firebase emulators: https://firebase.google.com/docs/emulator-suite
