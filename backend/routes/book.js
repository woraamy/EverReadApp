const express = require('express');
const Book = require('../models/Book');
// const mongoose = require('mongoose'); 
const router = express.Router();

// POST /api/book - Add a new book
router.post('/', async (req, res, next) => {
  try {
    const { api_id, user_id, name, author, page_count, current_page, status } = req.body;

    if (!name || typeof name !== 'string' || name.trim().length === 0) {
        console.log(req.body)
        console.log("yy")
        return res.status(400).json({ error: 'll name is required' });
    }

    const newBook = new Book({
        api_id: api_id,
        user_id: user_id,
        author: author,
        page_count: page_count,
        current_page: current_page,
        status: status,
        name: name.trim(),
    });

    const savedBook = await newBook.save();

    res.status(201).json(savedBook);
  } catch (err) {
    next(err); 
  }
});

module.exports = router;