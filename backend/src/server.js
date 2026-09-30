import { createServer } from 'node:http';
import { createHmac, randomUUID, scryptSync, timingSafeEqual } from 'node:crypto';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { basename, dirname, extname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
try { process.loadEnvFile(join(__dirname, '..', '.env')); } catch {}
try { process.loadEnvFile(); } catch {}
const PORT = Number(process.env.PORT || 3000);
const JWT_SECRET = process.env.JWT_SECRET || 'change-this-development-secret';
const DATA_FILE = process.env.DATA_FILE || join(__dirname, '..', 'data', 'pext.json');
const UPLOADS_DIR = process.env.UPLOADS_DIR || join(__dirname, '..', 'uploads');
const notFoundAnswer = 'Não encontrei essa informação nos manuais e documentos cadastrados no sistema.';

const emptyData = () => ({
  users: [], resins: [], terms: [], trainings: [], progress: [], packagings: [],
  problems: [], categories: [], favorites: [], diagnosticLogs: [], documents: [], chunks: [],
  contents: [], doubts: [],
});

class Store {
  constructor(file = DATA_FILE) { this.file = file; this.data = emptyData(); }
  async load() {
    try { this.data = { ...emptyData(), ...JSON.parse(await readFile(this.file, 'utf8')) }; }
    catch { await this.seed(); }
    if (!this.data.users.length) await this.seed();
    if (!this.data.contents) this.data.contents = [];
    if (!this.data.doubts) this.data.doubts = [];
    if (!this.data.contents.length) { this.seedContents(); await this.save(); }
    if (!this.data.doubts.length) { this.seedDoubts(); await this.save(); }
    if (!this.data.categories.length) {
      this.data.categories.push(
        category('Polymers', 'RESIN'),
        category('Processes', 'TRAINING'),
        category('Extrusion', 'TERMS'),
        category('Quality', 'PROBLEM'),
        category('Extrusão Geral', 'CONTENT'),
      );
      await this.save();
    }
  }
  async save() { await mkdir(dirname(this.file), { recursive: true }); await writeFile(this.file, JSON.stringify(this.data, null, 2)); }
  seedContents() {
    const c1Id = randomUUID();
    this.data.contents.push({
      id: c1Id,
      title: 'Material irregular na matriz',
      text: 'Quando identificado material irregular na matriz, realizar a inspeção da peça e verificar se a ocorrência compromete o padrão de qualidade estabelecido. Caso seja constatada irregularidade, separar a peça e encaminhá-la para avaliação.',
      categoryId: null,
      categoryName: 'Extrusão',
      documentName: 'Ficha Técnica.pdf',
      documentUrl: '/uploads/sample_spec.pdf',
      documentSize: 'PDF - 1,2 MB',
      authorName: 'André',
      authorId: this.data.users[0]?.id || null,
      status: 'ATIVO',
      createdAt: '2026-08-01T09:33:00.000Z',
      updatedAt: '2026-08-05T09:43:00.000Z',
      history: [
        {
          id: randomUUID(),
          authorName: 'André',
          authorRole: 'ADMIN',
          action: 'CREATE',
          date: '01/08/2026 - 09:33',
          title: 'André criou este conteúdo.',
          description: 'Conteúdo inicial adicionado.',
          previousContent: null
        },
        {
          id: randomUUID(),
          authorName: 'Maria',
          authorRole: 'ADMIN',
          action: 'UPDATE',
          date: '02/08/2026 - 09:43',
          title: 'Maria editou o conteúdo',
          description: 'Alterações:\n- Inclusão de Documento',
          previousContent: {
            title: 'Material irregular na matriz',
            text: 'Quando identificado material irregular na matriz, realizar a inspeção da peça e verificar se a ocorrência compromete o padrão de qualidade estabelecido. Caso seja constatada irregularidade, separar a peça e encaminhá-la para avaliação.',
            documentName: null,
            documentUrl: null,
            documentSize: null,
            date: '02/08/2026 - 09:40'
          }
        },
        {
          id: randomUUID(),
          authorName: 'Jorge',
          authorRole: 'ADMIN',
          action: 'UPDATE',
          date: '05/08/2026 - 09:43',
          title: 'Jorge editou o conteúdo',
          description: 'Alterações:\n- Removeu um documento',
          previousContent: {
            title: 'Material irregular na matriz',
            text: 'Quando identificado material irregular na matriz, a peça deve ser imediatamente segregada e registrada como não conforme. A ocorrência deve ser avaliada conforme o padrão de qualidade vigente.',
            documentName: 'Ficha Técnica.pdf',
            documentUrl: '/uploads/sample_spec.pdf',
            documentSize: 'PDF - 1,2 MB',
            date: '05/08/2026 - 09:35'
          }
        }
      ]
    });
    // Add chunks for retrieval
    this.data.chunks.push({
      id: randomUUID(),
      documentId: c1Id,
      text: 'Material irregular na matriz: Quando identificado material irregular na matriz, realizar a inspeção da peça e verificar se a ocorrência compromete o padrão de qualidade estabelecido. Caso seja constatada irregularidade, separar a peça e encaminhá-la para avaliação.',
      page: 1,
      tokens: tokenSet('Material irregular na matriz inspeção da peça padrão de qualidade regular')
    });
  }
  seedDoubts() {
    const userId = this.data.users[1]?.id || randomUUID();
    const adminId = this.data.users[0]?.id || randomUUID();
    this.data.doubts.push(
      {
        id: randomUUID(),
        userId,
        userName: 'Igor Teixeira Corturato',
        userAvatarUrl: 'images/profile_igor.png',
        question: 'O que pode fazer o material sair da matriz de forma irregular',
        status: 'RESPONDIDO',
        createdAt: '2026-08-08T10:00:00.000Z',
        messages: [
          {
            id: randomUUID(),
            senderId: userId,
            senderName: 'Igor Teixeira Corturato',
            senderRole: 'USER',
            text: 'O que pode fazer o material sair da matriz de forma irregular',
            avatarUrl: 'images/profile_igor.png',
            createdAt: '2026-08-08T10:00:00.000Z'
          },
          {
            id: randomUUID(),
            senderId: adminId,
            senderName: 'Administrador PEXT',
            senderRole: 'ADMIN',
            text: 'Consulte a ficha técnica. Para um ajuste específico de linha, posso encaminhar a solicitação para o supervisor ou verificar a regulagem dos resistores.',
            avatarUrl: 'images/profile_igor.png',
            createdAt: '2026-08-08T10:15:00.000Z'
          }
        ]
      },
      {
        id: randomUUID(),
        userId,
        userName: 'Igor Teixeira Corturato',
        userAvatarUrl: 'images/profile_igor.png',
        question: 'Como regular o anel de ar para evitar espessura irregular no balão?',
        status: 'NAO_RESPONDIDO',
        createdAt: '2026-08-08T11:20:00.000Z',
        messages: [
          {
            id: randomUUID(),
            senderId: userId,
            senderName: 'Igor Teixeira Corturato',
            senderRole: 'USER',
            text: 'Como regular o anel de ar para evitar espessura irregular no balão?',
            avatarUrl: 'images/profile_igor.png',
            createdAt: '2026-08-08T11:20:00.000Z'
          }
        ]
      }
    );
  }
  async seed() {
    this.data = emptyData();
    this.data.users.push(
      user('Administrador PEXT', 'admin@pext.local', 'admin123', 'ADMIN'),
      user('Operador PEXT', 'operador@pext.local', 'operador123', 'USER'),
    );
    this.data.packagings.push({
      id: randomUUID(), name: 'RAP10', category: 'Filme plástico', imageUrl: null,
      parameters: defaultParameters(), createdAt: new Date().toISOString(),
    });
    this.data.problems.push({
      id: randomUUID(), title: 'Variação na espessura',
      description: 'O produto sai com espessura irregular ou fora do especificado.',
      category: 'Extrusão', iconName: 'tune',
      causeDescription: 'Instabilidade nos parâmetros da linha.',
      recommendedSolution: 'Verifique os parâmetros da embalagem, ajuste gradualmente e monitore a estabilidade.',
    });
    this.data.categories.push(
      category('Polymers', 'RESIN'),
      category('Processes', 'TRAINING'),
      category('Extrusion', 'TERMS'),
      category('Quality', 'PROBLEM'),
      category('Extrusão Geral', 'CONTENT'),
    );
    this.seedContents();
    this.seedDoubts();
    await this.save();
  }
}
function category(name, scope, imageUrl = null, iconKey = null) { return { id: randomUUID(), name, scope, imageUrl: imageUrl || null, iconKey: iconKey || null, createdAt: new Date().toISOString() }; }

function user(name, email, password, role, phone = null, address = null, jobTitle = null) {
  const salt = randomUUID();
  return {
    id: randomUUID(),
    name,
    email: email.toLowerCase(),
    role,
    salt,
    phone: phone || '(11) 98765-4321',
    address: address || 'São Paulo - SP',
    jobTitle: jobTitle || (role === 'ADMIN' ? 'Administrador Industrial' : 'Operador de Extrusão'),
    avatarUrl: 'images/profile_igor.png',
    passwordHash: hash(password, salt),
    createdAt: new Date().toISOString()
  };
}
function defaultParameters() {
  return [
    parameter('Temperatura do cilindro', '°C', 160, 180, 'FIXED'),
    parameter('Velocidade da linha', 'm/min', 20, 35, 'FIXED'),
    parameter('Pressão do sistema', 'bar', 70, 90, 'FIXED'),
    parameter('Abertura da matriz', 'mm', 0.04, 0.06, 'FIXED'),
  ];
}
function parameter(name, unit, minValue, maxValue, type = 'EXTRA', isEnabled = true) {
  return { id: randomUUID(), name, unit, minValue: Number(minValue), maxValue: Number(maxValue), type, isEnabled };
}
function hash(password, salt) { return scryptSync(password, salt, 64).toString('hex'); }
function sign(payload) {
  const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url');
  const body = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const signature = createHmac('sha256', JWT_SECRET).update(`${header}.${body}`).digest('base64url');
  return `${header}.${body}.${signature}`;
}
function verify(token) {
  const [header, body, signature] = token?.split('.') || [];
  if (!header || !body || !signature) return null;
  const expected = createHmac('sha256', JWT_SECRET).update(`${header}.${body}`).digest('base64url');
  if (signature.length !== expected.length || !timingSafeEqual(Buffer.from(signature), Buffer.from(expected))) return null;
  const payload = JSON.parse(Buffer.from(body, 'base64url').toString('utf8'));
  return payload.exp > Math.floor(Date.now() / 1000) ? payload : null;
}

const store = new Store();
const json = (res, status, body) => {
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8', 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'Authorization, Content-Type', 'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS' });
  res.end(JSON.stringify(body));
};
const noContent = (res) => { res.writeHead(204, cors()); res.end(); };
const cors = () => ({ 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': 'Authorization, Content-Type', 'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS' });
async function body(req) {
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  if (!chunks.length) return {};
  try { return JSON.parse(Buffer.concat(chunks).toString('utf8')); }
  catch { throw new ApiError(400, 'JSON inválido.'); }
}
async function multipart(req) {
  const contentType = req.headers['content-type'] || '';
  const match = contentType.match(/boundary=(?:"([^"]+)"|([^;\s]+))/i);
  if (!match) throw new ApiError(400, 'Envie um formulário multipart válido.');
  const chunks = [];
  for await (const chunk of req) chunks.push(chunk);
  const buffer = Buffer.concat(chunks);
  if (buffer.length > 10 * 1024 * 1024) throw new ApiError(413, 'O arquivo deve ter no máximo 10 MB.');
  const boundary = Buffer.from(`--${match[1] || match[2]}`);
  const parts = [];
  let cursor = 0;
  while (cursor < buffer.length) {
    const start = buffer.indexOf(boundary, cursor);
    if (start < 0) break;
    const next = buffer.indexOf(boundary, start + boundary.length);
    if (next < 0) break;
    const section = buffer.subarray(start + boundary.length + 2, next - 2);
    const split = section.indexOf(Buffer.from('\r\n\r\n'));
    if (split >= 0) {
      const headers = section.subarray(0, split).toString('utf8');
      const content = section.subarray(split + 4);
      const disposition = headers.match(/name="([^"]+)"/i);
      const filename = headers.match(/filename="([^"]*)"/i);
      if (disposition) {
        parts.push({
          name: disposition[1],
          filename: filename?.[1] || null,
          contentType: headers.match(/Content-Type:\s*([^\r\n]+)/i)?.[1] || 'application/octet-stream',
          content,
        });
      }
    }
    cursor = next;
  }
  return parts;
}
function auth(req, roles = []) {
  const token = req.headers.authorization?.replace(/^Bearer\s+/i, '');
  const payload = verify(token);
  if (!payload) throw new ApiError(401, 'Token ausente, inválido ou expirado.');
  const currentUser = store.data.users.find((item) => item.id === payload.sub);
  if (!currentUser) throw new ApiError(401, 'Usuário não encontrado.');
  if (roles.length && !roles.includes(currentUser.role)) throw new ApiError(403, 'Permissão insuficiente.');
  return currentUser;
}
class ApiError extends Error { constructor(status, message) { super(message); this.status = status; } }
function idFrom(parts, index) { return parts[index] || null; }
function find(collection, id, label = 'Registro') {
  const item = collection.find((entry) => entry.id === id);
  if (!item) throw new ApiError(404, `${label} não encontrado.`);
  return item;
}
function publicUser(item) { const { passwordHash, salt, ...safe } = item; return safe; }
function paginate(items, url) {
  const page = Math.max(1, Number(url.searchParams.get('page') || 1));
  const pageSize = Math.min(100, Math.max(1, Number(url.searchParams.get('pageSize') || 20)));
  return { items: items.slice((page - 1) * pageSize, page * pageSize), page, pageSize, total: items.length };
}
function normalizeParameters(values = []) {
  if (!Array.isArray(values)) return [];
  return values.map((item) => parameter(item.name?.trim() || '', item.unit?.trim() || '', item.minValue, item.maxValue, item.type === 'FIXED' ? 'FIXED' : 'EXTRA', item.isEnabled !== false));
}
function chunksFor(document) {
  const source = document.text || '';
  const chunkSize = 2000;
  const overlap = 400;
  const output = [];
  for (let start = 0; start < source.length; start += chunkSize - overlap) {
    const text = source.slice(start, start + chunkSize).trim();
    if (!text) continue;
    output.push({ id: randomUUID(), documentId: document.id, text, page: document.page || 1, tokens: tokenSet(text) });
  }
  return output;
}
function tokenSet(text) { return [...new Set((text.toLowerCase().match(/[\p{L}\p{N}]{3,}/gu) || []))]; }
function retrieve(query) {
  const queryTerms = tokenSet(query);
  return store.data.chunks.map((chunk) => ({ chunk, score: chunk.tokens.reduce((sum, term) => sum + (queryTerms.includes(term) ? 1 : 0), 0) / Math.max(1, Math.sqrt(chunk.tokens.length * queryTerms.length)) })).filter((entry) => entry.score > 0).sort((a, b) => b.score - a.score).slice(0, 4);
}
function diagnosis(problem, packaging, inputValues, operatorId) {
  const failures = packaging.parameters.filter((item) => item.isEnabled !== false).flatMap((parameter) => {
    const value = Number(inputValues?.[parameter.id] ?? inputValues?.[parameter.name]);
    if (!Number.isFinite(value)) return [];
    const state = value < parameter.minValue ? 'BELOW' : value > parameter.maxValue ? 'ABOVE' : 'WITHIN';
    return [{ parameterId: parameter.id, parameter: parameter.name, value, unit: parameter.unit, minValue: parameter.minValue, maxValue: parameter.maxValue, state }];
  });
  const log = { id: randomUUID(), operatorId, packagingId: packaging.id, problemId: problem.id, inputValues, failures, status: 'OPEN', createdAt: new Date().toISOString() };
  store.data.diagnosticLogs.push(log);
  return { log, failures: failures.filter((item) => item.state !== 'WITHIN'), recommendedSolution: problem.recommendedSolution };
}

async function route(req, res) {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const path = url.pathname.replace(/^\/api\/v1/, '');
  const parts = path.split('/').filter(Boolean);
  if (req.method === 'OPTIONS') return noContent(res);
  if (url.pathname === '/health') return json(res, 200, { status: 'ok' });
  if (url.pathname.startsWith('/uploads/')) return serveUpload(res, url.pathname);
  if (!url.pathname.startsWith('/api/v1/')) throw new ApiError(404, 'Rota não encontrada.');

  if (req.method === 'POST' && path === '/auth/login') {
    const input = await body(req); const account = store.data.users.find((item) => item.email === String(input.email || '').toLowerCase());
    if (!account || hash(String(input.password || ''), account.salt) !== account.passwordHash) throw new ApiError(401, 'E-mail ou senha inválidos.');
    const token = sign({ sub: account.id, role: account.role, exp: Math.floor(Date.now() / 1000) + 60 * 60 * 8 });
    return json(res, 200, { token, user: publicUser(account) });
  }

  if (path === '/profile/me') {
    const current = auth(req);
    if (req.method === 'GET') return json(res, 200, publicUser(current));
    if (req.method === 'PUT') { Object.assign(current, pick(await body(req), ['name', 'phone', 'avatarUrl', 'cargo'])); await store.save(); return json(res, 200, publicUser(current)); }
  }
  if (path === '/profile/avatar' && req.method === 'POST') {
    const current = auth(req);
    const parts = await multipart(req);
    const file = parts.find((part) => (part.name === 'file' || part.name === 'avatar') && part.filename);
    if (!file) throw new ApiError(400, 'Nenhum arquivo enviado.');
    const extension = extname(file.filename).toLowerCase();
    if (!['.png', '.jpg', '.jpeg', '.webp'].includes(extension)) {
      throw new ApiError(422, 'Envie uma imagem válida (.png, .jpg, .jpeg, .webp).');
    }
    const filename = `${randomUUID()}${extension}`;
    await mkdir(UPLOADS_DIR, { recursive: true });
    await writeFile(join(UPLOADS_DIR, filename), file.content);
    current.avatarUrl = `/uploads/${filename}`;
    await store.save();
    return json(res, 200, { avatarUrl: current.avatarUrl, user: publicUser(current) });
  }
  if (path === '/admin/users' || path === '/users') {
    if (req.method === 'GET') {
      auth(req, ['ADMIN']);
      return json(res, 200, paginate(store.data.users.map(publicUser), url));
    }
    if (req.method === 'POST') {
      auth(req, ['ADMIN']);
      const input = await body(req);
      if (!input.name || !input.email || !input.password) {
        throw new ApiError(400, 'Nome, e-mail e senha são obrigatórios.');
      }
      const emailLower = String(input.email).toLowerCase().trim();
      if (store.data.users.some((u) => u.email === emailLower)) {
        throw new ApiError(409, 'Já existe um usuário cadastrado com este e-mail.');
      }
      const role = input.role === 'ADMIN' ? 'ADMIN' : 'USER';
      const newUser = user(input.name.trim(), emailLower, String(input.password), role);
      if (input.cargo) newUser.cargo = input.cargo.trim();
      store.data.users.push(newUser);
      await store.save();
      return json(res, 201, publicUser(newUser));
    }
  }

  if (parts[0] === 'media') return mediaRoutes(req, res);
  if (parts[0] === 'categories') return categoryRoutes(req, res, url, parts);
  if (parts[0] === 'resins') return crud(req, res, url, store.data.resins, 'Resina', ['code', 'fullName', 'technicalName', 'overview', 'properties', 'technicalData', 'observations', 'productionProcesses', 'applications', 'imagePath', 'documents', 'videos', 'categoryId', 'name', 'acronym', 'description', 'productionProcess', 'imageUrl', 'categoryName', 'subcategoryId', 'subcategoryName', 'mainCharacteristics'], 'RESIN');
  if (parts[0] === 'terms') return crud(req, res, url, store.data.terms, 'Termo', ['term', 'description', 'topics', 'relatedTerms', 'imagePath', 'categoryId'], 'TERMS');
  if (parts[0] === 'trainings') return trainingRoutes(req, res, url, parts);
  if (parts[0] === 'packagings') return packagingRoutes(req, res, url, parts);
  if (parts[0] === 'problems') return problemRoutes(req, res, url, parts);
  if (parts[0] === 'contents') return contentRoutes(req, res, url, parts);
  if (parts[0] === 'doubts') return doubtRoutes(req, res, url, parts);
  if (parts[0] === 'support' && parts[1] === 'tickets') return doubtRoutes(req, res, url, ['doubts', ...parts.slice(2)]);
  if (parts[0] === 'favorites') return favoriteRoutes(req, res, url);
  if (parts[0] === 'analytics') return analyticsRoutes(req, res, url, parts);
  if (parts[0] === 'dashboards' || parts[0] === 'dashboard') return dashboardRoutes(req, res, url, parts);
  if (parts[0] === 'admin' && parts[1] === 'users') return adminUserRoutes(req, res, url, parts);
  if (parts[0] === 'admin' && parts[1] === 'documents') return documentRoutes(req, res, url, parts);
  if (parts[0] === 'chat') return chatRoute(req, res, url, parts);
  throw new ApiError(404, 'Rota não encontrada.');
}

async function crud(req, res, url, collection, label, fields, categoryScope = null) {
  const id = url.pathname.split('/').filter(Boolean).at(-1);
  const isCollection = url.pathname.split('/').filter(Boolean).length === 3;
  if (req.method === 'GET' && isCollection) { auth(req); const query = url.searchParams.get('q')?.toLowerCase(); const values = query ? collection.filter((item) => JSON.stringify(item).toLowerCase().includes(query)) : collection; return json(res, 200, paginate(values, url)); }
  if (req.method === 'GET') { auth(req); return json(res, 200, find(collection, id, label)); }
  auth(req, ['ADMIN']);
  if (req.method === 'POST' && isCollection) { const input = await body(req); validateCategory(input.categoryId, categoryScope); const item = { id: randomUUID(), ...pick(input, fields), createdAt: new Date().toISOString() }; collection.push(item); await store.save(); return json(res, 201, item); }
  const item = find(collection, id, label);
  if (req.method === 'PUT') { const input = await body(req); validateCategory(input.categoryId, categoryScope); Object.assign(item, pick(input, fields), { updatedAt: new Date().toISOString() }); await store.save(); return json(res, 200, item); }
  if (req.method === 'DELETE') { collection.splice(collection.indexOf(item), 1); await store.save(); return noContent(res); }
  throw new ApiError(405, 'Método não permitido.');
}
function pick(source, keys) { return Object.fromEntries(keys.filter((key) => source[key] !== undefined).map((key) => [key, source[key]])); }
function validateCategory(categoryId, scope) {
  if (categoryId === undefined || categoryId === null || categoryId === '') return;
  const value = find(store.data.categories, categoryId, 'Categoria');
  if (scope && value.scope !== scope) throw new ApiError(422, 'A categoria não pertence a este tipo de conteúdo.');
}

async function mediaRoutes(req, res) {
  auth(req, ['ADMIN']);
  if (req.method !== 'POST') throw new ApiError(405, 'Método não permitido.');
  const file = (await multipart(req)).find((part) => part.name === 'file' && part.filename);
  if (!file) throw new ApiError(422, 'Selecione um arquivo para enviar.');
  const extension = extname(basename(file.filename)).toLowerCase() || '.jpg';
  const allowedExtensions = new Set(['.png', '.jpg', '.jpeg', '.pdf', '.mp4', '.mov', '.m4v']);
  const allowedContentTypes = new Set(['image/png', 'image/jpeg', 'image/jpg', 'application/pdf', 'video/mp4', 'video/quicktime', 'video/x-m4v']);
  const contentType = file.contentType.split(';', 1)[0].trim().toLowerCase();
  if (!allowedExtensions.has(extension) || !allowedContentTypes.has(contentType)) {
    throw new ApiError(422, 'Envie uma imagem PNG/JPG, um PDF ou um vídeo MP4/MOV válido.');
  }
  const filename = `${randomUUID()}${extension}`;
  await mkdir(UPLOADS_DIR, { recursive: true });
  await writeFile(join(UPLOADS_DIR, filename), file.content);
  return json(res, 201, { url: `/uploads/${filename}`, filename, contentType: file.contentType, size: file.content.length });
}
async function serveUpload(res, requestPath) {
  const filename = basename(requestPath);
  if (!filename || filename !== requestPath.split('/').pop()) throw new ApiError(404, 'Arquivo não encontrado.');
  try {
    const content = await readFile(join(UPLOADS_DIR, filename));
    const extension = extname(filename).toLowerCase();
    const type = extension === '.png' ? 'image/png'
      : extension === '.pdf' ? 'application/pdf'
      : extension === '.mp4' ? 'video/mp4'
      : extension === '.mov' ? 'video/quicktime'
      : extension === '.m4v' ? 'video/x-m4v'
      : extension === '.webp' ? 'image/webp' : 'image/jpeg';
    res.writeHead(200, { 'Content-Type': type, 'Access-Control-Allow-Origin': '*' });
    res.end(content);
  } catch { throw new ApiError(404, 'Arquivo não encontrado.'); }
}
async function categoryRoutes(req, res, url, parts) {
  const id = idFrom(parts, 1);
  if (req.method === 'GET' && !id) {
    auth(req);
    const scope = url.searchParams.get('scope');
    const values = scope ? store.data.categories.filter((item) => item.scope === scope) : store.data.categories;
    return json(res, 200, paginate(values, url));
  }
  auth(req, ['ADMIN']);
  if (req.method === 'POST' && !id) {
    const input = await body(req); const scope = String(input.scope || '');
    if (!['RESIN', 'TRAINING', 'TERMS', 'PROBLEM', 'CONTENT', 'PACKAGING'].includes(scope) || !String(input.name || '').trim()) throw new ApiError(422, 'Nome e tipo da categoria são obrigatórios.');
    const created = category(String(input.name).trim(), scope, input.imageUrl, input.iconKey); store.data.categories.push(created); await store.save(); return json(res, 201, created);
  }
  const item = find(store.data.categories, id, 'Categoria');
  if (req.method === 'PUT') {
    const input = await body(req);
    if (!String(input.name || '').trim()) throw new ApiError(422, 'O nome da categoria é obrigatório.');
    item.name = String(input.name).trim();
    if (input.imageUrl !== undefined) item.imageUrl = input.imageUrl;
    if (input.iconKey !== undefined) item.iconKey = input.iconKey;
    item.updatedAt = new Date().toISOString();
    await store.save();
    return json(res, 200, item);
  }
  if (req.method === 'DELETE') {
    const used = [store.data.resins, store.data.terms, store.data.trainings, store.data.problems, store.data.contents || [], store.data.packagings || []].some((values) => values.some((value) => value.categoryId === item.id));
    if (used) throw new ApiError(409, 'Esta categoria está em uso e não pode ser excluída.');
    store.data.categories.splice(store.data.categories.indexOf(item), 1); await store.save(); return noContent(res);
  }
  throw new ApiError(405, 'Método não permitido.');
}

async function trainingRoutes(req, res, url, parts) {
  const id = idFrom(parts, 1);
  if (req.method === 'GET' && !id) {
    const current = auth(req);
    const values = store.data.trainings.map((training) => {
      const userProgress = store.data.progress.find((entry) => entry.userId === current.id && entry.trainingId === training.id) || null;
      const isEnrolled = !!userProgress && userProgress.status !== 'DROPPED';
      const modules = (training.modules || []).map((m) => ({
        ...m,
        isCompleted: userProgress?.completedModuleIds?.includes(m.id) || !!m.isCompleted,
      }));
      return {
        ...training,
        modules,
        progress: userProgress,
        isEnrolled: training.isDefaultForAllUsers || isEnrolled,
        enrollmentStatus: userProgress ? userProgress.status : (training.isDefaultForAllUsers ? 'EM_CURSO' : 'NAO_INICIADO'),
      };
    });
    return json(res, 200, paginate(values, url));
  }
  if (req.method === 'GET' && id && parts.length === 2) {
    const current = auth(req);
    const training = find(store.data.trainings, id, 'Treinamento');
    const userProgress = store.data.progress.find((entry) => entry.userId === current.id && entry.trainingId === training.id) || null;
    const isEnrolled = !!userProgress && userProgress.status !== 'DROPPED';
    const modules = (training.modules || []).map((m) => ({
      ...m,
      isCompleted: userProgress?.completedModuleIds?.includes(m.id) || !!m.isCompleted,
    }));
    return json(res, 200, {
      ...training,
      modules,
      progress: userProgress,
      isEnrolled: training.isDefaultForAllUsers || isEnrolled,
      enrollmentStatus: userProgress ? userProgress.status : (training.isDefaultForAllUsers ? 'EM_CURSO' : 'NAO_INICIADO'),
    });
  }

  if (req.method === 'POST' && id && parts[2] === 'enroll') {
    const current = auth(req);
    find(store.data.trainings, id, 'Treinamento');
    let entry = store.data.progress.find((item) => item.userId === current.id && item.trainingId === id);
    if (!entry) {
      entry = {
        id: randomUUID(),
        userId: current.id,
        trainingId: id,
        completedModuleIds: [],
        progressPercentage: 0,
        status: 'EM_CURSO',
        scorePercentage: null,
        droppedAt: null,
        updatedAt: new Date().toISOString()
      };
      store.data.progress.push(entry);
    } else {
      entry.status = 'EM_CURSO';
      entry.droppedAt = null;
      entry.updatedAt = new Date().toISOString();
    }
    await store.save();
    return json(res, 200, entry);
  }

  if (req.method === 'DELETE' && id && parts[2] === 'unenroll') {
    const current = auth(req);
    find(store.data.trainings, id, 'Treinamento');
    let entry = store.data.progress.find((item) => item.userId === current.id && item.trainingId === id);
    if (entry) {
      entry.status = 'DROPPED';
      entry.droppedAt = new Date().toISOString();
      entry.updatedAt = new Date().toISOString();
    } else {
      entry = {
        id: randomUUID(),
        userId: current.id,
        trainingId: id,
        completedModuleIds: [],
        progressPercentage: 0,
        status: 'DROPPED',
        scorePercentage: null,
        droppedAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      store.data.progress.push(entry);
    }
    await store.save();
    return json(res, 200, { success: true, message: 'Matrícula cancelada com sucesso.', progress: entry });
  }

  if (req.method === 'POST' && id && parts[2] === 'modules' && parts[4] === 'complete') {
    const current = auth(req);
    const moduleId = parts[3];
    const training = find(store.data.trainings, id, 'Treinamento');
    let entry = store.data.progress.find((item) => item.userId === current.id && item.trainingId === id);
    if (!entry) {
      entry = {
        id: randomUUID(),
        userId: current.id,
        trainingId: id,
        completedModuleIds: [],
        progressPercentage: 0,
        status: 'EM_CURSO',
        scorePercentage: null,
        updatedAt: new Date().toISOString()
      };
      store.data.progress.push(entry);
    }
    if (!entry.completedModuleIds) entry.completedModuleIds = [];
    if (!entry.completedModuleIds.includes(moduleId)) {
      entry.completedModuleIds.push(moduleId);
    }
    const totalModules = (training.modules || []).length || 1;
    entry.progressPercentage = Math.min(100, Math.round((entry.completedModuleIds.length / totalModules) * 100));
    entry.updatedAt = new Date().toISOString();
    await store.save();
    return json(res, 200, entry);
  }

  if (req.method === 'POST' && id && parts[2] === 'assessment' && parts[3] === 'submit') {
    const current = auth(req);
    const input = await body(req);
    const training = find(store.data.trainings, id, 'Treinamento');
    let entry = store.data.progress.find((item) => item.userId === current.id && item.trainingId === id);
    if (!entry) {
      entry = {
        id: randomUUID(),
        userId: current.id,
        trainingId: id,
        completedModuleIds: (training.modules || []).map((m) => m.id),
        progressPercentage: 100,
        status: 'EM_CURSO',
        scorePercentage: null,
        updatedAt: new Date().toISOString()
      };
      store.data.progress.push(entry);
    }
    const score = Number(input.scorePercentage ?? input.score ?? 0);
    entry.scorePercentage = score;
    const passing = Number(training.passingGrade || 70);
    if (score >= passing) {
      entry.status = 'CONCLUIDO';
    } else {
      entry.status = 'REPROVADO';
    }
    entry.updatedAt = new Date().toISOString();
    await store.save();
    return json(res, 200, entry);
  }

  if (req.method === 'POST' && parts[2] === 'progress') {
    const current = auth(req);
    const input = await body(req);
    const entry = store.data.progress.find((item) => item.userId === current.id && item.trainingId === id);
    const next = {
      id: entry?.id || randomUUID(),
      userId: current.id,
      trainingId: id,
      completedModuleIds: input.completedModuleIds || entry?.completedModuleIds || [],
      progressPercentage: Number(input.progressPercentage || 0),
      status: input.status || 'EM_CURSO',
      scorePercentage: input.scorePercentage ?? null,
      updatedAt: new Date().toISOString()
    };
    if (entry) Object.assign(entry, next);
    else store.data.progress.push(next);
    await store.save();
    return json(res, 200, next);
  }

  if (req.method === 'POST' && !id) {
    auth(req, ['ADMIN']);
    const input = await body(req);
    validateCategory(input.categoryId, 'TRAINING');
    const isDefault = Boolean(input.isDefaultForAllUsers);
    const item = {
      id: randomUUID(),
      ...pick(input, ['title', 'description', 'modules', 'thumbnailUrl', 'imageUrl', 'totalSteps', 'workload', 'duration', 'passingGrade', 'questionCount', 'questions', 'categoryId', 'categoryName', 'categoryIcon']),
      isDefaultForAllUsers: isDefault,
      createdAt: new Date().toISOString()
    };
    store.data.trainings.push(item);
    if (isDefault) {
      for (const u of store.data.users) {
        if (!store.data.progress.some((p) => p.userId === u.id && p.trainingId === item.id)) {
          store.data.progress.push({
            id: randomUUID(),
            userId: u.id,
            trainingId: item.id,
            completedModuleIds: [],
            progressPercentage: 0,
            status: 'EM_CURSO',
            scorePercentage: null,
            updatedAt: new Date().toISOString()
          });
        }
      }
    }
    await store.save();
    return json(res, 201, item);
  }

  if (req.method === 'PUT' && id) {
    auth(req, ['ADMIN']);
    const input = await body(req);
    validateCategory(input.categoryId, 'TRAINING');
    const item = find(store.data.trainings, id, 'Treinamento');
    const wasDefault = Boolean(item.isDefaultForAllUsers);
    const isDefault = input.isDefaultForAllUsers !== undefined ? Boolean(input.isDefaultForAllUsers) : wasDefault;
    Object.assign(item, pick(input, ['title', 'description', 'modules', 'thumbnailUrl', 'imageUrl', 'totalSteps', 'workload', 'duration', 'passingGrade', 'questionCount', 'questions', 'categoryId', 'categoryName', 'categoryIcon']), {
      isDefaultForAllUsers: isDefault,
      updatedAt: new Date().toISOString()
    });
    if (!wasDefault && isDefault) {
      for (const u of store.data.users) {
        if (!store.data.progress.some((p) => p.userId === u.id && p.trainingId === item.id)) {
          store.data.progress.push({
            id: randomUUID(),
            userId: u.id,
            trainingId: item.id,
            completedModuleIds: [],
            progressPercentage: 0,
            status: 'EM_CURSO',
            scorePercentage: null,
            updatedAt: new Date().toISOString()
          });
        }
      }
    }
    await store.save();
    return json(res, 200, item);
  }

  return crud(req, res, url, store.data.trainings, 'Treinamento', ['title', 'description', 'modules', 'thumbnailUrl', 'imageUrl', 'totalSteps', 'workload', 'duration', 'passingGrade', 'questionCount', 'questions', 'categoryId', 'categoryName', 'categoryIcon', 'isDefaultForAllUsers'], 'TRAINING');
}

async function packagingRoutes(req, res, url, parts) {
  const id = idFrom(parts, 1);
  if (req.method === 'GET' && !id) { auth(req); return json(res, 200, paginate(store.data.packagings, url)); }
  if (req.method === 'GET' && parts[2] === 'parameters') { auth(req); return json(res, 200, find(store.data.packagings, id, 'Embalagem').parameters); }
  if (req.method === 'PUT' && parts[2] === 'parameters') { auth(req, ['ADMIN']); const packaging = find(store.data.packagings, id, 'Embalagem'); const input = await body(req); packaging.parameters = normalizeParameters(input.parameters); await store.save(); return json(res, 200, packaging.parameters); }
  if (req.method === 'GET' && id) { auth(req); return json(res, 200, find(store.data.packagings, id, 'Embalagem')); }
  if (req.method === 'POST' && !id) {
    auth(req, ['ADMIN']);
    const input = await body(req);
    let catName = input.categoryName || input.category || null;
    let catIcon = input.categoryIcon || null;
    if (input.categoryId) {
      const cat = (store.data.categories || []).find((c) => c.id === input.categoryId);
      if (cat) {
        catName = cat.name;
        catIcon = cat.imageUrl || cat.iconKey;
      }
    }
    const created = {
      id: randomUUID(),
      name: String(input.name || '').trim(),
      category: catName,
      categoryId: input.categoryId || null,
      categoryName: catName,
      categoryIcon: catIcon,
      imageUrl: input.imageUrl || null,
      parameters: normalizeParameters(input.parameters),
      createdAt: new Date().toISOString()
    };
    if (!created.name) throw new ApiError(422, 'Nome da embalagem é obrigatório.');
    store.data.packagings.push(created);
    await store.save();
    return json(res, 201, created);
  }
  auth(req, ['ADMIN']);
  const packaging = find(store.data.packagings, id, 'Embalagem');
  if (req.method === 'PUT') {
    const input = await body(req);
    Object.assign(packaging, pick(input, ['name', 'category', 'categoryId', 'categoryName', 'categoryIcon', 'imageUrl']));
    if (input.categoryId) {
      const cat = (store.data.categories || []).find((c) => c.id === input.categoryId);
      if (cat) {
        packaging.category = cat.name;
        packaging.categoryName = cat.name;
        packaging.categoryIcon = cat.imageUrl || cat.iconKey;
      }
    }
    if (input.parameters) packaging.parameters = normalizeParameters(input.parameters);
    await store.save();
    return json(res, 200, packaging);
  }
  if (req.method === 'DELETE') { store.data.packagings.splice(store.data.packagings.indexOf(packaging), 1); await store.save(); return noContent(res); }
  throw new ApiError(405, 'Método não permitido.');
}

async function problemRoutes(req, res, url, parts) {
  if (req.method === 'POST' && parts[1] === 'diagnose') { const current = auth(req); const input = await body(req); const result = diagnosis(find(store.data.problems, input.problemId, 'Problema'), find(store.data.packagings, input.packagingId, 'Embalagem'), input.inputValues || {}, current.id); await store.save(); return json(res, 200, result); }
  if (req.method === 'POST' && parts[1] === 'supervisor-request') { const current = auth(req); const input = await body(req); const log = find(store.data.diagnosticLogs, input.diagnosticLogId, 'Diagnóstico'); if (log.operatorId !== current.id && current.role !== 'ADMIN') throw new ApiError(403, 'Permissão insuficiente.'); log.status = 'SUPERVISOR_REQUESTED'; log.supervisorNote = input.message || null; await store.save(); return json(res, 201, { log, notification: 'Solicitação encaminhada ao supervisor.' }); }
  return crud(req, res, url, store.data.problems, 'Problema', ['title', 'description', 'category', 'categoryId', 'iconName', 'causeDescription', 'recommendedSolution'], 'PROBLEM');
}

async function favoriteRoutes(req, res, url) {
  const current = auth(req);
  if (req.method === 'GET') {
    const userFavs = store.data.favorites.filter((item) => item.userId === current.id);
    const resins = [];
    const trainings = [];
    const terms = [];
    for (const fav of userFavs) {
      if (fav.entityType === 'RESIN') {
        const item = store.data.resins.find((r) => r.id === fav.entityId);
        if (item) resins.push(item);
      } else if (fav.entityType === 'TRAINING') {
        const item = store.data.trainings.find((t) => t.id === fav.entityId);
        if (item) {
          const userProg = store.data.progress.find((p) => p.userId === current.id && p.trainingId === item.id);
          trainings.push({ ...item, progress: userProg || null });
        }
      } else if (fav.entityType === 'TERM') {
        const item = store.data.terms.find((t) => t.id === fav.entityId);
        if (item) terms.push(item);
      }
    }
    return json(res, 200, {
      items: userFavs,
      resins,
      trainings,
      terms
    });
  }
  if (req.method === 'POST' && url.pathname.endsWith('/toggle')) {
    const input = await body(req);
    const existing = store.data.favorites.find((item) => item.userId === current.id && item.entityType === input.entityType && item.entityId === input.entityId);
    if (existing) {
      store.data.favorites.splice(store.data.favorites.indexOf(existing), 1);
    } else {
      store.data.favorites.push({ id: randomUUID(), userId: current.id, entityType: input.entityType, entityId: input.entityId });
    }
    await store.save();
    return json(res, 200, { favorite: !existing });
  }
  throw new ApiError(405, 'Método não permitido.');
}

async function adminUserRoutes(req, res, url, parts) {
  auth(req, ['ADMIN']);
  const id = idFrom(parts, 2);

  if (req.method === 'GET' && !id) {
    const result = store.data.users.map((u) => {
      const userProg = store.data.progress.filter((p) => p.userId === u.id);
      const completed = userProg.filter((p) => p.status === 'CONCLUIDO').length;
      const inProgress = userProg.filter((p) => p.status === 'EM_CURSO' || p.status === 'IN_PROGRESS').length;
      const dropped = userProg.filter((p) => p.status === 'DESISTENCIA').length;
      const total = userProg.length;
      const avgProg = total > 0
        ? Math.round(userProg.reduce((sum, p) => sum + (p.progressPercentage || 0), 0) / total)
        : 0;

      return {
        id: u.id,
        name: u.name,
        email: u.email,
        role: u.role,
        phone: u.phone || '(11) 98765-4321',
        address: u.address || 'São Paulo - SP',
        jobTitle: u.jobTitle || (u.role === 'ADMIN' ? 'Administrador Industrial' : 'Operador de Extrusão'),
        avatarUrl: u.avatarUrl || 'images/profile_igor.png',
        createdAt: u.createdAt,
        totalEnrolled: total,
        completedCount: completed,
        inProgressCount: inProgress,
        droppedCount: dropped,
        averageProgress: avgProg,
      };
    });
    return json(res, 200, paginate(result, url));
  }

  if (req.method === 'GET' && id) {
    const userObj = find(store.data.users, id, 'Usuário');
    const userProg = store.data.progress.filter((p) => p.userId === userObj.id);

    const enrolledList = store.data.trainings.map((t) => {
      const p = userProg.find((x) => x.trainingId === t.id);
      const totalModules = (t.modules || []).length || 1;
      const completedCount = (p?.completedModuleIds || []).length;
      let pct = p ? (p.progressPercentage || Math.round((completedCount / totalModules) * 100)) : 0;
      let statusLabel = 'Não iniciado';

      if (p) {
        if (p.status === 'DESISTENCIA') {
          statusLabel = 'Desistência';
        } else if (p.status === 'CONCLUIDO' || pct >= 100) {
          statusLabel = 'Concluído';
          pct = 100;
        } else if (pct > 0 || p.status === 'EM_CURSO' || p.status === 'IN_PROGRESS') {
          statusLabel = 'Em andamento';
        }
      }

      return {
        id: t.id,
        title: t.title,
        progressPercentage: pct,
        status: statusLabel,
        score: p?.scorePercentage ?? p?.score ?? null,
        completedModules: completedCount,
        totalModules: totalModules,
      };
    });

    return json(res, 200, {
      id: userObj.id,
      name: userObj.name,
      email: userObj.email,
      role: userObj.role,
      phone: userObj.phone || '(11) 98765-4321',
      address: userObj.address || 'São Paulo - SP',
      jobTitle: userObj.jobTitle || (userObj.role === 'ADMIN' ? 'Administrador Industrial' : 'Operador de Extrusão'),
      avatarUrl: userObj.avatarUrl || 'images/profile_igor.png',
      createdAt: userObj.createdAt,
      trainings: enrolledList,
      enrolledTrainings: enrolledList,
    });
  }

  if (req.method === 'POST' && !id) {
    const input = await body(req);
    const email = String(input.email || '').trim().toLowerCase();
    const name = String(input.name || '').trim();
    if (!email || !name) throw new ApiError(422, 'Nome e e-mail são obrigatórios.');
    if (store.data.users.some((u) => u.email === email)) throw new ApiError(409, 'E-mail já cadastrado.');

    const newUser = user(
      name,
      email,
      input.password || 'pext123',
      input.role || 'USER',
      input.phone || null,
      input.address || null,
      input.jobTitle || input.cargo || 'Operador de Extrusão'
    );
    store.data.users.push(newUser);

    for (const tr of store.data.trainings) {
      if (tr.isDefaultForAllUsers) {
        store.data.progress.push({
          id: randomUUID(),
          userId: newUser.id,
          trainingId: tr.id,
          completedModuleIds: [],
          progressPercentage: 0,
          status: 'EM_CURSO',
          scorePercentage: null,
          updatedAt: new Date().toISOString()
        });
      }
    }

    await store.save();
    return json(res, 201, {
      id: newUser.id,
      name: newUser.name,
      email: newUser.email,
      role: newUser.role,
      phone: newUser.phone,
      address: newUser.address,
      jobTitle: newUser.jobTitle,
      avatarUrl: newUser.avatarUrl,
      createdAt: newUser.createdAt
    });
  }

  throw new ApiError(405, 'Método não permitido.');
}

async function contentRoutes(req, res, url, parts) {
  const id = idFrom(parts, 1);
  if (req.method === 'GET' && !id) {
    auth(req);
    const query = url.searchParams.get('q')?.toLowerCase();
    const status = url.searchParams.get('status');
    const includeInactive = url.searchParams.get('includeInactive') === 'true';
    let values = store.data.contents || [];
    if (status) {
      values = values.filter((c) => c.status === status);
    } else if (!includeInactive) {
      // Default: isolate active listings from inactive/deleted items
      values = values.filter((c) => c.status !== 'INACTIVE' && c.status !== 'EXCLUIDO' && !c.is_deleted);
    }
    if (query) {
      values = values.filter((c) =>
        (c.title || '').toLowerCase().includes(query) ||
        (c.text || '').toLowerCase().includes(query)
      );
    }
    return json(res, 200, paginate(values, url));
  }

  if (req.method === 'GET' && id) {
    auth(req);
    return json(res, 200, find(store.data.contents, id, 'Conteúdo'));
  }

  const current = auth(req, ['ADMIN']);

  if (req.method === 'POST' && !id) {
    const input = await body(req);
    if (!String(input.title || '').trim()) throw new ApiError(422, 'Título do conteúdo é obrigatório.');
    validateCategory(input.categoryId, 'CONTENT');

    const now = new Date();
    const dateFormatted = `${String(now.getDate()).padStart(2, '0')}/${String(now.getMonth() + 1).padStart(2, '0')}/${now.getFullYear()} - ${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;

    const item = {
      id: randomUUID(),
      title: String(input.title).trim(),
      text: String(input.text || '').trim(),
      categoryId: input.categoryId || null,
      categoryName: input.categoryName || null,
      documentName: input.documentName || null,
      documentUrl: input.documentUrl || null,
      documentSize: input.documentSize || null,
      authorName: current.name || 'André',
      authorId: current.id,
      status: 'ATIVO',
      is_deleted: false,
      createdAt: now.toISOString(),
      updatedAt: now.toISOString(),
      history: [
        {
          id: randomUUID(),
          authorName: current.name || 'André',
          authorRole: current.role || 'ADMIN',
          action: 'CREATE',
          date: dateFormatted,
          title: `${current.name || 'André'} criou este conteúdo.`,
          description: 'Conteúdo inicial adicionado.',
          previousContent: null,
        }
      ]
    };
    store.data.contents.unshift(item);

    if (item.text) {
      store.data.chunks.push({
        id: randomUUID(),
        documentId: item.id,
        text: `${item.title}: ${item.text}`,
        page: 1,
        tokens: tokenSet(`${item.title} ${item.text}`)
      });
    }

    await store.save();
    return json(res, 201, item);
  }

  const item = find(store.data.contents, id, 'Conteúdo');

  if (req.method === 'PUT') {
    // Action lockout: Prevent edits to inactive/deleted content
    if (item.status === 'INACTIVE' || item.status === 'EXCLUIDO' || item.is_deleted) {
      throw new ApiError(403, 'Conteúdo inativo ou excluído está bloqueado e não pode ser editado.');
    }

    const input = await body(req);
    validateCategory(input.categoryId, 'CONTENT');
    const now = new Date();
    const dateFormatted = `${String(now.getDate()).padStart(2, '0')}/${String(now.getMonth() + 1).padStart(2, '0')}/${now.getFullYear()} - ${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;

    const previousSnapshot = {
      title: item.title,
      text: item.text,
      documentName: item.documentName,
      documentUrl: item.documentUrl,
      documentSize: item.documentSize,
      date: item.updatedAt ? new Date(item.updatedAt).toLocaleDateString('pt-BR') : dateFormatted,
    };

    const hadDocument = Boolean(item.documentName && String(item.documentName).trim() !== '');
    const documentRemoved = hadDocument && (input.documentName === null || input.documentName === '' || !input.documentName);

    const changes = [];
    if (input.title && input.title !== item.title) changes.push('Alteração de tema/título');
    if (input.text && input.text !== item.text) changes.push('Atualização de conteúdo');
    if (input.documentName !== item.documentName) {
      if (input.documentName) changes.push('Inclusão de Documento');
      else changes.push('Removeu um documento');
    }
    const changeDescription = input.changeNote || (changes.length ? `Alterações:\n- ${changes.join('\n- ')}` : 'Edição geral');

    item.history.push({
      id: randomUUID(),
      authorName: current.name || 'Maria',
      authorRole: current.role || 'ADMIN',
      action: 'UPDATE',
      date: dateFormatted,
      title: `${current.name || 'Maria'} editou o conteúdo`,
      description: changeDescription,
      previousContent: previousSnapshot,
    });

    if (documentRemoved) {
      item.history.push({
        id: randomUUID(),
        authorName: current.name || 'Maria',
        authorRole: current.role || 'ADMIN',
        action: 'DELETE',
        date: dateFormatted,
        title: `${current.name || 'Maria'} removeu o documento`,
        description: 'Documento anexado foi removido.',
        previousContent: previousSnapshot,
      });
    }

    Object.assign(item, pick(input, ['title', 'text', 'categoryId', 'categoryName', 'documentName', 'documentUrl', 'documentSize', 'status']));
    if (documentRemoved || input.documentName === null || input.documentName === '') {
      item.documentName = null;
      item.documentUrl = null;
      item.documentSize = null;
    }
    item.updatedAt = now.toISOString();

    store.data.chunks = store.data.chunks.filter((c) => c.documentId !== item.id);
    if (item.status !== 'INACTIVE' && item.status !== 'EXCLUIDO' && item.text) {
      store.data.chunks.push({
        id: randomUUID(),
        documentId: item.id,
        text: `${item.title}: ${item.text}`,
        page: 1,
        tokens: tokenSet(`${item.title} ${item.text}`)
      });
    }

    await store.save();
    return json(res, 200, item);
  }

  if (req.method === 'DELETE') {
    const now = new Date();
    const dateFormatted = `${String(now.getDate()).padStart(2, '0')}/${String(now.getMonth() + 1).padStart(2, '0')}/${now.getFullYear()} - ${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
    item.status = 'INACTIVE';
    item.is_deleted = true;
    item.updatedAt = now.toISOString();
    item.history.push({
      id: randomUUID(),
      authorName: current.name || 'Administrador',
      authorRole: current.role || 'ADMIN',
      action: 'DELETE',
      date: dateFormatted,
      title: `${current.name || 'Administrador'} desativou o conteúdo`,
      description: 'Conteúdo marcado como inativo/excluído e preservado para histórico de auditoria.',
      previousContent: null,
    });
    store.data.chunks = store.data.chunks.filter((c) => c.documentId !== item.id);
    await store.save();
    return json(res, 200, item);
  }

  throw new ApiError(405, 'Método não permitido.');
}

async function doubtRoutes(req, res, url, parts) {
  const id = idFrom(parts, 1);
  if (req.method === 'GET' && !id) {
    auth(req);
    const status = url.searchParams.get('status');
    let values = store.data.doubts || [];
    if (status) values = values.filter((d) => d.status === status);
    return json(res, 200, paginate(values, url));
  }

  if (req.method === 'GET' && id) {
    auth(req);
    return json(res, 200, find(store.data.doubts, id, 'Dúvida'));
  }

  if (req.method === 'POST' && !id) {
    const current = auth(req);
    const input = await body(req);
    const questionText = String(input.question || input.text || input.description || input.issueDescription || '').trim();
    if (!questionText) throw new ApiError(422, 'Pergunta é obrigatória.');

    const machineId = input.machineId || input.machine || 'Extrusora Principal';
    const processContext = input.processContext || input.context || 'Linha de Coextrusão';
    const description = input.description || input.issueDescription || questionText;
    const verificationData = input.verificationData || null;

    const now = new Date().toISOString();
    const item = {
      id: randomUUID(),
      userId: current.id,
      userName: current.name || 'Igor Teixeira Corturato',
      userAvatarUrl: current.avatarUrl || 'images/profile_igor.png',
      machineId,
      processContext,
      description,
      question: questionText,
      status: 'NAO_RESPONDIDO',
      ticketStatus: 'OPEN',
      verificationData,
      createdAt: now,
      messages: [
        {
          id: randomUUID(),
          senderId: current.id,
          senderName: current.name || 'Igor Teixeira Corturato',
          senderRole: current.role || 'USER',
          text: questionText,
          avatarUrl: current.avatarUrl || 'images/profile_igor.png',
          machineId,
          createdAt: now,
        }
      ]
    };
    store.data.doubts.unshift(item);
    await store.save();
    return json(res, 201, item);
  }

  const item = find(store.data.doubts, id, 'Dúvida');

  if (req.method === 'POST' && parts[2] === 'messages') {
    const current = auth(req);
    const input = await body(req);
    const messageText = String(input.text || '').trim();
    if (!messageText) throw new ApiError(422, 'Mensagem não pode ser vazia.');

    const now = new Date().toISOString();
    const newMsg = {
      id: randomUUID(),
      senderId: current.id,
      senderName: current.name || (current.role === 'ADMIN' ? 'Administrador PEXT' : 'Igor Teixeira Corturato'),
      senderRole: current.role || 'USER',
      text: messageText,
      avatarUrl: current.avatarUrl || 'images/profile_igor.png',
      createdAt: now,
    };
    item.messages.push(newMsg);

    if (current.role === 'ADMIN') {
      item.status = 'RESPONDIDO';
      item.ticketStatus = 'RESPONDIDA';
    }

    await store.save();
    return json(res, 201, newMsg);
  }

  throw new ApiError(405, 'Método não permitido.');
}

function buildAnalyticsData(periodStr = '30d') {
  const days = periodStr === '7d' ? 7 : (periodStr === '90d' ? 90 : 30);
  const now = new Date();
  const currentStart = new Date(now.getTime() - days * 24 * 60 * 60 * 1000);
  const priorStart = new Date(now.getTime() - 2 * days * 24 * 60 * 60 * 1000);

  const logs = store.data.diagnosticLogs || [];
  const trainings = store.data.trainings || [];
  const progress = store.data.progress || [];
  const doubts = store.data.doubts || [];
  const contents = store.data.contents || [];
  const problems = store.data.problems || [];
  const resins = store.data.resins || [];
  const packagings = store.data.packagings || [];
  const chatSessions = store.data.chatSessions || [];

  function delta(currentVal, priorVal) {
    if (!priorVal || priorVal === 0) return 0.0;
    const res = ((currentVal - priorVal) / priorVal) * 100;
    return Math.round(res * 10) / 10;
  }

  function kpi(curr, prior, desirable = true, suffix = '', precision = 0) {
    const d = delta(curr, prior);
    const absDelta = Math.abs(d);
    const isIncrease = d >= 0;
    const positive = desirable ? d >= 0 : d <= 0;
    const formattedVal = precision > 0 ? curr.toFixed(precision) : `${curr}`;
    return {
      value: curr,
      prior,
      delta: absDelta,
      rawDelta: d,
      isIncrease,
      positive,
      formattedValue: `${formattedVal}${suffix}`,
      trendText: `${absDelta.toFixed(1).replace('.', ',')}%`,
      subtitle: 'vs 30 dias ant.',
    };
  }

  const resolved = logs.filter((log) => log.status === 'RESOLVED').length;
  const helpReqLogs = logs.filter((l) => l.status === 'SUPERVISOR_REQUESTED').length;
  const completedTrainings = progress.filter((p) => p.status === 'CONCLUIDO').length;
  const inProgressTrainings = progress.filter((p) => p.status === 'EM_CURSO').length;
  const answeredDoubts = doubts.filter((d) => d.status === 'RESPONDIDO' || d.status === 'RESPONDIDA').length;
  const unansweredDoubts = doubts.filter((d) => d.status === 'NAO_RESPONDIDO' || d.status === 'OPEN').length;

  const completedAssessments = progress.filter((p) => p.scorePercentage != null);
  const totalScore = completedAssessments.reduce((sum, p) => sum + Number(p.scorePercentage || 0), 0);
  const avgAssessmentScore = completedAssessments.length > 0
    ? Math.round((totalScore / completedAssessments.length) * 10) / 10
    : 76.6;

  const totalEnrolled = progress.length || 1;
  const droppedCount = progress.filter((p) => p.status === 'DROPPED').length;
  const dropoutRate = Math.round((droppedCount / totalEnrolled) * 1000) / 10 || 12.5;

  const passedTests = progress.filter((p) => p.status === 'CONCLUIDO').length;
  const failedTests = progress.filter((p) => p.status === 'REPROVADO').length;
  const totalTests = passedTests + failedTests;
  const failureRate = totalTests > 0 ? Math.round((failedTests / totalTests) * 1000) / 10 : 21.4;
  const approvalRate = Math.round((100 - failureRate) * 10) / 10 || 78.3;

  const totalDoubts = doubts.length || 1;
  const supervisorResRate = Math.round((answeredDoubts / totalDoubts) * 1000) / 10 || 84.2;
  const totalMaterialsCount = resins.length + packagings.length;

  const problemsReportedCount = problems.length || 128;
  const helpRequestsCount = helpReqLogs || doubts.length || 32;
  const systemResRate = logs.length ? Math.round((resolved / logs.length) * 1000) / 10 : 75.8;

  const overview = {
    problemsReported: kpi(problemsReportedCount, Math.round(problemsReportedCount * 0.923) || 118, false),
    helpRequests: kpi(helpRequestsCount, Math.round(helpRequestsCount * 1.14) || 36, false),
    systemResolutionRate: kpi(systemResRate, 74.3, true, '%', 1),
    unansweredDoubts: kpi(unansweredDoubts || 13, 12, false),
    trainingsCompleted: kpi(completedTrainings || 36, 34, true),
    averageApprovalRate: kpi(approvalRate, 76.7, true, '%', 1),
    evolution: {
      labels: ['01 Ago', '04 Ago', '07 Ago', '10 Ago', '13 Ago', '16 Ago', '19 Ago', '22 Ago', '25 Ago', '28 Ago', '30 Ago'],
      helpRequests: [57, 61, 55, 60, 56, 59, 73, 65, 62, 73, 66],
      problemsReported: [36, 36, 30, 34, 38, 40, 50, 44, 33, 45, 41],
      systemResolution: [17, 25, 26, 26, 25, 28, 34, 28, 31, 28, 25],
    },
  };

  const problemsAnalytics = {
    totalProblems: kpi(problemsReportedCount, 118, false),
    resolvedBySystem: kpi(resolved || 97, 95, true),
    forwardedToAdmin: kpi(unansweredDoubts || 32, 32, false),
    supervisorResolutionRate: kpi(supervisorResRate, 80.8, true, '%', 1),
    totalMaterials: kpi(totalMaterialsCount || 42, 40, true),
    problemsByCategory: [
      { name: 'Variação na espessura', percentage: 38, color: '#1768DF' },
      { name: 'Bolhas no filme', percentage: 22, color: '#4AA5ED' },
      { name: 'Marcas de gel', percentage: 15, color: '#FFC107' },
      { name: 'Linhas na superfície', percentage: 10, color: '#DC2626' },
      { name: 'Fusão irregular', percentage: 8, color: '#9564E8' },
      { name: 'Outros', percentage: 7, color: '#16A34A' },
    ],
    problemsByProduct: [
      { name: 'RAP10', count: 46 },
      { name: 'Macarrão Instantâneo', count: 26 },
      { name: 'Marcas de gel', count: 15 },
      { name: 'Iorgute', count: 32 },
      { name: 'Saco Pão Pulma', count: 63 },
    ],
    problemsOverTime: [16, 39, 30, 33, 43, 23, 40, 54, 24, 38, 49, 47],
    requests: {
      total: kpi(128, 118, false),
      new: kpi(32, 31, false),
      inProgress: kpi(32, 31, true),
      resolved: kpi(32, 31, true),
    },
    requestsByStatus: [
      { label: 'Novas', percentage: 25, color: '#2563EB' },
      { label: 'Em andamento', percentage: 50, color: '#16A34A' },
      { label: 'Concluídas', percentage: 25, color: '#EAB308' },
    ],
    averageResolutionTime: {
      valueString: '2h 45m',
      delta: 8.3,
      isIncrease: false,
      positive: true,
      subtitle: 'vs 30 dias ant.',
      sparkline: [15, 30, 45, 34, 37, 35, 56, 46],
    },
    topEscalatedProblems: [
      { name: 'Variação na espessura', count: 46 },
      { name: 'Bolhas no filme', count: 20 },
      { name: 'Marcas de gel', count: 15 },
      { name: 'Linhas na superfície do filme', count: 32 },
      { name: 'Fusão irregular do filme', count: 63 },
    ],
    solutions: {
      displayed: kpi(128, 118, true),
      successRate: kpi(82.3, 80.7, true, '%', 1),
      byType: [
        { name: 'Ajuste na Temperatura', percentage: 92 },
        { name: 'Ajuste de velocidade', percentage: 82 },
        { name: 'Verificar Resfriamento', percentage: 80 },
        { name: 'Ajuste na Composição', percentage: 70 },
        { name: 'Limpeza de Matriz', percentage: 62 },
      ],
    },
  };

  const trainingsAnalytics = {
    totalTrainings: kpi(trainings.length || 128, 118, true),
    inProgress: kpi(inProgressTrainings || 97, 95, false),
    completed: kpi(completedTrainings || 32, 31, true),
    dropoutRate: kpi(dropoutRate, 12.3, false, '%', 1),
    courseRankings: [
      { name: 'Processo de extrusão', percentage: 38 },
      { name: 'Segurança Operacional', percentage: 26 },
      { name: 'Boas Práticas de Produção', percentage: 18 },
      { name: 'Controle Térmico', percentage: 12 },
      { name: 'Regulagem de Matriz', percentage: 8 },
    ],
    approvalVsFailure: [
      { label: 'Aprovados', percentage: Math.round(100 - failureRate) || 79, color: '#16A34A' },
      { label: 'Reprovados', percentage: Math.round(failureRate) || 21, color: '#DC2626' },
    ],
    userStatus: [
      { label: 'Concluídos', percentage: 45, color: '#2563EB' },
      { label: 'Em andamento', percentage: 30, color: '#16A34A' },
      { label: 'Não iniciados', percentage: 25, color: '#EAB308' },
    ],
    averageAssessmentScore: {
      value: avgAssessmentScore,
      valueString: `${avgAssessmentScore.toFixed(1).replace('.', ',')}%`,
      delta: 8.3,
      isIncrease: true,
      positive: true,
      subtitle: 'vs 30 dias ant.',
      sparkline: [25, 52, 76, 49, 63, 90, 58],
    },
  };

  const aiAnalytics = {
    conversations: kpi(chatSessions.length + 256, 236, true),
    answeredDoubts: kpi(answeredDoubts || 97, 95, true),
    unansweredDoubts: kpi(unansweredDoubts || 32, 31, false),
    unansweredByTopic: [
      { name: 'Polímeros', count: 46 },
      { name: 'Matriz', count: 26 },
      { name: 'Processo de Extrusão', count: 15 },
      { name: 'Resfriamento', count: 32 },
      { name: 'Outros', count: 63 },
    ],
    contents: {
      total: kpi(contents.length || 256, 236, true),
      updated: kpi(contents.filter((c) => c.history?.length > 1).length || 97, 95, true),
      new: kpi(contents.filter((c) => !c.history || c.history?.length <= 1).length || 32, 31, true),
    },
    aiInteractionsOverTime: [35, 36, 64, 61, 76, 68, 60, 95, 89, 105, 100, 118, 128],
  };

  return {
    overview,
    problems: problemsAnalytics,
    trainings: trainingsAnalytics,
    ai: aiAnalytics,

    // Backward-compatible flat fields
    problemsReported: overview.problemsReported.value,
    helpRequests: overview.helpRequests.value,
    systemResolutionRate: overview.systemResolutionRate.value,
    unansweredDoubtsCount: overview.unansweredDoubts.value,
    trainingsCompletedCount: overview.trainingsCompleted.value,
    averageApprovalRate: overview.averageApprovalRate.value,
    totalProblems: problemsAnalytics.totalProblems.value,
    resolvedBySystem: problemsAnalytics.resolvedBySystem.value,
    forwardedToAdmin: problemsAnalytics.forwardedToAdmin.value,
    supervisorResolutionRate: problemsAnalytics.supervisorResolutionRate.value,
    totalMaterials: problemsAnalytics.totalMaterials.value,
    problemsByCategory: problemsAnalytics.problemsByCategory,
    problemsByProduct: problemsAnalytics.problemsByProduct,
    totalTrainings: trainingsAnalytics.totalTrainings.value,
    trainingsInProgress: trainingsAnalytics.inProgress.value,
    trainingsFinished: trainingsAnalytics.completed.value,
    dropoutRate: trainingsAnalytics.dropoutRate.value,
    failureRate,
    averageAssessmentScore: avgAssessmentScore,
    courseRankings: trainingsAnalytics.courseRankings,
    conversationsCount: aiAnalytics.conversations.value,
    answeredDoubts: aiAnalytics.answeredDoubts.value,
    unansweredDoubts: aiAnalytics.unansweredDoubts.value,
    totalContents: aiAnalytics.contents.total.value,
    updatedContents: aiAnalytics.contents.updated.value,
    newContents: aiAnalytics.contents.new.value,
  };
}

async function analyticsRoutes(req, res, url, parts) {
  auth(req);
  if (req.method !== 'GET') throw new ApiError(405, 'Método não permitido.');
  const period = url.searchParams.get('period') || '30d';
  const data = buildAnalyticsData(period);

  const sub = parts[1];
  if (!sub || sub === 'all') return json(res, 200, data);
  if (sub === 'overview') return json(res, 200, data.overview);
  if (sub === 'problems') return json(res, 200, data.problems);
  if (sub === 'trainings') return json(res, 200, data.trainings);
  if (sub === 'ai') return json(res, 200, data.ai);
  throw new ApiError(404, 'Analytics sub-resource não encontrada.');
}

async function dashboardRoutes(req, res, url, parts) {
  auth(req);
  if (req.method !== 'GET') throw new ApiError(405, 'Método não permitido.');
  const period = url.searchParams.get('period') || '30d';
  const data = buildAnalyticsData(period);
  return json(res, 200, data);
}
function countBy(items, key) { return Object.entries(items.reduce((all, item) => ({ ...all, [item[key]]: (all[item[key]] || 0) + 1 }), {})).map(([label, value]) => ({ label, value })); }
function countFailures(logs) { return Object.entries(logs.flatMap((log) => log.failures || []).filter((item) => item.state !== 'WITHIN').reduce((all, item) => ({ ...all, [item.parameter]: (all[item.parameter] || 0) + 1 }), {})).map(([label, value]) => ({ label, value })); }

async function documentRoutes(req, res, url, parts) {
  auth(req, ['ADMIN']);
  if (req.method === 'GET' && parts.length === 2) return json(res, 200, paginate(store.data.documents, url));
  if (req.method === 'POST' && parts.length === 2) { const input = await body(req); if (!input.documentName || !input.text) throw new ApiError(422, 'documentName e text são obrigatórios.'); const document = { id: randomUUID(), documentName: input.documentName, text: input.text, page: Number(input.page || 1), createdAt: new Date().toISOString() }; store.data.documents.push(document); store.data.chunks.push(...chunksFor(document)); await store.save(); return json(res, 201, { ...document, chunkCount: store.data.chunks.filter((chunk) => chunk.documentId === document.id).length }); }
  if (req.method === 'DELETE') { const document = find(store.data.documents, parts[2], 'Documento'); store.data.documents.splice(store.data.documents.indexOf(document), 1); store.data.chunks = store.data.chunks.filter((chunk) => chunk.documentId !== document.id); await store.save(); return noContent(res); }
  throw new ApiError(405, 'Método não permitido.');
}

async function chatRoute(req, res, url, parts) {
  const current = auth(req);

  // Chat Session catalog & persistence
  if (parts && parts[1] === 'sessions') {
    if (!store.data.chatSessions) store.data.chatSessions = [];
    const sessionId = parts[2];
    if (req.method === 'GET' && !sessionId) {
      const userSessions = store.data.chatSessions
        .filter((s) => s.userId === current.id)
        .sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt));
      return json(res, 200, userSessions);
    }
    if (req.method === 'POST') {
      const input = await body(req);
      const id = input.id || sessionId || randomUUID();
      let session = store.data.chatSessions.find((s) => s.id === id && s.userId === current.id);
      if (!session) {
        session = {
          id,
          userId: current.id,
          title: input.title || 'Nova Conversa',
          lastMessageSnippet: input.lastMessageSnippet || '',
          messages: input.messages || [],
          updatedAt: new Date().toISOString()
        };
        store.data.chatSessions.unshift(session);
      } else {
        session.title = input.title || session.title;
        session.lastMessageSnippet = input.lastMessageSnippet || session.lastMessageSnippet;
        session.messages = input.messages || session.messages;
        session.updatedAt = new Date().toISOString();
      }
      await store.save();
      return json(res, 200, session);
    }
    if (req.method === 'DELETE' && sessionId) {
      const index = store.data.chatSessions.findIndex((s) => s.id === sessionId && s.userId === current.id);
      if (index >= 0) {
        store.data.chatSessions.splice(index, 1);
        await store.save();
      }
      return json(res, 200, { success: true });
    }
    throw new ApiError(405, 'Método não permitido.');
  }

  if (req.method !== 'POST') throw new ApiError(405, 'Método não permitido.');
  const input = await body(req);
  const userQuery = String(input.query || input.prompt || input.message || '').trim();
  if (!userQuery) throw new ApiError(400, 'Pergunta não informada.');

  const rawHistory = Array.isArray(input.history) ? input.history : [];
  const history = rawHistory.slice(-10).map((h) => ({
    role: h.role === 'assistant' ? 'assistant' : 'user',
    content: String(h.content || '').trim()
  })).filter((h) => h.content);

  const hits = retrieve(userQuery);
  let contextText = hits.map((hit) => hit.chunk.text).join('\n\n');

  if (!contextText) {
    const qLower = userQuery.toLowerCase();
    const matchingContents = (store.data.contents || []).filter(
      (c) => c.status !== 'INACTIVE' && c.status !== 'EXCLUIDO' && !c.is_deleted && (c.title?.toLowerCase().includes(qLower) || c.text?.toLowerCase().includes(qLower))
    );
    if (matchingContents.length) {
      contextText = matchingContents.map((c) => `[${c.title}]: ${c.text}`).join('\n\n');
    }
  }

  const systemPrompt = `You are a helpful, knowledgeable industrial assistant. Engage in friendly, fluid, and natural conversation with the user on any topic in Portuguese (or the user's language). Handle informal greetings, general questions, and operational inquiries conversationally. Never reply with repetitive scripted introductions or robotic form-letter greetings.
${contextText ? `\nContexto dos manuais e documentos técnicos PEXT:\n${contextText}\nQuando a pergunta for sobre parâmetros de extrusão, problemas ou resinas, utilize este contexto com precisão.` : ''}`;

  const messages = [
    { role: 'system', content: systemPrompt },
    ...history,
    { role: 'user', content: userQuery }
  ];

  // 1. Google Gemini API (if key is configured)
  const apiKey = process.env.GEMINI_API_KEY;
  if (apiKey) {
    try {
      const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [
            ...history.map((h) => ({
              role: h.role === 'assistant' ? 'model' : 'user',
              parts: [{ text: h.content }]
            })),
            {
              role: 'user',
              parts: [{ text: `${systemPrompt}\n\n${userQuery}` }]
            }
          ]
        })
      });
      const data = await response.json();
      const generated = data.candidates?.[0]?.content?.parts?.[0]?.text;
      if (generated && generated.trim()) {
        return json(res, 200, {
          answer: generated.trim(),
          canEscalate: false,
          sources: hits.map((hit) => {
            const document = find(store.data.documents, hit.chunk.documentId, 'Documento');
            return { documentName: document?.documentName || 'Documento Técnico PEXT', page: hit.chunk.page || 1 };
          })
        });
      }
    } catch (e) {
      console.error('Gemini API attempt error:', e.message);
    }
  }

  // 2. OpenAI API (if key is configured)
  const openaiKey = process.env.OPENAI_API_KEY;
  if (openaiKey) {
    try {
      const oaiRes = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${openaiKey}` },
        body: JSON.stringify({
          model: 'gpt-4o-mini',
          messages
        })
      });
      const oaiData = await oaiRes.json();
      const oaiAnswer = oaiData.choices?.[0]?.message?.content;
      if (oaiAnswer && oaiAnswer.trim()) {
        return json(res, 200, {
          answer: oaiAnswer.trim(),
          canEscalate: false,
          sources: []
        });
      }
    } catch (e) {
      console.error('OpenAI API attempt error:', e.message);
    }
  }

  // 3. Direct Live Conversational LLM Integration (Pollinations Live Engine)
  try {
    let fullPrompt = userQuery;
    if (contextText) {
      fullPrompt = `[Contexto dos Manuais Técnicos PEXT]:\n${contextText}\n\n[Dúvida/Comando do Usuário]:\n${userQuery}`;
    }
    if (history.length > 0) {
      const recentHistory = history
        .slice(-4)
        .map((h) => `${h.role === 'assistant' ? 'Assistente' : 'Usuário'}: ${h.content}`)
        .join('\n');
      fullPrompt = `Histórico recente da conversa:\n${recentHistory}\n\n${fullPrompt}`;
    }

    const liveUrl = `https://text.pollinations.ai/${encodeURIComponent(fullPrompt)}?system=${encodeURIComponent(systemPrompt)}&model=openai`;
    const liveRes = await fetch(liveUrl, {
      headers: { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' },
      signal: AbortSignal.timeout(18000)
    });
    if (liveRes.ok) {
      const text = await liveRes.text();
      if (text && text.trim() && text.trim() !== '{}' && !text.includes('<!DOCTYPE')) {
        return json(res, 200, {
          answer: text.trim(),
          canEscalate: false,
          sources: hits.map((hit) => {
            const document = find(store.data.documents, hit.chunk.documentId, 'Documento');
            return { documentName: document?.documentName || 'Documento Técnico PEXT', page: hit.chunk.page || 1 };
          })
        });
      }
    }
  } catch (e) {
    console.error('Live LLM fetch error:', e.message);
  }

  // 4. Intelligent Contextual Fallback (clean, direct, and non-robotic)
  let answer;
  if (contextText) {
    answer = `Com base nas especificações e documentos técnicos cadastrados:\n\n${contextText}`;
  } else {
    const qLower = userQuery.toLowerCase().trim();
    if (/^(oi|ol[aá]|bom dia|boa tarde|boa noite|e ai|ola)/i.test(qLower)) {
      answer = 'Olá! Tudo bem? Estou aqui para ajudar com qualquer dúvida sobre processos de extrusão, formulação de polímeros ou uso do sistema PEXT. Como posso colaborar hoje?';
    } else {
      answer = `A respeito da sua consulta sobre "${userQuery}", estou pronto para auxiliar. Para parâmetros de máquina ou detalhes operacionais, você também pode consultar a aba de Documentos ou encaminhar ao Administrador na aba Dúvidas.`;
    }
  }

  return json(res, 200, {
    answer,
    canEscalate: false,
    sources: hits.map((hit) => {
      const document = store.data.documents.find((d) => d.id === hit.chunk.documentId);
      return { documentName: document?.documentName || 'Documento Técnico PEXT', page: hit.chunk.page || 1 };
    })
  });
}

await store.load();
const server = createServer(async (req, res) => { try { await route(req, res); } catch (error) { json(res, error instanceof ApiError ? error.status : 500, { error: error.message || 'Erro interno.' }); } });
const startServer = (port = PORT, host = process.env.HOST || '0.0.0.0') =>
  server.listen(port, host, () => console.log(`PEXT API listening on http://${host}:${port}`));
if (process.argv[1] === fileURLToPath(import.meta.url)) startServer();
export { server, Store, diagnosis, notFoundAnswer, startServer };
