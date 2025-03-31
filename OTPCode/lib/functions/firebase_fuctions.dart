import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*Future<void> signInWithPhoneNumber(String phoneNumber) async {
  try {

    final UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
    final user = userCredential.user;

    // Check if the user is signed in
    if (user != null) {

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Store the phone number as part of the user's data
      await userRef.set({
        'phoneNumber': phoneNumber.toString(),
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("User signed in with phone number and created in Firestore");
    }
  } catch (e) {
    print("Error signing in with phone number: $e");
  }
}
*/

// This function first signs out if the user is existing and then sign in again


Future<void> signInWithPhoneNumber(String phoneNumber) async {
  try {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? currentUser = auth.currentUser;

    // ✅ Step 1: Check if a user is already signed in
    if (currentUser != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(phoneNumber);
      final userDoc = await userRef.get();

      // ✅ Step 2: Check if the phone number exists in Firestore
      if (userDoc.exists && userDoc.data()?['phoneNumber'] == phoneNumber) {
        print("✅ User already signed in with this phone number. No need to sign out.");
        return; // Exit early, user is already authenticated
      } else {
        print("⚠️ User signed in, but phone number doesn't match. Creating a new user.");
        await auth.signOut(); // Sign out since the phone number is different
      }
    }

    // ✅ Step 3: Create a new anonymous user
    final UserCredential userCredential = await auth.signInAnonymously();
    final User? newUser = userCredential.user;

    if (newUser != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(phoneNumber);

      // ✅ Step 4: Store the new phone number in Firestore
      await userRef.set({
        'phoneNumber': phoneNumber,
        'uid': newUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ New anonymous user created with phone number and stored in Firestore.");
    }
  } catch (e) {
    print("❌ Error signing in with phone number: $e");
  }
}
