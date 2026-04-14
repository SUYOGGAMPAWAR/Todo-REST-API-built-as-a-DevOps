const request = require('supertest');
const { app, server } = require('../src/index');

afterAll(() => server.close());

describe('Health Endpoints', () => {
  test('GET /health returns UP', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('UP');
  });

  test('GET /ready returns READY', async () => {
    const res = await request(app).get('/ready');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('READY');
  });
});

describe('Todos API', () => {
  test('GET /api/todos returns list', async () => {
    const res = await request(app).get('/api/todos');
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  test('POST /api/todos creates a todo', async () => {
    const res = await request(app)
      .post('/api/todos')
      .send({ title: 'Test DevOps pipeline' });
    expect(res.statusCode).toBe(201);
    expect(res.body.data.title).toBe('Test DevOps pipeline');
    expect(res.body.data.completed).toBe(false);
  });

  test('POST /api/todos returns 400 without title', async () => {
    const res = await request(app).post('/api/todos').send({});
    expect(res.statusCode).toBe(400);
  });

  test('GET /api/todos/:id returns a specific todo', async () => {
    const res = await request(app).get('/api/todos/1');
    expect(res.statusCode).toBe(200);
    expect(res.body.data.id).toBe(1);
  });

  test('GET /api/todos/:id returns 404 for missing todo', async () => {
    const res = await request(app).get('/api/todos/9999');
    expect(res.statusCode).toBe(404);
  });

  test('PUT /api/todos/:id updates a todo', async () => {
    const res = await request(app)
      .put('/api/todos/1')
      .send({ completed: true });
    expect(res.statusCode).toBe(200);
    expect(res.body.data.completed).toBe(true);
  });

  test('DELETE /api/todos/:id deletes a todo', async () => {
    const res = await request(app).delete('/api/todos/2');
    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
  });
});
