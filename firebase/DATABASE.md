# Estrutura do Banco de Dados (Firestore)

Este documento mapeia a estrutura de coleções, subcoleções e os principais campos utilizados no projeto CodeQuest. O modelo segue os princípios de banco de dados NoSQL (baseado em documentos).

## 🧑‍💻 Users (`/users`)
Armazena o perfil principal e o progresso global dos usuários.

* **uid** (string): ID único (vem do Firebase Auth).
* **email** (string): E-mail do usuário.
* **name** / **displayName** (string): Nome de exibição.
* **leagueId** (string): ID da liga atual do usuário.
* **xpTotal** (int): Experiência total acumulada.
* **streakDays** (int): Dias consecutivos de ofensiva.
* **positionChange** (int): Variação de posição no ranking.
* **createdAt** / **updatedAt** (timestamp): Controle de estado.

### Subcoleção: Histórico de XP (`/users/{uid}/xpHistory`)
*Restrito para leitura apenas pelo dono do perfil.*
* **xpEarned** (int): Quantidade de XP ganho.
* **source** (string): Origem do XP (ex: 'activity', 'challenge').
* **earnedAt** (timestamp): Data e hora.

---

## 🏆 Leagues (`/leagues`)
Gerencia as ligas do sistema de ranqueamento.

* **id** (string): Identificador da liga.
* **name** (string): Nome (ex: Bronze, Prata, Ouro).
* **tier** (int): Nível hierárquico da liga.
* **promotionThreshold** (int): Pontuação/posição necessária para subir de liga.
* **totalParticipants** (int): Total de membros ativos.

### Subcoleção: Members (`/leagues/{leagueId}/members`)
* **uid** (string): ID do usuário referenciado.
* **name** (string): Nome do usuário.
* **xp** (int): XP total na liga.
* **weeklyXp** (int): XP contabilizado para a semana atual.
* **position** (int): Posição atual no ranking.
* **deltaPosition** (int): Variação de posições.

---

## 🗺️ Trails (`/trails`)
Trilhas de aprendizado disponíveis no aplicativo.

* **id** (string): Identificador da trilha (ex: 'flutter-basico').
* **title** (string): Título de exibição.
* **language** (string): Linguagem/Tecnologia (ex: 'Dart').
* **description** (string): Resumo da trilha.
* **totalLevels** (int): Quantidade total de níveis.

### Subcoleção: Levels (`/trails/{trailId}/levels`)
* **id** (string): ID do nível.
* **type** (string): Tipo de nível (ex: 'theory', 'quiz', 'code', 'challenge').
* **title** (string): Título do nível.
* **xpReward** (int): Recompensa base de XP.
* **order** (int): Ordem de exibição na trilha.
* **isUnlocked** (boolean): Controle de progressão.
* **stars** (int): Desempenho do usuário (0 a 3).

---

## 📝 Activities (`/activities`)
Atividades isoladas referenciadas pelos níveis das trilhas.

* **id** (string): Identificador da atividade.
* **type** (string): Formato (ex: 'multipleChoice', 'fillInBlank', 'codeOrder').
* **question** (string): Enunciado da questão.
* **options** (array): Opções de resposta (se aplicável).
* **correctAnswer** (string): Resposta correta para validação automática.
* **hint** (string): Dica de resolução.
* **xpReward** (int): Pontuação da atividade.
* **difficulty** (string): Nível de dificuldade (ex: 'easy', 'medium').
* **isActive** (boolean): Flag de soft-delete/ocultação.

---

## 🧩 Challenges (`/challenges`)
Desafios complexos, como montagem de blocos (Block Assembly).

* **id** (string): Identificador do desafio.
* **title** (string): Nome do desafio.
* **description** (string): Regras e contexto.
* **difficulty** (string): Dificuldade.
* **xpReward** (int): Recompensa.
* **maxAttempts** (int): Número máximo de tentativas permitidas.
* **blocks** (array): Lista de objetos contendo os blocos (`id`, `label`, `expectedPosition`) para validação lógica.

---

## ⚙️ Meta (`/meta`)
Documentos singulares para estatísticas gerais e controle do sistema.

* **projectId** (string): ID do projeto.
* **appliedAt** (timestamp): Data do último seed/atualização.
* **usersCount** (int): Total de usuários.
* **activitiesCount** (int): Total de atividades cadastradas.