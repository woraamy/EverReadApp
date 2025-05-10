
const express = require('express');
const router = express.Router();
const { body, param, validationResult } = require('express-validator');
const Book = require('../models/Book'); 
const History = require('../models/History'); 

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
    console.log('req.body', req.body)

    const {
      api_id,
      name,
      author,
      page_count,
      status     
    } = req.body;

    try {
      let bookUpdatePayload = {
        user_id: userIdFromToken,
        api_id: api_id,
        name: name,
        author: author,
        status: status,
      };

      if (page_count !== undefined && page_count !== null && !isNaN(parseInt(page_count))) {
        bookUpdatePayload.page_count = parseInt(page_count, 10);
      } else {
        const existingBook = await Book.findOne({ user_id: userIdFromToken, api_id: api_id });
        bookUpdatePayload.page_count = existingBook ? existingBook.page_count : null;
      }

      if (status === 'want to read') {
        bookUpdatePayload.current_page = 0;
      } else if (status === 'currently reading') {
        bookUpdatePayload.current_page = 0; 
      } else if (status === 'finished') {
        if (bookUpdatePayload.page_count !== null && bookUpdatePayload.page_count > 0) {
          bookUpdatePayload.current_page = bookUpdatePayload.page_count; 
        } else {
          bookUpdatePayload.current_page = 0; 
        }
      }

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
    body('api_id', 'Book API ID (api_id) is required').not().isEmpty().trim(),
    body('current_page', 'Current page is required and must be a non-negative number').isInt({ min: 0 })
  ],
  async (req, res) => {
    console.log("route hit")
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    console.log('req.body', req.body)

    if (!req.user || !req.user.userId) {
        return res.status(401).json({ error: 'User not authenticated or userId missing from token.' });
    }
    const userIdFromToken = req.user.userId;

    const { api_id, current_page } = req.body;
    const newCurrentPage = parseInt(current_page, 10);

    try {
      const book = await Book.findOne({ user_id: userIdFromToken, api_id: api_id });

      if (!book) {
        return res.status(404).json({ msg: 'Book not found in your collection. Add or set its status first.' });
      }
      
      let originalStatus = book.status; // Keep track of original status

      if (book.status === 'want to read' && newCurrentPage > 0) {
          book.status = 'currently reading'; 
      }

      if (book.page_count !== null && newCurrentPage > book.page_count) {
        return res.status(400).json({ errors: [{ msg: `Current page (${newCurrentPage}) cannot exceed total page count (${book.page_count}).` }] });
      }

      book.current_page = newCurrentPage;
      let statusChangedToFinishedDueToPageUpdate = false;

      if (book.page_count !== null && newCurrentPage >= book.page_count) {
        if (book.status !== 'finished') { 
            book.status = 'finished';
            statusChangedToFinishedDueToPageUpdate = true;
        }
      } else if (book.status === 'finished' && book.page_count !== null && newCurrentPage < book.page_count) {
        book.status = 'currently reading';
      }
      
      await book.save();

      if (book.status !== originalStatus) {
          const historyActionString = HistoryActionMap[book.status];
          if(historyActionString) {
            if(!(originalStatus === 'currently reading' && book.status === 'currently reading' && !statusChangedToFinishedDueToPageUpdate)) {
                 const newHistoryEntry = new History({ action: historyActionString, user_id: userIdFromToken, book_id: book._id, api_id: api_id });
                 await newHistoryEntry.save();
            }
          }
      }


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

// GET /api/books/progress/:api_id - Get the progress of a specific book
router.get(
  '/:api_id', 
  [
    param('api_id', 'Book API ID in path is required').not().isEmpty().trim()
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
    const { api_id } = req.params;

    try {
      const bookProgress = await Book.findOne({ 
        user_id: userIdFromToken, 
        api_id: api_id 
      });

      if (!bookProgress) {
        return res.status(404).json({ msg: 'Book not found on your shelf.' });
      }

      res.json(bookProgress); 

    } catch (err) {
      console.error(`Error in GET /api/books/progress/${api_id}:`, err.message);
      if (err.name === 'CastError' && err.path === '_id') { 
          return res.status(400).json({ error: 'Invalid API ID format.' });
      }
      res.status(500).send('Server Error');
    }
  }
);

// GET /api/books/progress/shelf/currently-reading - Get all books the user is currently reading
router.get('/shelf/currently-reading', async (req, res) => {
  try {
      if (!req.user || !req.user.userId) {
          return res.status(401).json({ msg: 'User not authenticated.' });
      }

      const books = await Book.find({
          user_id: req.user.userId,
          status: 'currently reading' 
      }).sort({ added_date: -1 });

      if (!books) {
          return res.json([]); 
      }

      res.json(books);

  } catch (err) {
      console.error('Error in GET /shelf/currently-reading:', err.message);
      res.status(500).send('Server Error');
  }
});

// GET want-to-read books
router.get('/shelf/want-to-read', async (req, res) => {
  try {
      if (!req.user || !req.user.userId) {
          return res.status(401).json({ msg: 'User not authenticated.' });
      }

      const books = await Book.find({
          user_id: req.user.userId,
          status: 'want to read' 
      }).sort({ added_date: -1 }); // Optional: sort

      if (!books) {
          return res.json([]);
      }
      res.json(books);

  } catch (err) {
      console.error('Error in GET /shelf/want-to-read:', err.message);
      res.status(500).send('Server Error');
  }
  
});


// GET finished books
router.get('/shelf/finished', async (req, res) => {
  try {
      if (!req.user || !req.user.userId) {
          return res.status(401).json({ msg: 'User not authenticated.' });
      }

      const books = await Book.find({
          user_id: req.user.userId,
          status: 'finished' 
      }).sort({ added_date: -1 }); // sort by most recently added

      if (!books) {
          return res.json([]);
      }
      res.json(books);

  } catch (err) {
      console.error('Error in GET /shelf/want-to-read:', err.message);
      res.status(500).send('Server Error');
  }
  
});

module.exports = router;


