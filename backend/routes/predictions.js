const express = require('express');
const Prediction = require('../models/Prediction');
const { authMiddleware, adminOnly } = require('../middleware/auth');
const router = express.Router();

router.get('/', authMiddleware, async (req, res) => {
  try {
    const filter = {};
    if (req.query.status) filter.status = req.query.status;
    if (req.query.trend) filter.trend = req.query.trend;
    if (req.user.role === 'client') {
      filter.createdBy = req.user.id;
    }
    const predictions = await Prediction.find(filter).populate('createdBy', 'name email role');
    res.json(predictions);
  } catch (error) {
    res.status(500).json({ message: 'Error obteniendo predicciones' });
  }
});

router.post('/', authMiddleware, async (req, res) => {
  try {
    const { title, description, amount, probability, trend, category, targetReturn, riskLevel, history } = req.body;
    const prediction = new Prediction({
      title,
      description,
      amount,
      probability,
      trend,
      category: category || 'Acciones',
      targetReturn: targetReturn || 0,
      riskLevel: riskLevel || 'Medio',
      history: history || [],
      createdBy: req.user.id,
    });
    await prediction.save();
    res.status(201).json(prediction);
  } catch (error) {
    res.status(500).json({ message: 'Error creando predicción' });
  }
});

router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const updates = {};
    const allowed = ['title', 'description', 'amount', 'probability', 'trend', 'category', 'targetReturn', 'riskLevel', 'status', 'history'];
    allowed.forEach((field) => {
      if (req.body[field] !== undefined) updates[field] = req.body[field];
    });
    const prediction = await Prediction.findById(req.params.id);
    if (!prediction) return res.status(404).json({ message: 'Predicción no encontrada' });
    if (req.user.role === 'client' && prediction.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ message: 'No autorizado a editar esta predicción' });
    }
    if (req.user.role === 'client' && updates.status) {
      delete updates.status;
    }
    const updated = await Prediction.findByIdAndUpdate(req.params.id, updates, { new: true });
    res.json(updated);
  } catch (error) {
    res.status(500).json({ message: 'Error actualizando predicción' });
  }
});

router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const prediction = await Prediction.findById(req.params.id);
    if (!prediction) return res.status(404).json({ message: 'Predicción no encontrada' });
    if (req.user.role === 'client' && prediction.createdBy.toString() !== req.user.id) {
      return res.status(403).json({ message: 'No autorizado a eliminar esta predicción' });
    }
    await prediction.deleteOne();
    res.json({ message: 'Predicción eliminada' });
  } catch (error) {
    res.status(500).json({ message: 'Error eliminando predicción' });
  }
});

router.put('/:id/status', authMiddleware, adminOnly, async (req, res) => {
  try {
    const { status } = req.body;
    const prediction = await Prediction.findByIdAndUpdate(req.params.id, { status }, { new: true });
    res.json(prediction);
  } catch (error) {
    res.status(500).json({ message: 'Error actualizando estado' });
  }
});

module.exports = router;
