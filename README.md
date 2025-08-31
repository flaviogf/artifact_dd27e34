[![Coverage Status](https://coveralls.io/repos/github/flaviogf/artifact_dd27e34/badge.svg?branch=chore/add-coverage)](https://coveralls.io/github/flaviogf/artifact_dd27e34?branch=chore/add-coverage)

# 📦 artifact_dd27e34

Sistema desenvolvido para processar arquivos de pedidos do sistema legado, normalizar os dados e disponibilizá-los via **API REST** com suporte a filtros.

---

## 🚀 **Objetivo**

Receber um arquivo desnormalizado via **API REST**, processá-lo e disponibilizar um **JSON normalizado** dos pedidos, com suporte a filtros de **ID de pedido** e **intervalo de datas**.

---

## 🛠 **Tecnologias Utilizadas**

- **Linguagem**: [Ruby 3.4.5](https://www.ruby-lang.org/)
- **Framework**: [Ruby on Rails 8.0.2.1](https://rubyonrails.org/)
- **Banco de dados**: [PostgreSQL](https://www.postgresql.org/)
- **Testes**: [RSpec](https://rspec.info/)
- **Cobertura de testes**: [SimpleCov](https://github.com/simplecov-ruby/simplecov)
- **Documentação da API**: [Rswag](https://github.com/rswag/rswag)
- **Gerenciamento de dependências**: [Bundler](https://bundler.io/)
- **Containerização**: [Docker 28.3.3](https://www.docker.com/)
- **Orquestração de containers**: [Docker Compose 2.39.2](https://docs.docker.com/compose/)

## ⚙️ Como Rodar o Projeto

### 1. Clone o repositório

```bash
git clone git@github.com:seu-usuario/artifact_dd27e34.git
cd artifact_dd27e34
```

### 2. Faça o build da aplicação

```bash
docker compose build
```

### 3. Rode a aplicação

```bash
docker compose up -d
```

A aplicação estará disponível em:

http://localhost:3000/api-docs

http://localhost:3000/sidekiq

## 🧪 Rodando os Testes

### 1. Clone o repositório

```bash
git clone git@github.com:seu-usuario/artifact_dd27e34.git
cd artifact_dd27e34
```

### 2. Faça o build da aplicação

```bash
docker compose build
```

### 3. Rode o container de teste

```bash
docker compose run --rm test
```
