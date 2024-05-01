FROM python:3.7.17-alpine3.18
LABEL Danielly Brito <danielly.eng@hotmail.com>

# impede que o python grave arquivos pyc no disco (equivalente ao comando: `python -B`)
ENV PYTHONDONTWRITEBYTECODE 1
# impede que o python armazene em buffer stdout e stderr (equivalente ao comando: `python -u`)
ENV PYTHONUNBUFFERED 1

# puxando os argumentos que foi definido no docker-compose.yml - nome do usuário definido lá
ARG user

# copiando o arquivo de script para dentro do container:
COPY ./entrypoint.sh /usr/src

# atualizando o PIP e adicionando um usuário sem privilégios de root para executar o conteiner:
RUN pip install --upgrade pip && \
    adduser --no-create-home --disabled-password $user && \
    sed -i 's/\r$//g' /usr/src/entrypoint.sh && \
    chmod +x /usr/src/entrypoint.sh && \
    chown $user:$user /usr/src/entrypoint.sh

# copia a pasta de desenvolvimento `app/djangoApp` para dentro do conteiner alterando o chown e permissão dessa pasta
COPY --chown=$user:$user ./app /usr/src/app

# definindo diretório de trabalho
WORKDIR /usr/src/app

# instala os pacotes necessários para a aplicação Django rodar e constrói a pasta `data/` que será um dos volumes utilizado pelo container
RUN pip install -r requirements.txt && \
    chmod -R 755 /usr/src/app && \
    chown -R $user:$user /usr/src/app

# definindo o usuário que irá 'iniciar' o docker:
USER $user