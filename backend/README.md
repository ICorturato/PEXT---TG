# PEXT API

REST API versionada em `/api/v1`, construída com Node.js e módulos nativos para
que possa rodar no projeto atual sem uma cadeia extra de dependências. A camada
`Store` persiste em JSON local durante o desenvolvimento e concentra o contrato
que deve ser trocado por PostgreSQL/pgvector e S3/MinIO no ambiente produtivo.

## Executar

```bash
cd backend
node src/server.js
```

## Connect the Flutter app

Start this API before launching Flutter. For physical Android devices connected
by USB, the debug build can target `http://127.0.0.1:3000/api/v1` after running:

```powershell
C:\platform-tools\adb.exe reverse tcp:3000 tcp:3000
```

For a physical device on Wi-Fi, use the project launcher. It detects the
computer's current Wi-Fi address, starts the API when required, and passes the
correct endpoint to Flutter:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-wifi-dev.ps1
```

Run this once from an Administrator PowerShell to allow the phone to reach the
API through Windows Firewall:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\enable-wifi-api-firewall.ps1
```

For an Android emulator, Windows, web, iOS, or a physical device on Wi-Fi, you
can also provide the reachable API address manually when launching Flutter:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1
```

For a physical Android device on Wi-Fi, replace `127.0.0.1` with the computer's LAN IP.
The app authenticates with the API and synchronizes packaging, problems, and
operator diagnostic submissions after login.

Variáveis disponíveis:

```bash
PORT=3000
JWT_SECRET=uma-chave-longa-e-segura
DATA_FILE=./data/pext.json
```

Usuários iniciais de desenvolvimento:

| Papel | E-mail | Senha |
| --- | --- | --- |
| ADMIN | `admin@pext.local` | `admin123` |
| USER | `operador@pext.local` | `operador123` |

## Segurança e RBAC

`POST /auth/login` retorna um JWT HMAC-SHA256. Envie-o como
`Authorization: Bearer <token>`. Escritas em catálogo, cursos, embalagens,
problemas, usuários e documentos exigem `ADMIN`; o restante opera com o usuário
autenticado.

## Módulos

- `auth`, `profile`, `admin/users`
- `resins`, `terms`, `trainings`, `favorites`
- `packagings` e `packagings/:id/parameters`
- `problems/diagnose` e `problems/supervisor-request`
- `dashboards/overview`
- `admin/documents` e `chat/query`

## RAG estrito

O administrador envia documentos textuais pelo endpoint
`POST /api/v1/admin/documents`, com `documentName`, `text` e `page` opcionais.
O serviço cria trechos com sobreposição e recupera os de maior correspondência
para `POST /api/v1/chat/query`. Sem trechos relevantes, a API retorna apenas:

`Não encontrei essa informação nos manuais e documentos cadastrados no sistema.`

Para produção, implemente o adaptador de embeddings e substitua a busca lexical
por pgvector, Qdrant ou Chroma; mantenha a mesma resposta de fontes para que o
Flutter continue exibindo citações auditáveis.
