const express = require('express');
const Alert = require('../models/Alert');
const { authMiddleware } = require('../middleware/auth');
const router = express.Router();

router.get('/', authMiddleware, async (req, res) => {
  try {
    const alerts = await Alert.find({ userId: req.user.id })
      .populate('relatedPredictionId', 'title status trend')
      .sort({ createdAt: -1 })
      .limit(20);
    res.json(alerts);
  } catch (error) {
    res.status(500).json({ message: 'Error obteniendo alertas' });
  }
});

router.put('/:id/read', authMiddleware, async (req, res) => {
  try {
    const alert = await Alert.findByIdAndUpdate(req.params.id, { read: true }, { new: true });
    res.json(alert);
  } catch (error) {
    res.status(500).json({ message: 'Error marcando alerta como leída' });
  }
});

router.get('/unread/count', authMiddleware, async (req, res) => {
  try {
    const count = await Alert.countDocuments({ userId: req.user.id, read: false });
    res.json({ unreadCount: count });
  } catch (error) {
    res.status(500).json({ message: 'Error obteniendo contador' });
  }
});

module.exports = router;
