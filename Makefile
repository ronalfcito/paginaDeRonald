# Makefile para proyecto Flask con Docker y despliegue en VPS

# Variables
IMAGE_NAME = ghcr.io/ronalfcito/pagina:latest
STACK_FILE = stack.yml
VPS_USER = $(shell echo $$VPS_USER)
VPS_HOST = $(shell echo $$VPS_HOST)
VPS_SSH_PORT = $(shell echo $$VPS_SSH_PORT)
VPS_SSH_KEY = $(shell echo $$VPS_SSH_KEY)

# Default target
.PHONY: all
all: help

# Ayuda
.PHONY: help
help:
    @echo "Targets disponibles:"
    @echo "  build      Construir imagen Docker localmente"
    @echo "  push       Subir imagen a GitHub Container Registry"
    @echo "  deploy     Copiar stack.yml y desplegar en VPS"
    @echo "  clean      Eliminar imagen Docker local"

# Construir imagen Docker
.PHONY: build
build:
    docker build -t $(IMAGE_NAME) .

# Subir imagen a GHCR (requiere GHCR_PAT como variable de entorno)
.PHONY: push
push:
    echo "$(GHCR_PAT)" | docker login ghcr.io -u $(GITHUB_ACTOR) --password-stdin
    docker push $(IMAGE_NAME)

# Desplegar en VPS usando llaves SSH
.PHONY: deploy
deploy:
    @echo "Copiando archivos al VPS..."
    scp -i $(VPS_SSH_KEY) -P $(VPS_SSH_PORT) $(STACK_FILE) Makefile $(VPS_USER)@$(VPS_HOST):~/despliegue/
    ssh -i $(VPS_SSH_KEY) -p $(VPS_SSH_PORT) $(VPS_USER)@$(VPS_HOST) \
        "cd ~/despliegue && docker stack deploy -c $(STACK_FILE) flask-app"

# Limpiar imágenes locales
.PHONY: clean
clean:
    docker rmi $(IMAGE_NAME) || true
