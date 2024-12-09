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

1. Install Dependencies
      ```bash
       flutter pub get


2. Set Up Environment Variables

To securely store sensitive data like API keys and Firebase configuration, use environment variables.

### Step 1: Create a `.env` File
1. Create a file named `.env` in the root of the project directory.
2. Add the required environment variables. Below is an example of what the `.env` file should look like:

    ```env
    GO_UPC_API_BASE_URL=
    GO_UPC_API_KEY=
    MANUFACTURER_API_KEY=your_manufacturer_api_key
    ```

### Step 2: Exclude `.env` from Version Control
To ensure the `.env` file is not committed to the repository, add it to `.gitignore`:

```plaintext
.env
