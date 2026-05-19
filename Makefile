SHELL := /bin/sh

PROJECT_NAME := codequest
FLUTTER_DEFINE_DEV := --dart-define=USE_EMULATOR=true

.PHONY: help env-init up bootstrap infra-up infra-down down android-setup run-dev clean logs seed deps gen analyze test build-apk run migrate ci doctor

help:
	@echo "Comandos disponíveis:"
	@echo ""
	@echo "  Setup inicial (rodar uma vez do zero):"
	@echo "  make infra-up      - Setup completo: Docker + Firebase + Android SDK + emulador"
	@echo "  make run-dev       - Inicia emulador (se necessario) e roda o app Flutter"
	@echo ""
	@echo "  Outros:"
	@echo "  make up            - Sobe docker, aplica bootstrap e inicia o app Flutter"
	@echo "  make env-init      - Cria .env a partir de .env.example (se não existir)"
	@echo "  make bootstrap     - Instala deps e gera código"
	@echo "  make android-setup - Configura ambiente Android (variaveis, AVD, licencas)"
	@echo "  make infra-down    - Derruba emuladores Docker"
	@echo "  make run           - Roda o app Flutter em modo dev (emulador ja deve estar ativo)"
	@echo "  make ci            - Executa pipeline local (analyze/test/build)"

env-init:
	powershell -NoProfile -ExecutionPolicy Bypass -Command "if (-not (Test-Path -LiteralPath '.env')) { Copy-Item -LiteralPath '.env.example' -Destination '.env'; Write-Host '.env criado a partir de .env.example' } else { Write-Host '.env ja existe' }"

android-setup:
	powershell -ExecutionPolicy Bypass -File scripts/android-setup.ps1

run-dev:
	powershell -ExecutionPolicy Bypass -File scripts/run-dev.ps1

up: env-init infra-up deps migrate gen run-dev

bootstrap: env-init deps migrate gen

infra-up: env-init android-setup
	docker compose up -d --build

infra-down:
	docker compose down

down: infra-down

clean:
	flutter clean
	docker compose down -v

logs:
	docker compose logs -f firebase-emulators

seed:
	docker compose run --rm seed-runner

deps:
	flutter pub get
	npm --prefix firebase/functions install
	npm --prefix firebase/seed install

migrate:
	powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'Firestore is schemaless; indexes and rules are loaded by Firebase emulators via firebase/firebase.json'"

gen:
	dart run build_runner build --force-jit

analyze:
	flutter analyze

test:
	flutter test

build-apk:
	flutter build apk --release

run:
	flutter run $(FLUTTER_DEFINE_DEV)

ci: deps gen analyze test

doctor:
	flutter doctor -v
	docker --version
	docker compose version
