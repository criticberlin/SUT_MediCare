# SUT Medicare App - Firebase Implementation Guide

This document outlines the Firebase Realtime Database structure and implementation details for the SUT Medicare app.

## Database Structure

The database follows a structured pattern for storing users, appointments, chats, messages, and notifications:

```json
{
  "users": {
    "Patients": {
      "userId1": { ... patient data ... }
    },
    "Doctors": {
      "userId2": { ... doctor data ... }
    },
    "userId1": { ... flat structure for quick lookup ... },
    "userId2": { ... flat structure for quick lookup ... }
  },
  "appointments": {
    "appointmentId": {
      "patientId": "userId1",
      "doctorId": "userId2",
      "dateTime": "2023-06-15T10:00:00.000Z",
      "reason": "Checkup",
      "duration": 30,
      "status": "pending",
      "notes": "..."
    }
  },
  "chats": {
    "chatId": {
      "participants": ["userId1", "userId2"],
      "participantsString": "userId1,userId2",
      "lastMessage": "Hello doctor",
      "lastMessageSender": "userId1",
      "lastMessageTime": 1687014552000
    }
  },
  "messages": {
    "chatId": {
      "messageId1": {
        "senderId": "userId1",
        "text": "Hello doctor",
        "read": false,
        "createdAt": 1687014552000
      }
    }
  },
  "notifications": {
    "userId1": {
      "notificationId1": {
        "title": "New Appointment",
        "body": "You have a new appointment with Dr. Smith",
        "type": "appointment",
        "referenceId": "appointmentId",
        "read": false,
        "createdAt": 1687014552000
      }
    }
  }
}
```

## Key Components

### 1. Authentication and User Storage

- Users are stored in a dual structure:
  - Role-based paths (`users/Patients/{uid}` or `users/Doctors/{uid}`)
  - Flat structure (`users/{uid}`) for quick lookups

### 2. Appointment Management

- Appointments store references to both doctor and patient
- Each appointment has a status that can be updated
- When an appointment is created, notifications are sent to both parties
- A chat is automatically created between the doctor and patient if one doesn't exist

### 3. Chat System

- Chats represent communication channels between patients and doctors
- Each chat includes participant information and last message details
- Messages are stored under their respective chat IDs
- Notifications are sent when new messages arrive

### 4. Notification System

- Notifications are stored under user IDs
- Each notification includes a reference ID linking to the relevant entity
- Types include "appointment" and "message"
- Notifications can be marked as read

## Implementation Details

### Services

1. **`AuthService`**
   - Handles user authentication and registration
   - Stores users in the appropriate database location based on role

2. **`AppointmentService`**
   - Manages appointment creation, updates, and querying
   - Creates chats between users when needed
   - Sends appropriate notifications

### Providers

1. **`AuthProvider`**
   - Manages authentication state
   - Provides user data to the UI

2. **`AppointmentProvider`**
   - Connects appointment service to UI
   - Manages appointment, chat, and notification state
   - Sets up streams for real-time updates

## Relations and Consistency

The implementation maintains relational consistency through:

1. **Validation**: Verifying that referenced entities exist before creating new ones
2. **Atomic Updates**: Using Firebase transactions for critical operations
3. **Denormalization**: Strategic duplication of data for performance
4. **Real-time Streams**: Using Firebase's real-time nature for immediate UI updates

## Edge Cases Handling

1. **Missing Users**: Validating existence before operations
2. **Deleted Users**: UI gracefully handles missing user data
3. **Empty Chats**: Showing appropriate placeholders
4. **Error States**: Comprehensive error handling and recovery

## Indexing Recommendations

For optimal performance, the following Firebase indices are recommended:

1. `appointments` by `patientId`
2. `appointments` by `doctorId` 
3. `chats` by `participants`
4. `messages` by `chatId` and `createdAt`
5. `notifications` by `userId` and `createdAt`

## Security Rules

The Firebase security rules should enforce:

1. Users can only read/write their own data
2. Doctors can access their patients' appointments
3. Chat participants can access only their messages
4. Users can only read their own notifications

Example rules structure:
```
{
  "rules": {
    "users": {
      ".read": "auth != null",
      "$role": {
        "$userId": {
          ".write": "$userId === auth.uid || root.child('users').child(auth.uid).child('role').val() === 'admin'"
        }
      }
    },
    "appointments": {
      "$appointmentId": {
        ".read": "data.child('patientId').val() === auth.uid || data.child('doctorId').val() === auth.uid",
        ".write": "data.child('patientId').val() === auth.uid || data.child('doctorId').val() === auth.uid"
      }
    }
    // Similar rules for chats, messages, and notifications
  }
}
``` 