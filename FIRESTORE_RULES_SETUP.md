# Firestore Security Rules Setup Guide

## Problem
You're getting "permission denied" errors when trying to add accounts because Firestore security rules are blocking write access.

## Solution
Deploy the Firestore security rules to allow authenticated users to access their own data.

## Option 1: Deploy via Firebase Console (Recommended - Easiest)

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `xpenso-4b3e3`
3. **Navigate to Firestore Database**:
   - Click on "Firestore Database" in the left sidebar
   - Click on the "Rules" tab at the top
4. **Copy and paste the rules** from `firestore.rules` file
5. **Click "Publish"**

The rules from `firestore.rules` allow:
- ✅ Users to read/write their own accounts
- ✅ Users to read/write their own user_settings
- ✅ Users to read/write their own expenses
- ✅ Users to read/write their own categories
- ❌ Users cannot access other users' data

## Option 2: Deploy via Firebase CLI

If you have Firebase CLI installed:

```bash
# Login to Firebase (if not already logged in)
firebase login

# Initialize Firestore (if not already done)
firebase init firestore

# Deploy the rules
firebase deploy --only firestore:rules
```

## Option 3: Development Mode Rules (UNSAFE for production, but FIXES all permission errors)

If you are just developing and want to fix the "Permission Denied" error immediately, use these rules. These allow anyone who is logged in to read and write everything.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ALLOW READ/WRITE for everything if the user is logged in
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**How to apply:**
1. Copy the code above.
2. Go to **Firebase Console** > **Firestore Database** > **Rules**.
3. Replace the existing text with this code.
4. Click **Publish**.
5. **Restart your app.**

---

## Why "Permission Denied" happens

Firestore is very strict. If you try to save an account but haven't told Firestore "it's okay for this user to save to the 'accounts' collection", it will block the request. 

The original rules I provided (`firestore.rules`) are very secure because they check if the `userId` in the data matches the `userId` of the logged-in user. If your data doesn't have a `userId` field or if it's incorrect, Firestore will deny it.

Using the **Development Mode** rules above removes those checks and just checks if you are logged in.

---

## Verify Data Structure

In your code, I am saving accounts like this:
```dart
{
  'userId': 'CURRENT_USER_ID',
  'name': 'Account Name',
  'balance': 1000.0
}
```

Make sure your Firestore doesn't have any older collections or indexes that might be interfering. If you still get errors, try deleting the "accounts" collection in the Firebase Console (this will wipe your mock data and let the app recreate it).

## What the Rules Do

### Accounts Collection
```javascript
match /accounts/{accountId} {
  allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
  allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
  allow update, delete: if isAuthenticated() && resource.data.userId == request.auth.uid;
}
```

This ensures:
- Only authenticated users can access accounts
- Users can only see their own accounts (filtered by userId)
- Users can only create accounts with their own userId
- Users can only update/delete their own accounts

### User Settings Collection
```javascript
match /user_settings/{userId} {
  allow read, write: if isOwner(userId);
}
```

This ensures:
- Users can only access their own settings document
- The document ID must match the user's auth UID

## Troubleshooting

### Still getting permission denied?
1. **Check if rules are deployed**: Go to Firebase Console → Firestore → Rules tab
2. **Check if user is authenticated**: Make sure you're logged in
3. **Check userId field**: Ensure the data being saved has the correct userId field
4. **Check Firebase Console logs**: Go to Firebase Console → Firestore → Usage tab for error details

### Rules not updating?
- Rules can take a few seconds to propagate
- Try logging out and logging back in
- Clear app data and restart

## Security Best Practices

✅ **DO:**
- Always check `request.auth != null` (user is authenticated)
- Always verify `userId` matches `request.auth.uid`
- Use specific rules for each collection

❌ **DON'T:**
- Never use `allow read, write: if true;` in production
- Don't allow users to access other users' data
- Don't skip authentication checks

## Next Steps

1. Deploy the rules using one of the options above
2. Test adding an account
3. Verify data appears in Firestore Console
4. Test all other features (expenses, settings, etc.)
