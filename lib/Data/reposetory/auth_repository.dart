import 'dart:developer';

import 'package:chatter_chatapp/Data/models/user_model.dart';
import 'package:chatter_chatapp/Data/sevicies/base_reposatry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class AuthReposatory extends BaseReposatry {
  Stream<User?> get authStateChanges => auth.authStateChanges(); // stream of user changes
  
  Future<UserModel> signUp({
    required String fullName,        // ye saara data user jata hai or user model m store ho jayga jo humne user_model.dart mai bnaya hai 
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {                         // asynchronous function to wait for the user to be created
    try {
      final usernameExists = await checkUsernameExists(username); // check if the username already exists
      if (usernameExists) {
        throw Exception("Username already exists"); // if the username already exists, throw an error
      }
      
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,                                // user crreated with email and password
        password: password);
      if (userCredential.user == null){
        throw "Failed to create user";
      }

    

      // create user model and save the user to db or firestore

      final user = UserModel(
        uid: userCredential.user!.uid,
        fullName: fullName,
        username: username,
        email: email,
        phoneNumber: phoneNumber);

      await saveUserData(user);    // this function will save the user data to firestore
      return user;

    } catch(e){
      log(e.toString());
      rethrow;
    }
  }


  

  // save created user data to firestore  by maping the user model to a map
  Future<void> saveUserData(UserModel user) async{
    try{
      firestore.collection('users').doc(user.uid).set(user.toMap());   // creata a document in firestore with user uid as the document id
    } catch(e){
      throw "Failed to save user data";
    }
  }



  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password);
        if (userCredential.user == null){
          throw "User not found";
        }
        final userData = await getUserData(userCredential.user!.uid);
        return userData;
    }catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut(); // sign out the user
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await firestore.collection("users").doc(uid).get();
      if (!doc.exists){
        throw "User not found";
      }
      return UserModel.fromFirestore(doc);
    }catch (e) {
      throw "Failed to get user data";
    }
  }


  Future<bool> checkUsernameExists(String username) async{
    try{
      final querySnapshot = await firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return querySnapshot.docs.isNotEmpty; // if the query returns any documents, the username exists
    } catch (e) {
      debugPrint("Error checking username $e");
      return false;
    }
  }

}