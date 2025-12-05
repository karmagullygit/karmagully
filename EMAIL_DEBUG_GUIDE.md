# Email Notification Debugging Guide

## Issue: Not Receiving Emails After Order Placement

### Step 1: Verify Vercel Environment Variables

The most common cause is missing environment variables in Vercel. You need to:

1. Go to: https://vercel.com/dashboard
2. Select your **karmagully** project
3. Go to **Settings** → **Environment Variables**
4. Verify these variables exist and have correct values:
   - `RESEND_API_KEY` - Your Resend API key (starts with `re_`)
   - `FROM_EMAIL` - Should be `onboarding@resend.dev` (or verified domain)
   - `FROM_NAME` - Should be `KarmaGully`
   - `ADMIN_EMAIL` - Should be `karmagully0@gmail.com`

**If any are missing**, add them now. The API key is the most critical one.

### Step 2: Verify Resend API Key is Valid

1. Go to: https://resend.com/api-tokens
2. Check if your API key is still valid and active
3. If expired or missing, create a new one and update it in Vercel

### Step 3: Check Vercel Function Logs

To see if the function is even being called:

1. Go to: https://vercel.com/dashboard
2. Select **karmagully** project
3. Go to **Deployments**
4. Click on the latest deployment
5. Go to **Functions** tab
6. Look for `send_order_notification.js`
7. Check the **Logs** to see if the function is being invoked

### Step 4: Check Resend Email Logs

If the function is being called, check if Resend is actually sending:

1. Go to: https://resend.com/emails
2. Look for recent emails to `karmagully0@gmail.com` or your test email
3. Check the delivery status (Success/Failed/Bounced)
4. If failed, click on the email to see the error reason

### Step 5: Test the API Endpoint Directly

You can test the endpoint using curl or Postman:

```bash
curl -X POST https://karmagully.vercel.app/api/send_order_notification \
  -H "Content-Type: application/json" \
  -d '{
    "order": {
      "id": "test-order-123",
      "customerName": "Test User",
      "customerEmail": "your.email@gmail.com",
      "customerPhone": "9876543210",
      "totalAmount": 500,
      "items": [
        {
          "product": {
            "id": "p1",
            "name": "Test Product",
            "price": 500
          },
          "quantity": 1
        }
      ],
      "shippingAddress": "123 Test St"
    }
  }'
```

If you get a 202 response, the function executed. Check your email inbox.

### Step 6: Redeploy to Vercel

After making changes, redeploy:

```bash
cd c:\Flutter KarmaShop\Karma_mobile6\karma_shop
git add .
git commit -m "Fix product field name in email API"
git push
```

Vercel will auto-deploy on git push.

### Step 7: Check App Logs

When you place an order in the app, check the Flutter console logs:

- Look for: `NotificationService: serverless endpoint accepted the notification`
- Or: `NotificationService: serverless returned 202 ...`
- Or: `NotificationService: error calling serverless endpoint: ...`

These will tell you if the app successfully called Vercel.

---

## Common Issues & Solutions

### ❌ "Resend API key not configured"
**Solution**: Add `RESEND_API_KEY` to Vercel Environment Variables

### ❌ "Product is undefined" in email
**Solution**: Already fixed - changed `it.product.title` to `it.product.name`

### ❌ "Invalid email" error from Resend
**Solution**: Use `onboarding@resend.dev` for FROM_EMAIL until you verify a custom domain

### ❌ Getting 404 error in app logs
**Solution**: Function path is wrong. Verify `/api/send_order_notification.js` exists in repo and is deployed

### ❌ 500 error with "Server error"
**Solution**: Check Vercel function logs for the actual error message

---

## Quick Checklist

- [ ] Vercel environment variables all set (especially RESEND_API_KEY)
- [ ] RESEND_API_KEY is valid and active
- [ ] `api/send_order_notification.js` exists and is deployed
- [ ] `api/package.json` has resend dependency
- [ ] Latest code pushed to GitHub
- [ ] Vercel shows successful deployment
- [ ] Product field changed from `title` to `name`

If everything is checked and still not working, share:
1. The error from app logs (screenshot or copy-paste)
2. The Vercel function logs (screenshot)
3. Resend email status (screenshot)
