# 🛰️ OrbitGuard — DevOps


## 📋 Índice

- [Descrição do Projeto](#-descrição-do-projeto)
- [Benefícios para o Negócio](#-benefícios-para-o-negócio)
- [Arquitetura](#️-arquitetura)
- [Repositórios Utilizados](#-repositórios-utilizados)
- [Rotas da API](#-rotas-da-api)
- [Instalação — How To](#-instalação--how-to)
- [Dockerfile](#-dockerfile)
- [Docker Compose](#-docker-compose)
- [Estrutura do Repositório](#-estrutura-do-repositório)
- [Integrantes](#-integrantes)



## 📖 Descrição do Projeto

O OrbitGuard é uma API RESTful desenvolvida em ASP.NET Core 8 voltada para o monitoramento inteligente via satélites de riscos ambientais. A plataforma centraliza dados de sensores IoT distribuídos em regiões de risco, processa alertas em tempo real e coordena a resposta a emergências como enchentes, deslizamentos e eventos climáticos extremos.
A solução conecta três pilares fundamentais do gerenciamento de crises:

Monitoramento — sensores IoT coletam leituras contínuas de regiões monitoradas, alimentando um histórico de risco que embasa a emissão de alertas
Resposta — ocorrências são registradas e vinculadas a alertas ativos, permitindo rastreabilidade completa de cada evento
Proteção — abrigos de emergência têm capacidade e recursos gerenciados em tempo real, orientando o deslocamento seguro da população

A infraestrutura é implantada em nuvem Azure com dois containers Docker integrados: a API .NET e o banco Oracle XE, ambos orquestrados via Docker Compose com migrations automáticas, volume nomeado para persistência e execução com usuário sem privilégios administrativos.

**Stack de infraestrutura:**

| Camada | Tecnologia |
|---|---|
| Nuvem | Microsoft Azure (VM Ubuntu 24.04) |
| Provisionamento | Azure CLI |
| Containerização | Docker Engine + Docker Compose |
| Aplicação | ASP.NET Core 8 (.NET 8) |
| Banco de Dados | Oracle XE 21c (`gvenzl/oracle-xe`) |
| Documentação | Swagger |


## 💼 Benefícios para o Negócio

### 🔁 Reprodutibilidade total
O ambiente é definido como código — qualquer pessoa sobe a solução completa com poucos comandos, sem configuração manual.

### ⚡ Deploy rápido e padronizado
O script `prov_VM.sh` automatiza desde a criação da VM até a instalação do Docker e Git, reduzindo o tempo do trabalho manual para poucos minutos.

### 🛡️ Segurança por padrão
A aplicação roda com um **usuário sem privilégios administrativos** (`orbitguard`) dentro do container, seguindo o princípio do menor privilégio.

### 💾 Dados persistentes e seguros
O banco Oracle utiliza um **volume Docker nomeado** (`orbitguard-oracle-data`), garantindo que os dados sobrevivam a reinicializações e recriações de container.

### 📈 Alta disponibilidade
Todos os containers são configurados com `restart: unless-stopped`, garantindo recuperação automática após falhas.

### 🔍 Observabilidade
A API expõe o Swagger UI publicamente na porta 8080, permitindo testes funcionais externos imediatos.

### 🗄️ Migrations automáticas
O container de migrations garante que as tabelas do banco sejam criadas automaticamente na primeira execução, sem necessidade de intervenção manual.

---

## 🏗️ Arquitetura

![Arquitetura OrbitGuard](/Images/image.png)



## 📦 Repositórios Utilizados

A entrega de DevOps utiliza dois repositórios:

| Repositório | Descrição | Link |
|---|---|---|
| DevOps OrbitGuard | Repositório de infraestrutura contendo Dockerfile, Docker Compose, script Azure CLI, imagens e documentação da entrega DevOps. | `https://github.com/MatheusSousaAlmeida/devops-orbitguard` |
| OrbitGuard API | Repositório da aplicação ASP.NET Core 8 utilizada na entrega. Contém o código-fonte da API RESTful, entidades, controllers, Entity Framework Core e migrations. | `https://github.com/GabrielCabralmm/OrbitGuard-API` |

Durante o processo de implantação na VM Azure, o repositório da API .NET é clonado dentro do diretório `/opt/orbitguard`, onde são adicionados os arquivos de Docker necessários para executar a solução em containers.



## 🔗 Rotas da API

Todas as entidades seguem o padrão REST com os métodos `GET`, `GET /{id}`, `POST`, `PUT /{id}` e `DELETE /{id}`.

| Recurso | Rota base | Descrição |
|---|---|---|
| Usuário | `/api/Usuario` | Usuários do sistema |
| Região | `/api/Regiao` | Regiões monitoradas |
| Fonte Espacial | `/api/FonteEspacial` | Fontes de dados espaciais |
| Sensor IoT | `/api/SensorIot` | Sensores IoT cadastrados |
| Leitura | `/api/LeituraSensor` | Leituras dos sensores |
| Abrigo | `/api/Abrigo` | Abrigos de emergência |
| Recurso Abrigo | `/api/RecursoAbrigo` | Recursos disponíveis nos abrigos |
| Histórico de Risco | `/api/HistoricoRisco` | Histórico de riscos por região |
| Alerta | `/api/AlertaRisco` | Alertas de risco ambiental |
| Ocorrência | `/api/Ocorrencia` | Ocorrências registradas |
| Auditoria de Alerta | `/api/AuditoriaAlerta` | Auditoria de alterações em alertas |

### Exemplos de uso

```bash
# Criar um usuário
curl -X POST http://<IP>:8080/api/Usuario \
  -H "Content-Type: application/json" \
  -d '{"nome": "João Silva", "email": "joao@email.com", "perfil": "ADMIN", "telefone": "11999999999"}'

# Listar usuários
curl http://<IP>:8080/api/Usuario

# Criar uma região monitorada
curl -X POST http://<IP>:8080/api/Regiao \
  -H "Content-Type: application/json" \
  -d '{"nome": "Vale do Paraíba", "descricao": "Região de alto risco de enchente", "latitude": -22.9, "longitude": -45.5}'

# Deletar um usuário
curl -X DELETE http://<IP>:8080/api/Usuario/1
```

Documentação interativa completa:
```
http://<IP>:8080/swagger
```



## 🚀 Instalação — How To

### Pré-requisitos

- Conta Azure com Azure CLI instalado e autenticado (`az login`)
- Git instalado na máquina local

### Passo 1 — Clonar este repositório

```bash
git clone https://github.com/MatheusSousaAlmeida/devops-orbitguard
cd devops-orbitguard
```

### Passo 2 — Provisionar a VM no Azure

```bash
bash Script/prov_VM.sh
```

O script executa em sequência:
- **Tarefa 1** — Cria o Resource Group `rg-orbitguard` e a VM Ubuntu 24.04 em `canadacentral`
- **Tarefa 2** — Abre as portas 22, 80, 8080 e 1521 no NSG
- **Tarefa 3** — Instala o Docker Engine na VM e adiciona o usuário ao grupo docker
- **Tarefa 4** — Instala Git, nano, curl e demais ferramentas

Ao final exibe o **IP público e credenciais de acesso à VM**.

### Passo 3 — Conectar na VM via SSH

```bash
ssh azureuser@<IP_DA_VM>
```

### Passo 4 — Clonar o repositório da aplicação

```bash
cd /opt/orbitguard
git clone https://github.com/GabrielCabralmm/OrbitGuard-API .
```

### Passo 5 — Criar os arquivos Docker

```bash
# Criar o Dockerfile
vi /opt/orbitguard/Dockerfile
# (colar o conteúdo da seção Dockerfile abaixo)

# Criar o docker-compose.yml
vi /opt/orbitguard/docker-compose.yml
# (colar o conteúdo da seção Docker Compose abaixo)
```

### Passo 6 — Subir os containers

```bash
cd /opt/orbitguard
docker compose up -d --build
```

O Docker irá:
1. Compilar a imagem da API (.NET 8) via multi-stage build
2. Baixar a imagem do Oracle XE 21c
3. Rodar as migrations automaticamente via EF Core
4. Subir API + Oracle em background na rede `orbitguard-net`

### Passo 7 — Testar

Abra no navegador:
```
http://<IP_DA_VM>:8080/swagger
```

### Comandos úteis

```bash
# Ver status dos containers
docker compose ps

# Ver logs da API
docker logs -f rm563734-orbitguard-api

# Ver logs do Oracle
docker logs -f rm563734-orbitguard-oracle

# Verificar usuário sem privilégios na API
docker exec rm563734-orbitguard-api whoami

# Verificar diretório de trabalho da API
docker exec rm563734-orbitguard-api pwd

# Listar arquivos da API
docker exec rm563734-orbitguard-api ls -l



# Parar tudo
docker compose down

# Inspecionar volume
docker volume inspect orbitguard-oracle-data
```



## 🐳 Dockerfile

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY OrbitGuard/OrbitGuard.csproj OrbitGuard/
RUN dotnet restore OrbitGuard/OrbitGuard.csproj

COPY OrbitGuard/ OrbitGuard/
WORKDIR /src/OrbitGuard
RUN dotnet publish OrbitGuard.csproj -c Release -o /app/publish --no-restore


FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

RUN addgroup --system appgroup && adduser --system --ingroup appgroup orbitguard

COPY --from=build /app/publish .
RUN chown -R orbitguard:appgroup /app

USER orbitguard

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "OrbitGuard.dll"]
```



## 🐙 Docker Compose

```yml
services:

  oracle:
    image: gvenzl/oracle-xe:21-slim
    container_name: rm563734-orbitguard-oracle
    restart: unless-stopped
    environment:
      ORACLE_PASSWORD: Oracle123
      APP_USER: rm563230
      APP_USER_PASSWORD: 201106
    volumes:
      - orbitguard-oracle-data:/opt/oracle/oradata
    ports:
      - "1521:1521"
    networks:
      - orbitguard-net
    healthcheck:
      test: ["CMD-SHELL", "healthcheck.sh"]
      interval: 30s
      timeout: 10s
      retries: 10
      start_period: 120s

  migrations:
    image: mcr.microsoft.com/dotnet/sdk:8.0
    container_name: rm563734-orbitguard-migrations
    working_dir: /src/OrbitGuard
    volumes:
      - .:/src
    environment:
      ConnectionStrings__Oracle: "User Id=rm563230;Password=201106;Data Source=oracle:1521/XEPDB1;"
    command: >
      bash -c "dotnet tool install --global dotnet-ef &&
               export PATH=$$PATH:/root/.dotnet/tools &&
               dotnet restore &&
               dotnet ef database update"
    depends_on:
      oracle:
        condition: service_healthy
    networks:
      - orbitguard-net

  api:
    build:
      context: .
      dockerfile: Dockerfile
    image: orbitguard-api:latest
    container_name: rm563734-orbitguard-api
    restart: unless-stopped
    ports:
      - "8080:8080"
    environment:
      ASPNETCORE_ENVIRONMENT: Development
      ASPNETCORE_URLS: http://+:8080
      ConnectionStrings__Oracle: "User Id=rm563230;Password=201106;Data Source=oracle:1521/XEPDB1;"
    depends_on:
      migrations:
        condition: service_completed_successfully
    networks:
      - orbitguard-net

volumes:
  orbitguard-oracle-data:
    name: orbitguard-oracle-data
    driver: local

networks:
  orbitguard-net:
    driver: bridge
```


## 📁 Estrutura do Repositório

```
devops-orbitguard/
├── Docker/
│   ├── Dockerfile             ← Build multi-stage da API (.NET 8)
│   └── docker-compose.yml     ← Sobe API + Oracle XE + migrations
├── Images/
│   └── architecture.png       ← Diagrama de arquitetura macro
├── Script/
│   └── prov_VM.sh             ← Cria VM Azure, abre portas, instala Docker e Git
└── README.md
```


## 👨‍💻 Integrantes

| Nome | RM |
|---|---|
| Enzo Monteiro Maciel | RM563734 |
| Gabriel Cabral Mendes Mariano | RM563230 |
| Matheus de Almeida Sousa | RM563557 |
---
