require('dotenv').config();

const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');

const db = require('./db');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: 'Lab Equipment Management API'
  });
});

app.post('/api/auth/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        messaSge: 'Name, email and password are required'
      });
    }

    const [existingUsers] = await db.execute(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({
        message: 'Email already registered'
      });
    }

    const passwordHash = await bcrypt.hash(password, 10);

    const [result] = await db.execute(
      `
      INSERT INTO users (name, email, password_hash, role)
      VALUES (?, ?, ?, ?)
      `,
      [name, email, passwordHash, 'student']
    );

    res.status(201).json({
      message: 'Account created successfully',
      user: {
        id: result.insertId,
        name,
        email,
        role: 'student'
      }
    });

  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: 'Email and password are required'
      });
    }

    const [users] = await db.execute(
      `
      SELECT id, name, email, password_hash, role
      FROM users
      WHERE email = ?
      `,
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({
        message: 'Invalid email or password'
      });
    }

    const user = users[0];

    const passwordMatches = await bcrypt.compare(
      password,
      user.password_hash
    );

    if (!passwordMatches) {
      return res.status(401).json({
        message: 'Invalid email or password'
      });
    }

    res.json({
      message: 'Login successful',

      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role
      }
    });

  } catch (error) {
    console.error(error);

    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});