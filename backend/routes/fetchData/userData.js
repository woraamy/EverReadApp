const express = require('express');
const User = require('../../models/User');
const Book = require('../../models/Book');
const Review = require('../../models/Review');
const History = require('../../models/History');
const router = express.Router();
const mongoose = require('mongoose');

// GET /api/fetchData/userData - fetch user data
router.get('/', async (req, res) => {
  try {
    const id = req.user.userId
    const user = await User.findById(id).select('-password');
    if (!user) return res.status(404).json({ error: 'User not found' });
    // console.log('UserID:', userid, 'ObjectId:', id);
    const totalBookread = await Book.countDocuments({user_id: id , status: 'finish'}) || 0
    // console.log(totalBook)
    const reading = await Book.countDocuments({user_id: id, status: 'currently reading'}) || 0
    const review = await Review.countDocuments({user_id: id}) || 0
    
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth();
    const startOfYear = new Date(year, 0, 1); // January 1st, 00:00:00
    const endOfYear = new Date(year + 1, 0, 1); // January 1st of next year
    const yearlyBookread = await History.countDocuments({
                            user_id: id,
                            action: 'add finished',
                            created_at: {
                                $gte: startOfYear,
                                $lt: endOfYear
                            }
    }) || 0; 
    // Start = 1st day of current month
    const startOfMonth = new Date(year, month, 1);
    // End = 30th day of current month (00:00 on the 31st)
    const endOfMonth = new Date(year, month, 31); // JS handles overflow (e.g., Feb 31 becomes Mar 2)
    const monthlyBookread = await History.countDocuments({
        user_id: id,
        action: 'add finished',
        created_at: {
            $gte: startOfMonth,
            $lt: endOfMonth
        }
    }) || 0;
    const totalBook = await Book.find({user_id: id}) 
    const pageRead = totalBook.reduce((sum, book) => {
        return sum + (book.page_count || 0); 
      }, 0) || 0; 
    const getReadingStreak = async (id) => {
        const logs = await History.find({
          user_id: id,
        }).select('created_at').lean();
      
        // Normalize dates to YYYY-MM-DD strings
        const readDays = new Set(
          logs.map(log => {
            const d = new Date(log.created_at);
            d.setHours(0, 0, 0, 0);
            return d.toISOString();
          })
        );
      
        // Count streak from today going backward
        let streak = 0;
        let day = new Date();
        day.setHours(0, 0, 0, 0);
      
        while (readDays.has(day.toISOString())) {
          streak++;
          day.setDate(day.getDate() - 1); // move one day back
        }
      
        return streak;
      };
    const readingStreak = await getReadingStreak(id) || 0;

    res.json({
        id: id,
        username: user.username,
        email: user.email,
        yearly_goal: user.yearly_goal,
        month_goal: user.month_goal,
        created_at: user.created_at,
        book_read :totalBookread,
        reading : reading,
        review : review,
        yearly_book_read : yearlyBookread,
        monthly_book_read : monthlyBookread,
        page_read : pageRead,
        reading_streak : readingStreak
    });
  }
   catch (err) {
    console.error('Error fetching user data:', err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;

