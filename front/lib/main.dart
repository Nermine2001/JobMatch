import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jobmatch_app/screens/job_details_screen.dart';
import 'package:jobmatch_app/screens/login_screen.dart';
import 'package:jobmatch_app/screens/register_screen.dart';
import 'package:url_launcher/url_launcher.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /*await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    //appleProvider: AppleProvider.debug,
  );*/

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/jobDetails': (context) {
          final jobId = ModalRoute.of(context)!.settings.arguments as String;
          return JobDetailsScreen(jobId: jobId);
        },
      },
      debugShowCheckedModeBanner: false,
      title: 'JobMatch App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffbfbcf3),
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 85,),
              // Image avec coins arrondis
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'images/freepik_background.jpeg',
                  height: 450,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                "JobMatch",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Find your ideal job",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 45),
              // Login button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff1feac),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(400, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Poppins"
                    ),
                ),
              ),
              const SizedBox(height: 15),
              // Register button
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  minimumSize: const Size(400, 50),
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Poppins"
                    ),
                ),
              ),
              const SizedBox(height: 90),
              // Privacy policy
              GestureDetector(
                onTap: () {
                  // future action
                },
                child: GestureDetector(
                  onTap: () async {
                    await launchUrl(Uri.parse('https://www.termsfeed.com/live/f8069637-31d9-4ccb-b677-2dcd9688b003'), mode: LaunchMode.externalApplication);
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacySecurityScreen()));
                  },
                  child: const Text(
                    "Privacy policy",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}





/*
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // optionnel
        title: 'JobMatch App',
        theme: ThemeData(
        //primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xffbfbcf3),
        fontFamily: 'Roboto',
        ),
      home: Container(
        color: Color(0xffbfbcf3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('images/freepik_background.jpeg'),
            //SizedBox(height: 15,),
            Text(
              "JobMatch",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins'
              ),
            ),
            SizedBox(height: 10,),
            Text(
              "Find your ideal job",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Poppins'
              ),
            ),
            SizedBox(height: 25,),
            // button login
            ElevatedButton(onPressed: (){}, style: ButtonStyle(), child: Text("Login"),),
            SizedBox(height: 15,),
            //button register
            ElevatedButton(onPressed: (){}, style: ButtonStyle(), child: Text("Register")),
            SizedBox(height: 35,),
            //privacy policy link
            Text("Privacy policy", style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                fontFamily: 'Poppins'
            ),)
          ],
        ),
      ),
    );
  }
}
*/
