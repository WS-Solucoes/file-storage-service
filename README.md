# Projeto WS-Services

Este é o repositório principal do projeto WS-Services, que atua como orquestrador para os diversos microsserviços da plataforma. Ele utiliza submódulos do Git para gerenciar as dependências dos subprojetos `common`, `eFrotas`, `eRH-Service` e `frontend-services`. A partir desta versão a arquitetura passa a contar com dois novos componentes compartilhados:

- **Service Discovery (`service-discovery`)** – servidor Eureka responsável por registrar e monitorar os microsserviços.
- **API Gateway (`api-gateway`)** – implementado com Spring Cloud Gateway, centraliza roteamento, CORS e verificação de tokens.

## Visão Geral

```
┌─────────────────────┐        ┌──────────────────┐
│  frontend-services  │  HTTP  │    API Gateway   │
└─────────────────────┘ ─────► │ (Spring Gateway) │
										 └───────┬──────────┘
													│ lb://
				  ┌────────────────────────┼───────────────────────────┐
				  ▼                        ▼                           ▼
		┌───────────────┐        ┌──────────────┐           ┌────────────────┐
		│ common-service│        │frotas-service│           │   erh-service  │
		└───────────────┘        └──────────────┘           └────────────────┘
					  ▲                      ▲                            ▲
					  │                      │                            │
					  └───────────────┬──────┴──────────────┬────────────┘
											▼                     ▼
									┌──────────────┐     ┌───────────────┐
									│ Service Disc.│     │ Banco(s) / etc│
									│   (Eureka)   │     └───────────────┘
									└──────────────┘
```

Cada microsserviço expõe metadados no Eureka e permanece autônomo. O gateway faz o roteamento por caminho:

| Caminho de entrada         | Serviço de destino   | Observação                              |
|----------------------------|----------------------|------------------------------------------|
| `/api/auth/**`             | `common-service`     | Autenticação/renovação de tokens         |
| `/frotas/**` (StripPrefix) | `frotas-service`     | Endpoints existentes sob `/api/v1/**`    |
| `/erh/**` (StripPrefix)    | `erh-service`        | Endpoints existentes sob `/api/v1/**`    |

## Pré-requisitos

Antes de começar, garanta que você tenha as seguintes ferramentas instaladas:

* [Git](https://git-scm.com/)
* [Java Development Kit (JDK) 21](https://www.oracle.com/java/technologies/downloads/)
* [Apache Maven](https://maven.apache.org/download.cgi)

## Como Configurar o Repositório

Este projeto depende de outros repositórios (submódulos). Use um dos métodos abaixo para clonar tudo corretamente.

### Método A – Clonar tudo de uma vez (recomendado)

```bash
git clone --recurse-submodules <URL_DO_REPOSITORIO_WS_SERVICES>
```

### Método B – Inicializar submódulos após o clone

```bash
git clone <URL_DO_REPOSITORIO_WS_SERVICES>
cd WS-Services
git submodule init
git submodule update --recursive
git submodule foreach "git checkout main"
git submodule foreach "git pull"
```

## Build e Execução dos Serviços

Com todos os submódulos disponíveis, compile e execute os componentes na ordem abaixo (cada comando deve ser executado em um terminal separado ou usando `-pl` conforme necessidade):

1. **Service Discovery (Eureka)**
	```bash
	mvn -pl service-discovery spring-boot:run
	```
2. **API Gateway**
	```bash
	mvn -pl api-gateway spring-boot:run
	```
3. **Microsserviços**
	```bash
	mvn -pl common,eFrotas,eRH-Service spring-boot:run
	```

Variáveis úteis para customização:

| Variável                        | Descrição                                      | Default                    |
|---------------------------------|------------------------------------------------|----------------------------|
| `EUREKA_SERVER_URL`            | URL do Eureka Server                           | `http://localhost:8761/eureka` |
| `COMMON_SERVER_PORT`           | Porta local do `common-service`                | `8081`                     |
| `EFROTAS_SERVER_PORT`          | Porta local do `frotas-service`                | `8082`                     |
| `ERH_SERVER_PORT`              | Porta local do `erh-service`                   | `8083`                     |
| `API_GATEWAY_PORT`             | Porta de exposição do gateway                  | `8080`                     |

Para compilar todos os artefatos sem executar:

```bash
mvn clean install
```

## Frontend (Next.js)

Configure o frontend para apontar ao gateway. As variáveis abaixo já possuem defaults, mas podem ser sobrescritas conforme ambiente:

```bash
NEXT_PUBLIC_GATEWAY_URL=http://localhost:8080
NEXT_PUBLIC_FROTAS_PREFIX=/frotas
NEXT_PUBLIC_AUTH_PREFIX=/api/auth
NEXT_PUBLIC_API_PREFIX=/api/v1
```

## Gerenciando Submódulos

Para manter os submódulos atualizados com as últimas versões de seus respectivos repositórios:

```bash
git submodule update --remote --merge
```