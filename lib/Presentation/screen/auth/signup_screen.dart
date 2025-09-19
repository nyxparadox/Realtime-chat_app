import 'package:chatter_chatapp/Core/common/custom_button.dart';
import 'package:chatter_chatapp/Core/common/custom_text_field.dart';
// import 'package:chatter_chatapp/Core/utils/ui_utils.dart';
//import 'package:chatter_chatapp/Data/reposetory/auth_reposatory.dart';
import 'package:chatter_chatapp/Core/utils/ui_utils.dart';
// import 'package:chatter_chatapp/Data/reposetory/auth_repository.dart';

import 'package:chatter_chatapp/Data/sevicies/service_locator.dart';
import 'package:chatter_chatapp/Logic/cubit/auth/auth_cubit.dart';
import 'package:chatter_chatapp/Logic/cubit/auth/auth_state.dart';
import 'package:chatter_chatapp/Presentation/home/home_screen.dart';
import 'package:chatter_chatapp/Presentation/screen/auth/login_screen.dart';
import 'package:chatter_chatapp/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController usernamecontroller = TextEditingController();
  final TextEditingController fullnamecontroller = TextEditingController();

  bool ispasswordVisible = false;

  final namefocus = FocusNode();
  final usernamefocus = FocusNode();
  final emailfocus = FocusNode();
  final phonefocus = FocusNode();
  final passwordfocus = FocusNode();


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    phoneNumber.dispose();                // this void didspose() function is for disposing the controllers and focus nodes
    usernamecontroller.dispose();         // to free up resources
    fullnamecontroller.dispose();
    namefocus.dispose();
    usernamefocus.dispose();
    emailfocus.dispose();
    phonefocus.dispose();
    passwordfocus.dispose();
    super.dispose();
  }

  // full name validation
  String? _validatename(String? value){
    if (value == null || value.isEmpty){
    return 'Please enter your full name';}
    return null;
  }

  // username validation
  String? _validateusername(String? value){
    
    if (value == null || value.isEmpty){
      return 'please enter your username';
    }
    return null;
  }


  // email validation
  String? _validateemail(String? value){
    if (value == null || value.isEmpty){
      return 'please enter your email';
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Please enter a valid email address (e.g., example@gmail.com)';
    }
    return null;
  }

  //  phone number validation
String? _validatephoneNumber(String? value){
  if (value == null || value.isEmpty){
    return 'please enter your phone number';
  }else if( !RegExp(r'^\d{10}$').hasMatch(value)) {
    return 'Please enter a valid phone number (10 digits)';   // phoene number validation
  }
  return null;
}

// password validation
String? _validatepassword(String? value){
  if (value == null || value.isEmpty){
    return 'please enter your password';
  }else if (value.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
  
}

  Future<void> handleSignUp()async{
    FocusScope.of(context).unfocus();
    if (_formkey.currentState?.validate() ?? false){
      try {                         
        await getIt<AuthCubit>().signUp(
          fullName: fullnamecontroller.text,
          username: usernamecontroller.text,
          email: emailController.text,
          phoneNumber: phoneNumber.text,
          password: passwordController.text,
        );
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(       // this is the other way to show snak bar ,
          SnackBar(content: Text(e.toString())),          //  i am commenting this because, it creating double snackbar.
        );
      }
    }else {
      debugPrint('form validation failed');  // print ---> debugprint
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit,AuthState>(
      bloc: getIt<AuthCubit>(),
      listener: (context, state){
        if (state.status == AuthStatus.authenticated){
          getIt<AppRouter>().pushAndRemoveUntil(const HomeScreen());
          
        }else if (state.status == AuthStatus.error && state.error != null) {
          UiUtils.showSnackBar(context, message: state.error!);
        } 
      },
      builder: (context,state){
      return Scaffold(
        appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withAlpha((0.5 * 255).toInt()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Chatter'),
          
        ),
        
        body: SafeArea(
          
          child: Form(
            key: _formkey,
      
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 70.0, left: 23.0, right: 23.0),
              child: Container(
                height: 850,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFF004F4F),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.9),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(6, 5)),
                  
                  BoxShadow(color: Colors.tealAccent,
                  blurRadius: 4,
                  // spreadRadius: 0,
                  offset: Offset(-2, -2))],),


                padding: const EdgeInsets.only(left:14 ,right: 14),
                
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    
                    children: [
                      const SizedBox(
                        height: 90,
                      ),
                      Text('Create Account',
                          style: Theme.of(context).textTheme.headlineLarge ?.copyWith(
                            color: Colors.white
                          )),
                          
                      Text("please fill in the details to continue",
                      style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: Colors.cyanAccent)),
                          
                      const SizedBox(
                        height: 55,
                      ),
                          
                      CustomTextField(
                        controller: fullnamecontroller,
                        hintText: "full name",
                        focusNode: namefocus,
                        validator: _validatename,
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Colors.tealAccent,)),
                          
                      const SizedBox(
                        height: 15,
                      ),
                          
                      CustomTextField(
                        controller: usernamecontroller,
                        hintText: "username",
                        focusNode: usernamefocus,
                        validator: _validateusername,
                        prefixIcon: Icon(Icons.alternate_email, color: Colors.tealAccent,),),
                          
                      const SizedBox(
                        height: 15,
                      ),
                      CustomTextField(
                        controller: emailController,
                        hintText: "email",
                        focusNode: emailfocus,
                        validator: _validateemail,
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.tealAccent,),),
                          
                      const SizedBox(
                        height: 15,
                      ),
                          
                      CustomTextField(
                        controller: phoneNumber,
                        hintText: "phone number",
                        focusNode: phonefocus,
                        validator: _validatephoneNumber,
                        prefixIcon: Icon(Icons.call_outlined, color: Colors.tealAccent,),
                        keyboardType: TextInputType.number),
                          
                      const SizedBox(
                        height: 15,
                      ),
                          
                      CustomTextField(
                        controller: passwordController,
                        hintText: "create password",
                        obscureText: ispasswordVisible,
                        focusNode: passwordfocus,
                        validator: _validatepassword,
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.tealAccent,),
                        suffixIcon: IconButton(onPressed: (){
                          setState(() {
                            ispasswordVisible = !ispasswordVisible;
                          });
                        }, 
                        icon:  Icon(
                          ispasswordVisible ?Icons.visibility_off: Icons.visibility,
                          color: Colors.blueGrey,), ),
                      ),
                          
                      const SizedBox(
                        height: 45,
                      ),
                          
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(.5),
                            offset: Offset(4, 4),
                            blurRadius: 7,
                            spreadRadius: 2,
                          ),
                          
                          BoxShadow(
                            color: Colors.tealAccent,
                            blurRadius: 0,
                            
                            offset: Offset(-1, -1)
                          )]
                        ),
                        child: CustomButton(onPressed: handleSignUp,
                          text: 'Create Account',
                          child: state.status == AuthStatus.loading ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                          : Text('Create Account', style: TextStyle(color: Colors.white),)),
                      ),
                  
                      const SizedBox(
                        height: 16,
                      ),
                  
                      Center(
                        child: RichText(text: TextSpan(
                          text: "Already have an account?",
                          style: Theme.of (context).textTheme.bodyLarge
                          ?.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          children: [
                            TextSpan(
                              text: " Login",
                              style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(/*color: Theme.of(context).colorScheme.primary,*/
                              color: Colors.cyanAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,),
                              
                              recognizer: TapGestureRecognizer()..onTap = (){
                                Navigator.pop(context, MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),),
                                );
                              }
                            )
                          ]
                        
                        )),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      );
      }
    );
  }
}