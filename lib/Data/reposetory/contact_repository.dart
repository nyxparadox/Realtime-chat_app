import 'package:chatter_chatapp/Data/models/user_model.dart';
import 'package:chatter_chatapp/Data/sevicies/base_reposatry.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_contact/flutter_contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';


class ContactRepository extends BaseReposatry {

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<bool> requestContactPermission () async{
    return await FlutterContacts.requestPermission();
  }

  Future<List<Map<String, dynamic>>> getRegisteredContacts() async{
    try{

      bool hasPermission = await requestContactPermission();
      if (!hasPermission){
        debugPrint("contacts permission denied");
        return [];
      }

      // get device contacts with phone number
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true
      );


      // extract phone number and normalize them
      final phoneNumbers = contacts
        .where((contact) => contact.phones.isNotEmpty)
        .map((contact) {
        // Normalize the phone number: remove non-digits and get last 10 digits
        String rawNumber = contact.phones.first.number;
        String digitsOnly = rawNumber.replaceAll(RegExp(r'\D'), '');
        String normalizedNumber = digitsOnly.length >= 10
            ? digitsOnly.substring(digitsOnly.length - 10)
            : digitsOnly; // fallback if number is too short

        return {
          'name': contact.displayName ,
          'phoneNumber': normalizedNumber,
          'photo': contact.photo ,
        };
      })
      .toList();

      /*final phoneNumbers = contacts
          .where((contact) => contact.phones.isNotEmpty)
          .map((contact) => {
                'name': contact.displayName,
                'phoneNumber': contact.phones.first.number
                    .replaceAll(RegExp(r'[^\d+]'), ''),
                'photo': contact.photo, // Store contact photo if available
              })
          .toList();

      if (phoneNumber.startsWith("+91")) {
          phoneNumber = phoneNumber.substring(3);
        } */

        

      // get all users from firestore
      final userSnapshot = await firestore.collection("users").get();

      final registeredUsers = await userSnapshot.docs
      .map((doc)=>UserModel.fromFirestore(doc)).toList();


      // match the phone numbers with registered user

      final matchedContacts = phoneNumbers.where((contact){
        final phoneNumber= contact["phoneNumber"];

      

        return registeredUsers.any((user)=> user.phoneNumber==phoneNumber && user.uid !=currentUserId);
      }).map((contact){
        final registeredUser =registeredUsers.firstWhere((user)=> user.phoneNumber==contact["phoneNumber"]);

        return{
          'id' : registeredUser.uid,
          'name' :contact['name'],
          'phoneNumber' : contact['phoneNumber'], 
        };
      }).toList();

      return matchedContacts;

    }catch(e){
      debugPrint("error getting registerec user");
      return [];
    }
  }
}