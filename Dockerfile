# 1. Imagem base com Python
FROM python:3.11-slim

# 2. Diretório de trabalho
WORKDIR /app

# 3. Copia e instala dependências
COPY requirements.txt .
RUN  pip install --no-cache-dir \
    -r requirements.txt

# 4. Copia o código da aplicação
COPY . .

# 5. Porta exposta pelo container
EXPOSE 8000

# 6. Comando de inicialização
CMD ["python", "app.py"]