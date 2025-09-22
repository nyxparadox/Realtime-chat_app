// import 'package:chatter_chatapp/Data/reposetory/auth_repository.dart';
// import 'package:chatter_chatapp/Data/reposetory/auth_repository.dart';
import 'package:chatter_chatapp/Data/reposetory/chat_repository.dart';
import 'package:chatter_chatapp/Data/reposetory/contact_repository.dart';
import 'package:chatter_chatapp/Data/sevicies/service_locator.dart';
import 'package:chatter_chatapp/Logic/cubit/auth/auth_cubit.dart';
import 'package:chatter_chatapp/Presentation/chat/chat_message_screen.dart';
import 'package:chatter_chatapp/Presentation/screen/auth/login_screen.dart';
import 'package:chatter_chatapp/Presentation/widget/chat_list_tile.dart';
import 'package:chatter_chatapp/router/app_router.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';
// import 'package:get_it/get_it.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository;
  late final ChatRepository _chatRepository;
  late final String _currentUserId;

  @override
  void initState() {
    _contactRepository = getIt<ContactRepository>();
    _chatRepository = getIt<ChatRepository>();
    _currentUserId = getIt<AuthCubit>().state.user?.uid ?? '';      // get current user id from auth cubit state

    super.initState();
  }

  void _showContactList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Text(
                'Contacts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _contactRepository.getRegisteredContacts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("error: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final contacts = snapshot.data!;
                    if (contacts.isEmpty) {
                      return const Center(child: Text("No contacts found"));
                    }

                    return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey,
                            child: Text(contact['name'].isNotEmpty ? contact['name'][0].toUpperCase() : '?',),   //---- this line is changed
                          ),

                          title: Text(contact["name"], style: TextStyle(color: Colors.white),),
                          onTap: () {
                            getIt<AppRouter>().push(
                              ChatMessageScreen(
                                receiverId: contact['id'],
                                receiverName: contact['name'] ,
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF004F4F),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              getIt<AuthCubit>().signOut();
              getIt<AppRouter>().pushAndRemoveUntil(const LoginScreen());
            },
          ),
        ],
        title: Text('Chats', style: TextStyle(color: Colors.white)),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/homeBg05.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder(
          stream: _chatRepository.getChatRooms(_currentUserId),
           builder: (context, snapshot){
            if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text("Error: ${snapshot.error}"));
            }
        
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
        
            final chats = snapshot.data!;
            if (chats.isEmpty) {
              return const Center(child: Text("No chats available"));
              
            }
        
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ChatListTile(
                  chat: chat,
                  currentUserId: _currentUserId,
                  onTap: () {
                    final otherUserId = chat.participants.firstWhere(
                      (id) => id != _currentUserId,);
                    final otherUserName = chat.participantsName![otherUserId] ?? "Unkonwn user";
                    getIt<AppRouter>().push(
                      ChatMessageScreen(
                        receiverId: otherUserId,
                        receiverName: otherUserName,
                      ),
                    );
                  },
                );
              },
            );
        
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactList(context),
        backgroundColor: Color(0xFF004F4F),
        foregroundColor: Colors.white,

        child: const Icon(Icons.edit, size: 30),
      ),
    );
  }
}
