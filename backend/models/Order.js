const mongoose = require('mongoose');

const OrderSchema = new mongoose.Schema({
  items: [{
    productId: String,
    name: String,
    quantity: Number,
    price: Number,
    image: String
  }],
  amount: { type: Number, required: true }, // in paise
  currency: { type: String, default: 'INR' },
  customer: {
    name: String,
    email: String,
    phone: String,
    shippingAddress: Object
  },
  status: { type: String, enum: ['PENDING', 'PAID', 'FAILED', 'COD_PENDING'], default: 'PENDING' },
  paymentMethod: { type: String, enum: ['UPI', 'Card', 'COD'], default: 'UPI' },
  razorpay_order_id: String,
  razorpay_payment_id: String,
  razorpay_signature: String,
  paymentTimestamp: Date,
}, { timestamps: true });

module.exports = mongoose.model('Order', OrderSchema);
