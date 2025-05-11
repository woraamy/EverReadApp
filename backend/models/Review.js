const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    index: true,
  },
  api_id: { 
    type: String, 
    required: true,
    index: true,
  },
  book_id: { 
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Book',
    required: false,
    index: true,
  },
  rating: { 
    type: Number,
    required: [true, 'Rating is required'],
    min: [1, 'Rating must be at least 1'],
    max: [5, 'Rating cannot be more than 5'], 
  },
  description: {
    type: String,
    trim: true,
  },
  created_at: {
    type: Date,
    default: Date.now,
  },
});

reviewSchema.index({ user_id: 1, book_id: 1 }, { unique: true });

module.exports = mongoose.model('Review', reviewSchema);