//import 'package:flutter/cupertino.dart';   // for ios app
import 'package:chatter_chatapp/Core/common/custom_button.dart';
import 'package:chatter_chatapp/Core/common/custom_text_field.dart';
import 'package:chatter_chatapp/Core/utils/ui_utils.dart';
import 'package:chatter_chatapp/Data/sevicies/service_locator.dart';
import 'package:chatter_chatapp/Logic/cubit/auth/auth_cubit.dart';
import 'package:chatter_chatapp/Logic/cubit/auth/auth_state.dart';
import 'package:chatter_chatapp/Presentation/home/home_screen.dart';
import 'package:chatter_chatapp/Presentation/screen/auth/signup_screen.dart';
import 'package:chatter_chatapp/router/app_router.dart';
//import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final emailfocus = FocusNode();
  final passwordfocus = FocusNode();
  bool ispasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailfocus.dispose();
    passwordfocus.dispose();
    super.dispose();
  }

  String? _validateemail(String? value){
    if (value == null || value.isEmpty){
      return 'please enter your email';
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Please enter a valid email address (e.g., example@gmail.com)';
    }
    return null;
  }

  String? _validatepassword(String? value){
  if (value == null || value.isEmpty){
    return 'please enter your password';
  }
  return null;
}


Future<void> handleSignIn()async{
    FocusScope.of(context).unfocus();
    if (_formkey.currentState?.validate() ?? false){
      try {
        await getIt<AuthCubit>().signIn(
          email: emailController.text,
          password: passwordController.text,
        );
      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }else {
      debugPrint('form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return  BlocConsumer<AuthCubit,AuthState>(
      bloc: getIt<AuthCubit>(),
      listener: (context, state){
        if (state.status == AuthStatus.authenticated){
          getIt<AppRouter>().pushAndRemoveUntil(const HomeScreen());
          
        }else if (state.status == AuthStatus.error && state.error != null) {
          UiUtils.showSnackBar(context, message: state.error!);
        } 
      },
      builder: (context,state){
      return  Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            
            child: Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 130, left: 35 ,right: 35),
                  child: Container(
                    height: 750,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF004F4F),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [ BoxShadow( 
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(12, 10)),
                      
                      BoxShadow(color: Colors.tealAccent.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: Offset(-2, -2))],

                      
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                      children: [
                        const SizedBox(
                          height: 60,
                        ),
                      
                        
                        Text('Welcome Back',
                        style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold ,
                        color: Colors.white)),
                        
                        const SizedBox(
                          height: 5,
                        ),
                        Text('Sign in to continue',
                        style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: Colors.cyanAccent),),
                                
                        const SizedBox(
                          height: 60,
                        ),
                                
                        CustomTextField(
                              controller: emailController, 
                              hintText: "email",
                              validator: _validateemail,
                              prefixIcon: const Icon(Icons.email_rounded, color: Colors.tealAccent,),),
                        
                        const SizedBox(height: 25,),
                        
                        CustomTextField(
                              controller: passwordController, 
                              hintText: "password",
                              focusNode: passwordfocus,
                              validator: _validatepassword,
                              obscureText: !ispasswordVisible,
                              prefixIcon: const Icon(Icons.lock_rounded, color: Colors.tealAccent,),
                              suffixIcon: IconButton(onPressed: (){
                                setState(() {
                                  ispasswordVisible = !ispasswordVisible;
                            
                                });
                              }, icon: Icon(
                                !ispasswordVisible ?Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: Colors.blueGrey,
                              ))
                              ),
                            
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RichText(text: TextSpan(
                              text: "Forgot Password?",style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(/* color: Theme.of(context).colorScheme.primary, */
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold)
                            )),
                          ],
                        ),
                                
                        const SizedBox(height: 50,),
                                
                        Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(.5),
                                offset: Offset(4, 2),
                                blurRadius: 15,
                                spreadRadius: 3
                              ),
                              
                              BoxShadow(
                                color: Colors.tealAccent.withOpacity(.7),
                                offset: Offset(-2, -2),

                              )]
                            
                          ),
                          child: CustomButton(
                            onPressed: handleSignIn,
                            text: 'Login',
                            child: state.status == AuthStatus.loading ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text('Login', style: TextStyle(color: Colors.white),),
                            
                            
                            ),
                        ),
                            
                        const SizedBox(height: 28,),
                            
                        RichText(text: TextSpan(
                          text: "Don't have an account?",
                          style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: Colors.white,
                          fontSize: 20),
                            
                          children: [TextSpan(
                            text: " Sign up",
                            style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(
                              /*color: Theme.of(context).colorScheme.primary,*/
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                            
                              
                              recognizer: TapGestureRecognizer()..onTap = (){
                              //  Navigator.push(context, MaterialPageRoute(
                              //  builder: (context) => const SignupScreen())
                              //  );
                                  getIt<AppRouter>().push(const SignupScreen());
                              },
                          )
                      ])        
                        ),
                      ],
                                ),
                    ),
                  ),
                ),
              )),
          ),
        ),
      );
      }
    );
  
  }
}