
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();
const jwt = require('jsonwebtoken');
const app = express();

// MongoDB Setup
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/EverRead';
mongoose.connect(MONGODB_URI)
  .then(() => console.log('MongoDB connected successfully.'))
  .catch(err => console.error('MongoDB connection error:', err));

// Middlewares
app.use(cors({
  origin: "http://localhost:5050", // your frontend URL
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// JWT Secret
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret';

// Middleware to protect routes
const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ error: 'Authorization header missing' });

  const token = authHeader.split(' ')[1]; 
  if (!token) return res.status(401).json({ error: 'Token missing' });

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = user; // attach user data to request
    next();
  });
};

// route
const bookRoutes = require('./routes/book');
const signUpRoutes = require('./routes/auth/register');
const signInRoutes = require('./routes/auth/login');
const bookProgressRoutes = require('./routes/book'); 
const reviewRoutes = require('./routes/review'); 
const userDataRoutes = require('./routes/fetchData/userData')
const followerRoutes = require('./routes/follower')
const historyRoutes = require('./routes/history')

app.use(express.urlencoded({ extended: true }));

//public route
app.use('/api/auth/register', signUpRoutes);
app.use('/api/auth/login', signInRoutes);

// Protected Route (Requires Login)
app.use('/api/fetchData/userData',verifyToken, userDataRoutes);
app.use('/api/books/progress', verifyToken, bookProgressRoutes);
app.use('/api/review', verifyToken, reviewRoutes);
app.use('/api/follower', verifyToken, followerRoutes);
app.use('/api/history', verifyToken, historyRoutes);

app.use((req, res, next) => {
  res.status(404).json({ error: 'Resource not found' });
});

app.use((err, req, res, next) => {
  console.error("Global Error Handler Caught:", err);
  // Handle Mongoose Validation Errors
  if (err.name === 'ValidationError') {
      return res.status(400).json({ error: err.message });
  }
   // Handle Mongoose Cast Errors (e.g., invalid ObjectId)
  if (err.name === 'CastError') {
     return res.status(400).json({ error: `Invalid ID format for field ${err.path}` });
  }
    // Handle Duplicate Key Errors (e.g., unique index violation)
  if (err.code === 11000) {
     return res.status(409).json({ error: `Duplicate key error: A record with this value already exists.` });
  }

  const statusCode = err.statusCode || err.status || 500;
  const message = err.message || 'Internal Server Error';

});

const PORT = process.env.PORT || 5050;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});