# SCC-CEASA Starter

Projeto Spring Boot (3.3.x) + Thymeleaf + JPA + Flyway para o **SCC (Sistema de Contas de Convênio)**.

## Requisitos
- Java 17
- PostgreSQL 17.x (ou compatível)
- Maven 3.9+

## Subir local
1. Crie o banco:
   ```sql
   CREATE DATABASE scc;
   ```

2. Ajuste credenciais em `src/main/resources/application.properties`
cp src/main/resources/application-example.properties src/main/resources/application.properties

3. Rode:
   ```bash
   mvn spring-boot:run
   ```

4. Acesse:
   - http://localhost:8080

## O que já vem pronto
- CRUD básico de **Unidade Administrativa**
  - `/cadastros/unidades`
- Templates base com Bootstrap
- Estrutura de pacotes para evoluir os demais domínios
- Pasta Flyway `db/migration` pronta

## Flyway V1..V12
Eu tentei copiar automaticamente as migrations (se os zips estiverem disponíveis no ambiente).
Se faltar alguma, copie seus `.sql` para:
`src/main/resources/db/migration/`

