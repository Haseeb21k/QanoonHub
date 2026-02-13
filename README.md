# QanoonHub

A comprehensive case and task management system designed for law firms to streamline operations, improve productivity, and enhance client relationships.

## Overview

**QanoonHub** is a web-based platform that enables legal professionals to efficiently manage cases, deadlines, client communications, and staff tasks. The system provides an intuitive interface for partners, associates, paralegals, and clients to collaborate effectively.

## Key Features

- **Client Relationship Management (CRM)** - Manage client information, interactions, and case history
- **Case Management** - Create, assign, and track cases with detailed information
- **Document Management** - Upload, store, and share case-related documents securely
- **Task Management** - Assign tasks, set deadlines, and track progress
- **Appointment Scheduling** - Schedule and manage appointments with automated reminders
- **Real-time Messaging** - Communicate with team members and clients via Socket.io
- **Notifications & Alerts** - Receive alerts for important dates, deadlines, and events

## Tech Stack

### Backend
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MongoDB
- **Authentication:** JWT with bcrypt password hashing
- **Real-time:** Socket.io

### Frontend
- **Framework:** React (Vite)
- **Styling:** CSS/Tailwind CSS
- **Icons:** iOS16 Glyph (Icons8)

## Project Structure

```
LawFirm_Management/
├── app.js                 # Main application entry point
├── controllers/          # Route controllers
├── models/              # MongoDB schemas
├── routes/              # API routes
├── middlewares/         # Authentication & validation
├── helpers/             # Utility functions
├── socketHandler/       # Real-time chat handlers
├── frontend/            # React frontend application
└── uploads/             # File storage
```

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd LawFirm_Management
   ```

2. **Install dependencies**
   ```bash
   npm install
   cd frontend && npm install
   ```

3. **Configure environment variables**
   Create a `.env` file in the root directory with:
   ```
   MONGODB_URI=<your-mongodb-connection-string>
   JWT_SECRET=<your-jwt-secret>
   PORT=5000
   ```

4. **Run the application**
   ```bash
   # Backend
   npm start

   # Frontend (in a separate terminal)
   cd frontend && npm run dev
   ```

## User Roles

- **Partners** - Full administrative access, case assignments, staff management
- **Associates** - Case handling, document management, task completion
- **Paralegals** - Support staff with task and document management capabilities
- **Clients** - View case progress, upload documents, communicate with legal team

## Security Features

- HTTPS encryption for data transmission
- Secure cookie management with HttpOnly and Secure flags
- Password hashing with bcrypt
- CORS policy enforcement
- MongoDB authentication and role-based access control
- TLS/SSL encryption for database connections

## API Documentation

The application uses RESTful API design with standard HTTP methods:
- `GET` - Retrieve resources
- `POST` - Create new resources
- `PUT` - Update existing resources
- `DELETE` - Remove resources

Test API endpoints using tools like Postman or Thunder Client.

## License

This project is licensed under the terms specified in [LICENSE.md](LICENSE.md).

## Contributors

Developed as a Web Engineering and Technologies project for law firm case management.

---

For detailed setup instructions and troubleshooting, see:
- [CHAT_SETUP.md](CHAT_SETUP.md)
- [CHAT_TROUBLESHOOTING.md](CHAT_TROUBLESHOOTING.md)