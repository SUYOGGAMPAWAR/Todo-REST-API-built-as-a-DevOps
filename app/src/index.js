const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;
const VERSION = process.env.APP_VERSION || '1.0.0';

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// In-memory store (replace with DB in production)
let todos = [
  { id: 1, title: 'Learn Docker', completed: true },
  { id: 2, title: 'Set up Jenkins CI/CD', completed: false },
  { id: 3, title: 'Deploy to Kubernetes', completed: false },
];
let nextId = 4;

// ── Routes ──────────────────────────────────────────────
app.get('/health', (req, res) => {
  res.json({ status: 'UP', version: VERSION, timestamp: new Date().toISOString() });
});

app.get('/ready', (req, res) => {
  res.json({ status: 'READY' });
});

app.get('/api/todos', (req, res) => {
  res.json({ success: true, count: todos.length, data: todos });
});

app.get('/api/todos/:id', (req, res) => {
  const todo = todos.find(t => t.id === parseInt(req.params.id));
  if (!todo) return res.status(404).json({ success: false, message: 'Todo not found' });
  res.json({ success: true, data: todo });
});

app.post('/api/todos', (req, res) => {
  const { title } = req.body;
  if (!title) return res.status(400).json({ success: false, message: 'Title is required' });
  const todo = { id: nextId++, title, completed: false };
  todos.push(todo);
  res.status(201).json({ success: true, data: todo });
});

app.put('/api/todos/:id', (req, res) => {
  const index = todos.findIndex(t => t.id === parseInt(req.params.id));
  if (index === -1) return res.status(404).json({ success: false, message: 'Todo not found' });
  todos[index] = { ...todos[index], ...req.body, id: todos[index].id };
  res.json({ success: true, data: todos[index] });
});

app.delete('/api/todos/:id', (req, res) => {
  const index = todos.findIndex(t => t.id === parseInt(req.params.id));
  if (index === -1) return res.status(404).json({ success: false, message: 'Todo not found' });
  todos.splice(index, 1);
  res.json({ success: true, message: 'Todo deleted' });
});

// ── Start ────────────────────────────────────────────────
const server = app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT} | version ${VERSION}`);
});

module.exports = { app, server };
