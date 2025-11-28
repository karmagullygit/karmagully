# Karma Shop - E-commerce Flutter App

A simple yet feature-rich e-commerce application built with Flutter, featuring both customer and admin interfaces.

## Features

### Customer Features
- **User Authentication**: Login and registration with demo accounts
- **Product Browsing**: Grid view of products with search and category filtering
- **Product Details**: Detailed product information with image, description, and stock status
- **Shopping Cart**: Add/remove items, adjust quantities, view total
- **Checkout**: Simple order placement process

### Admin Features
- **Admin Dashboard**: Overview with statistics and quick actions
- **Product Management**: Add, edit, delete products with full CRUD operations
- **Stock Monitoring**: Visual indicators for low stock and out of stock items
- **Category Management**: Organize products by categories

## Demo Accounts

### Admin Access
- **Email**: admin@karma.com
- **Password**: admin123

### Customer Access
- **Email**: user@karma.com
- **Password**: user123

## Tech Stack

- **Framework**: Flutter 3.24.0+
- **State Management**: Provider
- **Navigation**: GoRouter
- **UI Components**: Material Design 3
- **Image Caching**: cached_network_image
- **Local Storage**: shared_preferences

## Getting Started

### Prerequisites
- Flutter SDK (3.24.0 or later)
- Android Studio / VS Code
- Android emulator or physical device

### Installation

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

## Usage

### Customer Flow
1. Launch the app (redirects to login screen)
2. Use demo customer credentials or register a new account
3. Browse products on the home screen
4. Search for specific products or filter by category
5. Tap on products to view details
6. Add items to cart and adjust quantities
7. Proceed to checkout from cart screen

### Admin Flow
1. Login with admin credentials
2. Access admin dashboard with overview statistics
3. Navigate to Product Management
4. Add new products or edit existing ones
5. Monitor stock levels and manage inventory
6. Switch to customer view to test the shopping experience

## Future Enhancements

The app is designed to be easily extensible. Planned features include:

1. **Order Management**: Complete order tracking system
2. **Customer Management**: Admin tools for managing customer accounts
3. **Analytics Dashboard**: Sales reports and performance metrics
4. **Payment Integration**: Real payment gateway integration
5. **Advanced Search**: Filters by price range, ratings, etc.
6. **Reviews & Ratings**: Customer feedback system
7. **Real Backend**: Replace mock data with actual API integration
