import test from 'node:test';
import assert from 'node:assert/strict';
import { server } from '../src/server.js';

let baseUrl;

test.before(async () => {
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  baseUrl = `http://127.0.0.1:${server.address().port}/api/v1`;
});

test.after(async () => new Promise((resolve) => server.close(resolve)));

test('authenticates the seeded admin and enforces protected profile access', async () => {
  const login = await fetch(`${baseUrl}/auth/login`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: 'admin@pext.local', password: 'admin123' }),
  });
  assert.equal(login.status, 200);
  const session = await login.json();
  assert.equal(session.user.role, 'ADMIN');

  const profile = await fetch(`${baseUrl}/profile/me`, { headers: { Authorization: `Bearer ${session.token}` } });
  assert.equal(profile.status, 200);
  assert.equal((await profile.json()).email, 'admin@pext.local');

  const denied = await fetch(`${baseUrl}/profile/me`);
  assert.equal(denied.status, 401);
});
