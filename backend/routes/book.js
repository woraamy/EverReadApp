// File: routes/bookProgressRoutes.js
const express = require('express');
const router = express.Router();
const { body, param, validationResult } = require('express-validator');
const Book = require('../models/Book'); // Adjust path if necessary
const History = require('../models/History'); // Adjust path if necessary

const BookStatusValues = ["want to read", "currently reading", "finished"];
const HistoryActionMap = {
  "want to read": "add want to read",
  "currently reading": "add currently reading",
  "finished": "add finished"
};

const mapToSwiftBookFormat = (userBookDoc) => {
  // Assuming userBookDoc is a Mongoose document.
  // And userBookDoc directly contains fields like api_id, title, authors, thumbnailUrl, etc.
  // OR userBookDoc has an embedded volumeInfo.
  if (userBookDoc.volumeInfo && userBookDoc.api_id) { // Ideal case: schema matches Swift expectation
      return {
          id: userBookDoc.api_id, // Or userBookDoc.id if that's how api_id is stored as primary key for this item
          volumeInfo: {
              title: userBookDoc.volumeInfo.title,
              authors: userBookDoc.volumeInfo.authors, // Assuming authors is an array
              imageLinks: {
                  thumbnail: userBookDoc.volumeInfo.imageLinks?.thumbnail, // Optional chaining for safety
                  smallThumbnail: userBookDoc.volumeInfo.imageLinks?.smallThumbnail
              },
              description: userBookDoc.volumeInfo.description,
              pageCount: userBookDoc.volumeInfo.pageCount,
              publishedDate: userBookDoc.volumeInfo.publishedDate,
              publisher: userBookDoc.volumeInfo.publisher,
              averageRating: userBookDoc.volumeInfo.averageRating,
              ratingsCount: userBookDoc.volumeInfo.ratingsCount
              // Add any other fields your Swift VolumeInfo expects
          }
          // You could also include user-specific progress here if needed by the client for these views
          // userProgress: {
          //   currentPage: userBookDoc.current_page,
          //   status: userBookDoc.status
          // }
      };
  }
  // Fallback: if UserBook schema is flatter and needs mapping to {id, volumeInfo}
  // This part needs to be adjusted based on your ACTUAL UserBook schema.
  // This is a common scenario if you denormalized Google Books data.
  return {
      id: userBookDoc.api_id, // Or however you store the Google Books ID
      volumeInfo: {
          title: userBookDoc.title,
          authors: userBookDoc.authors || [], // Ensure it's an array
          imageLinks: {
              thumbnail: userBookDoc.thumbnailUrl || userBookDoc.imageLinks?.thumbnail, // Prioritize specific thumbnailUrl if available
              smallThumbnail: userBookDoc.smallThumbnailUrl || userBookDoc.imageLinks?.smallThumbnail
          },
          description: userBookDoc.description,
          pageCount: userBookDoc.pageCount,
          // Add other VolumeInfo fields if they are stored directly on UserBook
      }
  };
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

      // Log history if status changed implicitly or explicitly due to page update
      if (book.status !== originalStatus) {
          const historyActionString = HistoryActionMap[book.status];
          if(historyActionString) {
            // Avoid duplicate "currently reading" if it was already set or if it's a minor page update within "currently reading"
            // This logic might need refinement based on exact desired history logging behavior
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
  '/:api_id', // Route parameter for the Google Books API ID
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
        // If the book is not found in the user's collection,
        // it means they haven't added it to any shelf yet.
        // Return 404 or a specific response indicating this.
        return res.status(404).json({ msg: 'Book not found on your shelf.' });
      }

      res.json(bookProgress); // Send the found book document

    } catch (err) {
      console.error(`Error in GET /api/books/progress/${api_id}:`, err.message);
      if (err.name === 'CastError' && err.path === '_id') { // Example of specific error handling
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
          status: 'currently reading' // Matches BookReadingStatus.rawValue
      }).sort({ added_date: -1 }); // Optional: sort by most recently added

      if (!books) {
          return res.json([]); // Return empty array if no books found, not an error
      }

      // // Map to the format expected by Swift client (id + volumeInfo)
      // const formattedBooks = books.map(mapToSwiftBookFormat);
      res.json(books);

  } catch (err) {
      console.error('Error in GET /shelf/currently-reading:', err.message);
      res.status(500).send('Server Error');
  }
});

// GET want-to-read books
router.get('/shelf/want-to-read', async (req, res) => {
  // console.log("route hit???")
  // console.log('req.user', req.user)
  // console.log('req.user.userId', req.user.userId)
  // console.log('req.body', req.body)
  try {
      if (!req.user || !req.user.userId) {
          return res.status(401).json({ msg: 'User not authenticated.' });
      }

      const books = await Book.find({
          user_id: req.user.userId,
          status: 'want to read' // Matches BookReadingStatus.rawValue
      }).sort({ added_date: -1 }); // Optional: sort

      if (!books) {
          return res.json([]);
      }
      console.log('books', books)
      // const formattedBooks = books.map(mapToSwiftBookFormat);
      res.json(books);

  } catch (err) {
      console.error('Error in GET /shelf/want-to-read:', err.message);
      res.status(500).send('Server Error');
  }
  
});

module.exports = router;


