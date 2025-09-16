# Projeto WS-Services

Este é o repositório principal do projeto WS-Services, que atua como um orquestrador para os diversos microsserviços da plataforma. Ele utiliza submódulos do Git para gerenciar as dependências de outros repositórios, como `eFrotas`, `eRH-Service`, `common` e `frontend-services`.

## Pré-requisitos

Antes de começar, garanta que você tenha as seguintes ferramentas instaladas:
* [Git](https://git-scm.com/)
* [Java Development Kit (JDK) 17 ou superior](https://www.oracle.com/java/technologies/downloads/)
* [Apache Maven](https://maven.apache.org/download.cgi)

## Como Configurar e Rodar o Projeto

Como este projeto depende de outros repositórios (submódulos), um `git clone` padrão não será suficiente. Siga os passos abaixo para configurar o ambiente corretamente.

### 1. Clonando o Repositório

Você tem duas opções para clonar o projeto e suas dependências.

#### Método A (Recomendado): Clonar tudo de uma vez

Este é o método mais simples e direto. Use a flag `--recurse-submodules` para clonar o repositório principal e inicializar todos os submódulos em um único comando.

```bash
git clone --recurse-submodules <URL_DO_REPOSITÓRIO_WS-SERVICES>
```

#### Método B (Alternativo): Se você já clonou sem os submódulos

Se você já executou um `git clone` normal, os diretórios dos submódulos (`eFrotas`, `eRH-Service`, etc.) estarão vazios. Para baixá-los, execute os seguintes comandos:

```bash
# 1. Inicializa os submódulos (registra os links do arquivo .gitmodules)
git submodule init

# 2. Baixa o conteúdo dos submódulos e de quaisquer submódulos aninhados
git submodule update --recursive
```

Ao final de qualquer um dos métodos, seu projeto estará com todo o código-fonte necessário.

### 2. Compilando e Executando a Aplicação

Com o código e os submódulos no lugar, você pode compilar e rodar o projeto usando o Maven.

```bash
# Navegue até a raiz do projeto WS-Services
cd WS-Services

# Execute o projeto (assumindo que seja um projeto Spring Boot)
mvn spring-boot:run
```

Para apenas compilar e gerar o pacote (`.jar`):
```bash
mvn clean install
```

## Gerenciando os Submódulos

Para manter os submódulos atualizados com as últimas versões de seus respectivos repositórios, você pode executar o seguinte comando a partir da raiz do `WS-Services`:

```bash
git submodule update --remote --merge
```