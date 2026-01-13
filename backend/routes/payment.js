const express = require('express');
const router = express.Router();
const Razorpay = require('razorpay');
const crypto = require('crypto');
const Order = require('../models/Order');

let rzp = null;
if (process.env.RAZORPAY_KEY_ID && process.env.RAZORPAY_KEY_SECRET) {
  rzp = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
  });
} else {
  console.warn('RAZORPAY_KEY_ID or RAZORPAY_KEY_SECRET not set; payment endpoints will return errors until configured.');
}

// Create Razorpay order and save local Order with status PENDING
router.post('/create-order', async (req, res) => {
  try {
    const { items, amount, currency = 'INR', customer } = req.body;
    if (!amount || !customer) return res.status(400).json({ error: 'amount and customer required' });

    // amount must be in paise
    if (!rzp) return res.status(500).json({ error: 'razorpay_keys_not_configured' });

    const options = {
      amount: amount,
      currency: currency,
      receipt: `rcpt_${Date.now()}`,
      payment_capture: 1
    };

    const razorpayOrder = await rzp.orders.create(options);

    // Try to save to database, but continue even if DB is not available
    let orderDbId = null;
    try {
      const order = new Order({
        items: items || [],
        amount: amount,
        currency: currency,
        customer: customer,
        razorpay_order_id: razorpayOrder.id,
        status: 'PENDING'
      });
      const savedOrder = await order.save();
      orderDbId = savedOrder._id;
    } catch (dbErr) {
      console.warn('Database not available, order not persisted:', dbErr.message);
      // Continue without DB - payment will still work
    }

    res.json({
      id: razorpayOrder.id,
      amount: razorpayOrder.amount,
      currency: razorpayOrder.currency,
      receipt: razorpayOrder.receipt,
      order_db_id: orderDbId
    });
  } catch (err) {
    console.error('create-order error:', err.error || err.message || err);
    console.error('Full Razorpay error:', JSON.stringify(err, null, 2));
    res.status(500).json({ error: 'internal_error', details: err.error || err.message });
  }
});

// Create COD order (no Razorpay needed)
router.post('/create-cod-order', async (req, res) => {
  try {
    const { items, amount, currency = 'INR', customer, paymentMethod } = req.body;
    if (!amount || !customer) return res.status(400).json({ error: 'amount and customer required' });

    // Create order directly in database with COD status
    const order = new Order({
      items: items || [],
      amount: amount,
      currency: currency,
      customer: customer,
      paymentMethod: paymentMethod || 'COD',
      status: 'COD_PENDING', // Will be marked as PAID when delivered
      razorpay_order_id: null,
      razorpay_payment_id: null,
      razorpay_signature: null,
    });

    const savedOrder = await order.save();

    res.json({
      success: true,
      orderId: savedOrder._id,
      message: 'COD order placed successfully',
      order: {
        id: savedOrder._id,
        amount: savedOrder.amount,
        currency: savedOrder.currency,
        status: savedOrder.status,
        customer: savedOrder.customer,
        items: savedOrder.items,
      }
    });
  } catch (err) {
    console.error('create-cod-order error:', err);
    res.status(500).json({ error: 'internal_error', details: err.message });
  }
});

// Verify payment signature (called after payment success on frontend)
router.post('/verify-payment', async (req, res) => {
  try {
    console.log('=== PAYMENT VERIFICATION REQUEST ===');
    console.log('Request body:', JSON.stringify(req.body, null, 2));

    const { razorpay_order_id, razorpay_payment_id, razorpay_signature, order_db_id } = req.body;

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      console.error('Missing fields:', { razorpay_order_id, razorpay_payment_id, razorpay_signature });
      return res.status(400).json({ verified: false, error: 'missing_fields' });
    }

    if (!process.env.RAZORPAY_KEY_SECRET) {
      console.error('RAZORPAY_KEY_SECRET not configured');
      return res.status(500).json({ verified: false, error: 'razorpay_secret_not_configured' });
    }

    // Generate signature to verify
    const generated_signature = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');

    console.log('Signature comparison:');
    console.log('Generated:', generated_signature);
    console.log('Received:', razorpay_signature);
    console.log('Match:', generated_signature === razorpay_signature);

    const isValid = generated_signature === razorpay_signature;

    if (!isValid) {
      console.error('❌ Signature invalid');
      return res.status(400).json({ verified: false, error: 'invalid_signature' });
    }

    console.log('✅ Signature valid');

    // Try to update order in database if available
    try {
      let order = null;
      if (order_db_id) {
        console.log('Looking for order by DB ID:', order_db_id);
        order = await Order.findById(order_db_id);
      }

      if (!order && razorpay_order_id) {
        console.log('Looking for order by Razorpay order ID:', razorpay_order_id);
        order = await Order.findOne({ razorpay_order_id });
      }

      if (order) {
        console.log('Order found, updating status');
        order.status = 'PAID';
        order.paymentMethod = order.paymentMethod || 'Online';
        order.razorpay_payment_id = razorpay_payment_id;
        order.razorpay_signature = razorpay_signature;
        order.paymentTimestamp = new Date();
        await order.save();
        console.log('Order saved successfully');
        return res.json({
          verified: true,
          orderId: order._id,
          message: 'Payment verified and order updated'
        });
      } else {
        console.warn('Order not found in database, but signature is valid');
        // Return success anyway since signature is valid
        return res.json({
          verified: true,
          message: 'Payment verified (database unavailable)',
          razorpay_order_id,
          razorpay_payment_id
        });
      }
    } catch (dbErr) {
      console.warn('Database error, but signature is valid:', dbErr.message);
      // Return success anyway since signature is valid
      return res.json({
        verified: true,
        message: 'Payment verified (database unavailable)',
        razorpay_order_id,
        razorpay_payment_id
      });
    }
  } catch (err) {
    console.error('❌ verify-payment error:', err);
    console.error('Error stack:', err.stack);
    res.status(500).json({ verified: false, error: 'internal_error', details: err.message });
  }
});

// Get all orders (for order management)
router.get('/orders', async (req, res) => {
  try {
    const orders = await Order.find().sort({ createdAt: -1 });
    res.json({ success: true, orders });
  } catch (err) {
    console.error('get-orders error', err);
    res.status(500).json({ error: 'internal_error' });
  }
});

// Get specific order by ID
router.get('/orders/:id', async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ error: 'order_not_found' });
    res.json({ success: true, order });
  } catch (err) {
    console.error('get-order error', err);
    res.status(500).json({ error: 'internal_error' });
  }
});

module.exports = router;
