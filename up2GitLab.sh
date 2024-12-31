#!/bin/bash

# Up2GitLab 0.2
# Actualitzar facil i rapidament el teu repositori de GitLab
# (CC) 2024 Victor Santos
# https://vctrsnts.github.io
# Bajo licencia GNU/GPL

# Mode de fer servir: executal de la següent manera:
# sh up2GitLab.sh <fitxers>

# Actualitzacio del public key amb GitLab
eval "$(ssh-agent -s)"
ssh-add /root/.ssh/github_web

ssh -T git@github.com

sleep 10

# A traves de Docker, actualitzem el fitxer RSS
# docker exec jekyll_book bundle exec jekyll build
# cp ../Gemfile .
docker exec jekyll_book bundle exec jekyll build

sleep 10

# cp ../Gemfile .

# Solicita el mensaje del commit
read -p "Introduce el mensaje del commit: " commit_message

rm -rf .fuse*

# Asegúrate de estar en el directorio del repositorio
repo_dir="/mnt/user/appdata/jekyll_book/_site"
cd "$repo_dir" || { echo "Directorio del repositorio no encontrado"; exit 1; }

# Establecer el repositorio remoto (opcional, si no está ya configurado)
# remote_repo="git@gitlab.com:vctrsnts/vctrsnts.git"
remote_repo="git@github.com:Vctrsnts/llibres.git"
git remote add master "$remote_repo" 2>/dev/null

# Configurar la reconciliación de ramas divergentes
git config --global pull.rebase false

# Añade todos los cambios al índice
if ! git add .; then
    echo "Error al añadir cambios"
    exit 1
fi

# Realiza el commit con el mensaje ingresado
if ! git commit -m "$commit_message"; then
    echo "Error al realizar el commit. Verifica que hay cambios para commitear."
    exit 1
fi

# Realiza el push a la rama master
if ! git push origin master --force; then
    echo "Error al realizar el push a la rama master"
    exit 1
fi

# Registro de actividades
log_file="$repo_dir/push_log.txt"
echo "$(date): Commit realizado con mensaje '$commit_message' y push a la rama master" >> "$log_file"

echo "Cambios subidos con éxito a la rama master."
