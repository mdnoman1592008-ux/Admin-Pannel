# Admin access setup

The admin portal uses Firebase Authentication for sign-in and the matching
Firestore document in `users/{uid}` for authorization. Do not add a public
"make me admin" screen: a user could then grant themselves access.

## Create the first administrator

1. In Firebase Console, open **Authentication → Users → Add user** and create
   an email/password account. Enable the Email/Password provider first if it
   is disabled.
2. Copy the new user's **UID**.
3. In Firebase Console, open **Firestore Database → users** and create a
   document whose ID is exactly that UID. Set these fields:

   ```text
   uid: <same Firebase UID>
   email: <administrator email>
   displayName: <administrator name>
   role: super_admin
   isActive: true
   provider: email
   createdAt: <Firestore Timestamp>
   lastLogin: <Firestore Timestamp>
   ```

   Use `super_admin` only for the owner. Normal content operators should use
   `admin`, `editor`, `moderator`, `support`, or `viewer` as appropriate.
4. Deploy `firestore.rules` before exposing the app. Firestore Console and a
   trusted Admin SDK bypass these client rules, which is why they are the
   correct place to create the first privileged user.
5. Build/deploy `admin_panel` and sign in with that email and password. The
   portal reads `users/{uid}.role` and opens only for non-viewer admin roles.

## Required production services

- Firebase Authentication with your real Android/iOS/Web app registrations.
- Firestore database with deployed rules and required composite indexes.
- Supabase bucket `ether-cinema` with `supabase_storage.sql` policies applied.
- A trusted server-side Firebase Cloud Function (or equivalent) that consumes
  queued `notifications` documents and sends FCM using Firebase Admin SDK.
  The browser must never hold an FCM server credential.

## Content requirements

Only publish a movie after it has a real title, metadata, image URLs, and an
authorized playback source. The application no longer supplies demo playback
URLs as a fallback.
