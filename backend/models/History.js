const mongoose = require('mongoose');

const HistoryAction = [
  "write a review",
  "add want to read",
  "add currently reading",
  "add finished"
];

const historySchema = new mongoose.Schema({
  action: {
    type: String,
    required: [true, 'Action type is required'],
    enum: {
        values: HistoryAction,
        message: props => `${props.value} is not a valid history action.`
    }
  },
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    index: true,
  },
  book_id: { 
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Book',
    required: false,
    index: true,
  },
  api_id: { 
    type: String,
    index: false,
  },
  created_at: {
    type: Date,
    default: Date.now,
    index: true 
  },
  
});

module.exports = mongoose.model('History', historySchema);