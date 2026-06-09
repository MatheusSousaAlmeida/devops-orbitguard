#!/bin/bash

RESOURCE_GROUP="rg-orbitguard"
LOCATION="canadacentral"
VM_NAME="vm-orbitguard"
VM_SIZE="Standard_D2s_v3"
ADMIN_USER="azureuser"
ADMIN_PASSWORD="OrbitGuard@Azure2026"
IMAGE="Canonical:ubuntu-24_04-lts:server:latest"

echo "============================================"
echo "  OrbitGuard — Provisionamento Azure"
echo "============================================"

# Tarefa 1 — Criar Resource Group e VM
echo ""
echo "[1/4] Criando Resource Group e VM..."

az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION"

echo "Resource Group '$RESOURCE_GROUP' criado em '$LOCATION'."

az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --size "$VM_SIZE" \
  --image "$IMAGE" \
  --admin-username "$ADMIN_USER" \
  --authentication-type password \
  --admin-password "$ADMIN_PASSWORD" \
  --public-ip-sku Standard

echo "VM '$VM_NAME' criada com sucesso."

# Tarefa 2 — Abrir portas no NSG
echo ""
echo "[2/4] Abrindo portas no NSG..."

NSG_NAME="${VM_NAME}NSG"

az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "Allow-SSH" \
  --priority 100 \
  --protocol Tcp \
  --destination-port-range 22 \
  --access Allow \
  --direction Inbound

az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "Allow-HTTP" \
  --priority 110 \
  --protocol Tcp \
  --destination-port-range 80 \
  --access Allow \
  --direction Inbound

az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "Allow-API" \
  --priority 120 \
  --protocol Tcp \
  --destination-port-range 8080 \
  --access Allow \
  --direction Inbound

az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --name "Allow-Oracle" \
  --priority 130 \
  --protocol Tcp \
  --destination-port-range 1521 \
  --access Allow \
  --direction Inbound

echo "Portas abertas: 22, 80, 8080, 1521."

# Tarefa 3 — Instalar Docker na VM
echo ""
echo "[3/4] Instalando Docker na VM..."

az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts '
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable docker
    systemctl start docker
    usermod -aG docker azureuser
  '

echo "Docker instalado com sucesso."

# Tarefa 4 — Instalar ferramentas auxiliares e preparar diretório
echo ""
echo "[4/4] Instalando Git e ferramentas auxiliares..."

az vm run-command invoke \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --command-id RunShellScript \
  --scripts '
    apt-get install -y git nano curl wget unzip htop
    mkdir -p /opt/orbitguard
    chown azureuser:azureuser /opt/orbitguard
  '

echo "Instalações realizadas com sucesso."

# Exibir dados de acesso
PUBLIC_IP=$(az vm show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --show-details \
  --query publicIps \
  --output tsv)

echo ""
echo "============================================"
echo "  VM criada com sucesso!"
echo "============================================"
echo "  IP Público : $PUBLIC_IP"
echo "  SSH        : ssh $ADMIN_USER@$PUBLIC_IP"
echo "  Senha      : $ADMIN_PASSWORD"
echo "============================================"
