// File: routes/bookProgressRoutes.js
const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const Book = require('../models/Book'); // Adjust path if necessary
const History = require('../models/History'); // Adjust path if necessary

const BookStatusValues = ["want to read", "currently reading", "finished"];
const HistoryActionMap = {
  "want to read": "add want to read",
  "currently reading": "add currently reading",
  "finished": "add finished"
};

// POST /api/books/progress/status - Update or add a book's status
router.post(
  '/status',
  [
    // Input validation
    body('api_id', 'Book API ID (api_id) is required').not().isEmpty().trim(),
    body('name', 'Book name/title is required').not().isEmpty().trim(),
    body('author', 'Book author is required').not().isEmpty().trim(),
    body('status', `New status must be one of: ${BookStatusValues.join(', ')}`).isIn(BookStatusValues),
    body('page_count', 'Page count must be a non-negative number if provided').optional({ checkFalsy: true }).isInt({ min: 0 }),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    if (!req.user || !req.user.userId) {
        return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
    }
    const userIdFromToken = req.user.userId;

    const {
      api_id,
      name,
      author,
      page_count, // Total pages for the book (from Google Books API or other source)
      status      // The new target status: "want to read", "currently reading", "finished"
    } = req.body;

    try {
      let bookUpdatePayload = {
        user_id: userIdFromToken,
        api_id: api_id,
        name: name,
        author: author,
        status: status,
      };

      // Set page_count if provided
      if (page_count !== undefined && page_count !== null && !isNaN(parseInt(page_count))) {
        bookUpdatePayload.page_count = parseInt(page_count, 10);
      } else {
        // If not provided, try to preserve existing page_count if book exists, or set to null
        const existingBook = await Book.findOne({ user_id: userIdFromToken, api_id: api_id });
        bookUpdatePayload.page_count = existingBook ? existingBook.page_count : null;
      }

      // Determine current_page based on the new status
      if (status === 'want to read') {
        bookUpdatePayload.current_page = 0;
      } else if (status === 'currently reading') {
        // When setting to 'currently reading', typically start at page 0
        // unless a specific starting page is intended (which would be part of a more complex initial add)
        bookUpdatePayload.current_page = 0; 
      } else if (status === 'finished') {
        if (bookUpdatePayload.page_count !== null && bookUpdatePayload.page_count > 0) {
          bookUpdatePayload.current_page = bookUpdatePayload.page_count; // Mark as fully read
        } else {
          // If finished but page_count is unknown, current_page might be set to 0 or kept as is if book existed.
          // For a new entry without page_count, it's ambiguous. Let's default to 0.
          bookUpdatePayload.current_page = 0; 
        }
      }

      // Upsert logic: Find a book by user_id and api_id.
      // If found, update it. If not, create a new one.
      const updatedOrNewBook = await Book.findOneAndUpdate(
        { user_id: userIdFromToken, api_id: api_id },
        { $set: bookUpdatePayload },
        { new: true, upsert: true, runValidators: true, setDefaultsOnInsert: true }
      );

      // Create a corresponding History entry for the status change
      const historyActionString = HistoryActionMap[status];
      if (historyActionString) {
        const newHistoryEntry = new History({
          action: historyActionString,
          user_id: userIdFromToken,
          book_id: updatedOrNewBook._id,
          api_id: api_id,
        });
        await newHistoryEntry.save();
      } else {
        console.warn(`No history action mapped for status: ${status} for book api_id: ${api_id}`);
      }

      res.json(updatedOrNewBook);

    } catch (err) {
      console.error('Error in POST /api/books/progress/status:', err.message);
      if (err.name === 'ValidationError') {
        const messages = Object.values(err.errors).map(val => val.message);
        return res.status(400).json({ errors: messages });
      }
      res.status(500).send('Server Error');
    }
  }
);

// POST /api/books/progress/page - Update the current page of a book
router.post(
  '/page',
  [
    authMiddleware, // Your authentication middleware
    body('api_id', 'Book API ID (api_id) is required').not().isEmpty().trim(),
    body('current_page', 'Current page is required and must be a non-negative number').isInt({ min: 0 })
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const user_id = req.user.id; // From authMiddleware

    const { api_id, current_page } = req.body;
    const newCurrentPage = parseInt(current_page, 10);

    try {
      const book = await Book.findOne({ user_id: user_id, api_id: api_id });

      if (!book) {
        return res.status(404).json({ msg: 'Book not found in your collection. Add it first using the status endpoint.' });
      }

      // Optionally, enforce that only 'currently reading' books can have page progress updated
      // if (book.status !== 'currently reading') {
      //   return res.status(400).json({ msg: 'Book is not marked as "currently reading". Update status first.' });
      // }

      if (book.page_count !== null && newCurrentPage > book.page_count) {
        return res.status(400).json({ errors: [{ msg: `Current page (${newCurrentPage}) cannot exceed total page count (${book.page_count}).` }] });
      }

      book.current_page = newCurrentPage;
      let statusChangedToFinished = false;

      // If page update means the book is now finished
      if (book.page_count !== null && newCurrentPage >= book.page_count) {
        if (book.status !== 'finished') {
            book.status = 'finished';
            statusChangedToFinished = true;
        }
      } else {
        // If user updates page but it's less than total, ensure status is 'currently reading'
        // (unless it was 'finished' and they are "un-finishing" it, which is a complex case not handled here)
        if (book.status === 'want to read' || book.status === 'finished') { // If it was 'want to read' or 'finished' and now pages are updated
            book.status = 'currently reading'; // Implicitly move to currently reading
            // Consider if a history event is needed for this implicit status change from 'want to read'
        }
      }
      
      await book.save(); // This will run validators

      // If status changed to 'finished' due to page update, log history
      if (statusChangedToFinished) {
        const historyActionString = HistoryActionMap['finished'];
        if (historyActionString) {
          const newHistoryEntry = new History({
            action: historyActionString,
            user_id: user_id,
            book_id: book._id,
            api_id: api_id,
          });
          await newHistoryEntry.save();
        }
      }
      // Note: We are not creating history entries for every single page update,
      // only if it results in the book being marked as 'finished'.

      res.json(book);

    } catch (err) {
      console.error('Error in POST /api/books/progress/page:', err.message);
      if (err.name === 'ValidationError') {
        const messages = Object.values(err.errors).map(val => val.message);
        return res.status(400).json({ errors: messages });
      }
      res.status(500).send('Server Error');
    }
  }
);


module.exports = router;
