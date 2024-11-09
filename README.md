# Product Safety Verification App

This Flutter app allows users to verify product authenticity and expiration dates through barcode scanning, ensuring consumer safety in informal markets.

## Features

- **Barcode Scanning**: Scan product barcodes to retrieve information.
- **Product Validation**: Verify product details using GS1 and manufacturer APIs.
- **Flagging and Reporting**: Report expired or counterfeit products.
- **Subscription Plans**: Options for consumers, business owners, and health authorities.
- **Notifications**: Real-time alerts for health inspectors on flagged products.
- **Payment Integration**: Secure recurring payments through Ozow.

## Configuration

Environment variables for API keys and base URLs are managed with `flutter_dotenv`.

1. Add keys to `.env` file:
   ```env
   API_BASE_URL=https://api.example.com
   GO_UPC_API_BASE_URL=your_go_upc_api_key
