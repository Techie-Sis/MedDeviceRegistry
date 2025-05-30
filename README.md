# MedDeviceRegistry

MedDeviceRegistry is a blockchain-based medical device tracking and certification platform built on Stacks blockchain, ensuring transparent regulatory compliance and device authenticity verification.

## Features

- **Device Registration**: Manufacturers can register medical devices with comprehensive specifications
- **Regulatory Compliance**: FDA and regulatory authority approval tracking
- **Manufacturing Transparency**: Complete visibility of production details and facility information
- **Immutable Records**: Blockchain-based records ensure regulatory data integrity

## Smart Contract Functions

### Administration
- `register-regulatory-authority`: Add authorized regulatory bodies for device approval

### Manufacturer Functions
- `register-medical-device`: Register new medical device with production details
- `get-manufacturer-devices`: View all devices registered by a manufacturer

### Regulatory Approval
- `approve-device`: Regulatory authorities can approve registered devices
- `is-regulatory-authority`: Verify if an address has regulatory authority

### Data Access
- `get-device`: Retrieve complete device information and approval status

## Getting Started

1. Clone this repository
2. Install [Clarinet](https://github.com/hirosystems/clarinet)
3. Run `clarinet check` to verify the contract
4. Deploy using Clarinet or Stacks CLI

## For Manufacturers

Register medical devices by providing:
- Device name and model
- Technical specifications
- Production date
- Manufacturing facility location

## For Regulatory Bodies

Authorized regulators can review and approve devices, ensuring compliance with medical device standards.