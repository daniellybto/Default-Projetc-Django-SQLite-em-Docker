#!/bin/ash

# O shell irá encerrar a execução do script quando um comando falhar
set -e

# Verifica se a variável $PROJETO_NAME está vazia e define um valor padrão
if [ -z "${PROJETO_NAME}" ]; then
    PROJETO_NAME="djangoapp"
fi

if ! [ -d "$PROJETO_NAME" ]; then
  echo "A pasta do projeto não existe, criando-a então..."
  django-admin startproject ${PROJETO_NAME} .

  # verificar se o settings.py da versão do Django já inclui o import do módulo 'os'
  # ele verifica apenas nas 25 primeiras linhas do arquivo
  if ! head -n 25 ${PROJETO_NAME}/settings.py | grep -q "import os"; then
    #caso não exista esse import no arquivo ele irá adicionar na primeira linha do arquivo
    sed -i '1s/^/import os\n/' ${PROJETO_NAME}/settings.py
  fi

  # Substituindo os dados de SECRET_KEY definidos no .env:
  sed -i "s/^SECRET_KEY = .*/SECRET_KEY = os.getenv('SECRET_KEY', 'aft4ecef3af')/" ${PROJETO_NAME}/settings.py
  # Substituindo os dados de DEBUG definidos no .env:
  sed -i "s/^DEBUG = .*/DEBUG = bool(int(os.getenv('DEBUG', 0)))/" ${PROJETO_NAME}/settings.py
  # Substituindo os dados de DEBUG definidos no .env:
  sed -i "s/^ALLOWED_HOSTS = .*/ALLOWED_HOSTS = os.environ.get('DJANGO_ALLOWED_HOSTS').split(' ')/" ${PROJETO_NAME}/settings.py

  echo "Projeto criado com sucesso!!! Bom desenvolvimento ^-^ "
fi

pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 0.0.0.0:8000 --verbosity 3

exec "$@"
