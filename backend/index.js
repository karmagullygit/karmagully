require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
const paymentRoutes = require('./routes/payment');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 4000;

// Connect MongoDB if URI provided; otherwise skip with a warning
if (process.env.MONGODB_URI) {
  mongoose.connect(process.env.MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log('MongoDB connected'))
    .catch(err => console.error('MongoDB connection error', err));
} else {
  console.warn('MONGODB_URI not set; skipping MongoDB connection. Orders will not be persisted until configured.');
}

// Regular JSON body parsing for endpoints other than webhook
app.use(cors());
app.use(bodyParser.json());

// Mount payment API routes
app.use('/api/payment', paymentRoutes);

// Webhook endpoint requires raw body for signature verification
app.post('/api/payment/webhook', express.raw({ type: '*/*' }), async (req, res) => {
  const secret = process.env.RAZORPAY_WEBHOOK_SECRET;
  const signature = req.headers['x-razorpay-signature'];
  const body = req.body; // Buffer
  const cryptoSignature = crypto.createHmac('sha256', secret).update(body).digest('hex');

  if (cryptoSignature !== signature) {
    console.warn('Invalid webhook signature');
    return res.status(400).send('Invalid signature');
  }

  let payload;
  try {
    payload = JSON.parse(body.toString());
  } catch (err) {
    console.error('Webhook JSON parse error', err);
    return res.status(400).send('Bad payload');
  }

  const event = payload.event;
  const Order = require('./models/Order');

  try {
    if (event === 'payment.captured' || event === 'payment.authorized') {
      const payment = payload.payload.payment.entity;
      const razorpay_order_id = payment.order_id;
      const razorpay_payment_id = payment.id;
      const signatureFromWebhook = signature;

      const order = await Order.findOne({ razorpay_order_id });
      if (order) {
        order.status = 'PAID';
        order.razorpay_payment_id = razorpay_payment_id;
        order.razorpay_signature = signatureFromWebhook;
        order.paymentTimestamp = new Date(payment.created_at * 1000);
        await order.save();
      }
    } else if (event === 'payment.failed') {
      const payment = payload.payload.payment.entity;
      const razorpay_order_id = payment.order_id;
      const order = await Order.findOne({ razorpay_order_id });
      if (order) {
        order.status = 'FAILED';
        await order.save();
      }
    } else if (event === 'order.paid') {
      const orderEntity = payload.payload.order.entity;
      const razorpay_order_id = orderEntity.id;
      const order = await Order.findOne({ razorpay_order_id });
      if (order) {
        order.status = 'PAID';
        await order.save();
      }
    }

    res.status(200).json({ ok: true });
  } catch (err) {
    console.error('Webhook handling error', err);
    res.status(500).send('internal_error');
  }
});

app.listen(PORT, () => console.log(`Server listening on ${PORT}`));
