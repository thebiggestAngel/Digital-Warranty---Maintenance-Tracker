# 🔧 Digital Warranty & Maintenance Tracker

> 📱 On-chain warranty and maintenance records for consumer devices

## 🌟 Overview

The Digital Warranty & Maintenance Tracker is a Clarity smart contract that revolutionizes how device warranties and service records are managed. By leveraging blockchain technology, we create an immutable, transparent, and fraud-resistant system for tracking device ownership, warranties, and maintenance history.

## ❗ Problem

- 🔍 Consumers lose warranty documents and service receipts
- 🏪 Service centers lack reliable maintenance history
- 💸 Resale values suffer due to unverifiable service records
- 🚫 Warranty fraud is difficult to prevent

## ✅ Solution

- 📖 **Immutable Records**: All warranty and service data stored on-chain
- 🔐 **Ownership Verification**: Cryptographic proof of device ownership
- 📝 **Service History**: Complete maintenance timeline with costs and parts
- 🔄 **Transfer Support**: Seamless ownership transfers with history preservation

## 🚀 Features

### Device Management
- ✨ **Register Device**: Add new devices with warranty information
- 🔄 **Transfer Ownership**: Secure ownership transfers with price tracking
- ❌ **Deactivate Device**: Mark devices as inactive when needed

### Warranty Tracking
- ⏰ **Warranty Validation**: Check if warranty is still active
- 📅 **Remaining Time**: Calculate remaining warranty period
- 🔧 **Warranty Extension**: Extend warranty duration

### Service Records
- 📋 **Add Service Records**: Log maintenance, repairs, and part replacements
- 💰 **Cost Tracking**: Track service costs and next service dates
- 🔍 **Service History**: View complete maintenance timeline

### Data Access
- 📊 **Device Information**: Retrieve complete device details
- 👤 **Ownership History**: Track all previous owners
- 🔍 **Service Lookup**: Query service records by device

## 🛠️ Usage

### Registering a New Device

```clarity
(contract-call? .digital-warranty-tracker register-device
  "Apple"           ;; manufacturer
  "iPhone 14 Pro"   ;; model  
  "A1234567890"     ;; serial number
  u52560            ;; warranty duration (blocks ≈ 1 year)
  "Limited"         ;; warranty type
  u999              ;; purchase price (STX)
)
```

### Adding a Service Record

```clarity
(contract-call? .digital-warranty-tracker add-service-record
  u1                        ;; device ID
  "Screen Replacement"      ;; service type
  u150                      ;; service cost (STX)
  "Cracked screen repair"   ;; description
  "Display Assembly"        ;; parts replaced
  (some u2628)             ;; next service due (optional)
)
```

### Transferring Ownership

```clarity
(contract-call? .digital-warranty-tracker transfer-ownership
  u1                                      ;; device ID
  'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KX0RQ2H9  ;; new owner
  (some u500)                             ;; transfer price (optional)
)
```

### Checking Warranty Status

```clarity
(contract-call? .digital-warranty-tracker is-warranty-valid u1)
(contract-call? .digital-warranty-tracker get-warranty-remaining u1)
```

## 🏗️ Contract Structure

### Data Maps
- **devices**: Core device information and warranty details
- **device-services**: Complete service and maintenance records  
- **device-ownership-history**: Transfer history with timestamps
- **user-devices**: User-device ownership mapping

### Key Functions

#### Public Functions
- `register-device` - Register new device with warranty
- `add-service-record` - Add maintenance/repair records
- `transfer-ownership` - Transfer device to new owner
- `deactivate-device` - Mark device as inactive
- `extend-warranty` - Extend warranty period

#### Read-Only Functions  
- `get-device-info` - Retrieve device details
- `is-warranty-valid` - Check warranty status
- `get-warranty-remaining` - Calculate remaining warranty
- `get-ownership-history` - View transfer history
- `is-device-owner` - Verify ownership

## 🔐 Security Features

- ✅ **Authorization Checks**: Only owners can modify their devices
- 🛡️ **Input Validation**: Proper validation of all parameters
- 🚫 **Error Handling**: Comprehensive error codes and messages
- 🔒 **Access Control**: Contract owner privileges for extensions

## 📈 Benefits

### For Consumers
- 📱 **Digital Receipts**: Never lose warranty documents again
- 💰 **Higher Resale Value**: Proven maintenance history increases value
- 🔍 **Easy Verification**: Instant warranty status checks
- 🏪 **Service Transparency**: Complete service history visibility

### For Service Providers
- 📋 **Reliable History**: Access to complete maintenance records
- 💼 **Fraud Prevention**: Cryptographic proof prevents fake claims
- 🔄 **Streamlined Process**: Automated warranty validation
- 📊 **Business Insights**: Track service patterns and costs

### For Manufacturers
- 📈 **Brand Trust**: Transparent warranty management
- 🔍 **Product Insights**: Real-world usage and failure data
- 🛡️ **Fraud Reduction**: Immutable warranty records
- 🤝 **Customer Relations**: Enhanced post-sale service

## 🏃‍♂️ Getting Started

1. **Deploy Contract**
   ```bash
   clarinet console
   ::deploy_contract Digital-Warranty---Maintenance-Tracker
   ```

2. **Register Your Device**
   ```bash
   ::call Digital-Warranty---Maintenance-Tracker register-device "Samsung" "Galaxy S23" "SN123456" u26280 "Standard" u800
   ```

3. **Check Device Info**
   ```bash
   ::call Digital-Warranty---Maintenance-Tracker get-device-info u1
   ```

## 🧪 Testing

Run the test suite:
```bash
npm install
npm test
```

## 📄 License

MIT License - see LICENSE file for details

## 🤝 Contributing

Contributions welcome! Please read our contributing guidelines and submit pull requests.

---

*Built with ❤️ using Clarity and Stacks blockchain*
