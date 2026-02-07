# Testing Guide for Dynamic Features

## Quick Test Steps

### 1. Test Total Balance Calculation
1. Run the app: `flutter run`
2. Login with your credentials
3. Navigate to **Accounts** tab
4. Note the "TOTAL NET WORTH" value
5. Click "Add new account"
6. Add account: Name = "Test Account", Balance = 10000
7. Click "Add Account"
8. Verify the total net worth increased by ₹10,000
9. Go back to **Home** tab
10. Verify "TOTAL BALANCE" shows the updated sum

### 2. Test Balance Visibility Toggle
1. On the **Home** tab, note the total balance value
2. Click the **eye icon** (👁️) in the balance card
3. Balance should change to "₹ ••••••"
4. Click the eye icon again
5. Balance should be visible again
6. Close and reopen the app
7. The visibility preference should persist

### 3. Test Profile Page
1. On the **Home** tab, click the **profile icon** (circular avatar)
2. Profile page should open showing:
   - User's first letter in large avatar
   - Display name
   - Email address
   - Account status
3. Click "Edit Profile" button
4. Should show "coming soon" message

### 4. Test Add Account Flow
1. Navigate to **Accounts** tab
2. Click "Add new account" button
3. Try submitting empty form - should show validation errors
4. Enter account name: "My Savings"
5. Enter balance: "50000"
6. Click "Add Account"
7. Should see success message
8. Should return to accounts list
9. New account should appear in the list
10. Total net worth should update

### 5. Test Monthly Budget (Settings Integration)
1. On **Home** tab, check the "BUDGET" card value
2. It should show ₹50,000 (default)
3. The budget is now stored in Firestore user_settings
4. Future: Can be edited in settings

## Expected Behavior

### ✅ What Should Work:
- Total balance = Sum of all account balances
- Balance visibility toggle (eye icon)
- Add new accounts
- Profile page navigation
- All data persists in Firestore
- Real-time updates across the app

### 🔄 Data Flow Verification:
```
Add Account → Firestore → Accounts List Updates → Total Balance Recalculates → Dashboard Updates
```

### 📱 UI Updates:
- Dashboard total balance updates when accounts change
- Eye icon changes between visibility_outlined and visibility_off_outlined
- Accounts list refreshes after adding new account
- Profile shows real user data from Firebase Auth

## Troubleshooting

### If Total Balance Shows 0:
- Check if you have any accounts added
- Go to Accounts tab and add at least one account
- The balance will automatically update

### If Eye Icon Doesn't Work:
- Check console for errors
- Verify SettingsRepository is provided in main.dart
- Check Firestore rules allow user_settings read/write

### If Add Account Fails:
- Check Firestore rules allow accounts collection write
- Verify user is authenticated
- Check console for error messages

## Database Structure

### Firestore Collections:

**accounts**
```
{
  userId: "user123",
  name: "HDFC Savings",
  balance: 25000
}
```

**user_settings**
```
{
  userId: "user123",
  monthlyBudget: 50000,
  balanceVisible: true,
  dailyReminders: true,
  budgetAlerts: false
}
```

**expenses**
```
{
  userId: "user123",
  amount: 500,
  categoryId: "food",
  date: Timestamp,
  note: "Lunch"
}
```

## Success Criteria

✅ All features work without errors
✅ Data persists in Firestore
✅ UI updates in real-time
✅ No hardcoded values for balance/budget
✅ User-specific data isolation
