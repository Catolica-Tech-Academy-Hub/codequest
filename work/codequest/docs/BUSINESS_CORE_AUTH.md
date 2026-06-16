# Core de Regra de Negócio Base: Autenticação

## Escopo da Primeira Implementação

- Login com e-mail e senha.
- Criação de usuário com nome, e-mail e senha.
- Gestão de sessão (usuário autenticado, logout, recuperação de senha).
- Persistência de perfil mínimo no Firestore.

## Modelo de Domínio Inicial

### Entidades

- UserAccount
  - id
  - email
  - displayName
  - leagueId
  - createdAt

- UserSession
  - userId
  - isAuthenticated
  - issuedAt

### Value Objects sugeridos

- EmailAddress
  - formato válido
  - normalização (trim/lowercase)

- PasswordPolicy
  - mínimo de 8 caracteres
  - ao menos uma letra e um número (evolutivo)

- DisplayName
  - tamanho mínimo e máximo
  - caracteres permitidos

## Casos de Uso

- SignInWithEmailAndPassword
- RegisterUserAccount
- ObserveSession
- SignOutCurrentUser
- SendPasswordReset

## Regras de Negócio

- Cadastro deve criar usuário no Auth e documento em users/{uid}.
- Cadastro novo inicia com leagueId bronze-001.
- Login só é permitido para credenciais válidas no Auth.
- Sessão inválida redireciona para rota /login.
- Usuário autenticado não deve acessar /login e /register.

## Contratos (Interfaces)

- AuthRepositoryContract
  - signIn(email, password)
  - signUp(email, password, name)
  - signOut()
  - sendPasswordReset(email)
  - authStateChanges

- UserProfileRepositoryContract
  - createProfile(user)
  - getProfile(uid)

## Critérios de Aceite da Feature de Auth

- Login funcional com usuário seed.
- Cadastro funcional criando Auth + Firestore.
- Logout funcional.
- Recuperação de senha disparando e-mail.
- Redirecionamento automático por estado de sessão.

## Testes Recomendados

- Caso de uso de cadastro com sucesso.
- Caso de uso de cadastro com e-mail inválido.
- Caso de uso de login com senha incorreta.
- Caso de uso de logout.
- Provider de sessão emitindo estado autenticado e anônimo.
