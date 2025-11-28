/**
 * Serverless function to send order notification emails via Resend.
 *
 * Usage:
 * - Deploy to Vercel, Netlify, or any serverless platform that supports Node.js.
 * - Provide environment variables: RESEND_API_KEY, FROM_EMAIL, ADMIN_EMAIL
 * - POST JSON payload with the `order` object (same shape as your app sends).
 */

const { Resend } = require('resend');

exports.handler = async function (event, context) {
  try {
    // Netlify/Vercel compatibility: event.body may contain the JSON string
    const body = event.body ? (typeof event.body === 'string' ? JSON.parse(event.body) : event.body) : {};
    const order = body.order || body;

    if (!order || !order.id) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Invalid payload: missing order' }),
      };
    }

    const RESEND_API_KEY = process.env.RESEND_API_KEY;
    const FROM_EMAIL = process.env.FROM_EMAIL || 'onboarding@resend.dev';
    const FROM_NAME = process.env.FROM_NAME || 'Karma Shop';
    const ADMIN_EMAIL = process.env.ADMIN_EMAIL || 'karmagully0@gmail.com';

    if (!RESEND_API_KEY) {
      return {
        statusCode: 500,
        body: JSON.stringify({ error: 'Resend API key not configured' }),
      };
    }

    const resend = new Resend(RESEND_API_KEY);

    const subject = `New Order Placed — ${order.id}`;
    let text = `A new order was placed in Karma Shop:\n`;
    text += `Order ID: ${order.id}\n`;
    text += `Customer: ${order.customerName || order.userId || 'Unknown'}\n`;
    text += `Email: ${order.customerEmail || 'N/A'}\n`;
    text += `Phone: ${order.customerPhone || 'N/A'}\n`;
    text += `Total: ₹${(order.totalAmount || 0).toFixed ? (order.totalAmount).toFixed(2) : order.totalAmount}\n`;
    text += `Items:\n`;
    if (Array.isArray(order.items)) {
      for (const it of order.items) {
        const title = it.product?.title || it.title || 'Item';
        const qty = it.quantity || 1;
        const price = it.product?.price ?? it.price ?? 'N/A';
        text += `- ${title} x${qty} @ ₹${price}\n`;
      }
    }
    text += `\nShipping address: ${order.shippingAddress || 'N/A'}\n`;
    if (order.notes) text += `\nNotes: ${order.notes}\n`;

    // Build recipient list: admin + customer (if available)
    const recipients = [ADMIN_EMAIL];
    if (order.customerEmail && order.customerEmail.trim()) {
      recipients.push(order.customerEmail);
    }

    const msg = {
      from: `${FROM_NAME} <${FROM_EMAIL}>`,
      to: recipients,
      subject: subject,
      text,
    };

    await resend.emails.send(msg);

    return {
      statusCode: 202,
      body: JSON.stringify({ success: true }),
    };
  } catch (err) {
    console.error('send_order_notification error', err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Server error', details: err.message || err }),
    };
  }
};
