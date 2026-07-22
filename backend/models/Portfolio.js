const mongoose = require('mongoose');

const PortfolioSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  totalValue: { type: Number, default: 0 },
  currency: { type: String, default: 'USD' },
  predictions: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Prediction' }],
  performanceHistory: [
    {
      date: { type: Date, required: true },
      value: { type: Number, required: true },
      changePercent: { type: Number, default: 0 },
    },
  ],
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Portfolio', PortfolioSchema);
