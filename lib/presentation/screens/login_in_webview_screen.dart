import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginWebViewScreen extends StatefulWidget {
  final String url;
  const LoginWebViewScreen({super.key, required this.url});

  @override
  State<LoginWebViewScreen> createState() => _LoginWebViewScreenState();
}

class _LoginWebViewScreenState extends State<LoginWebViewScreen> {

  late final WebViewController _webViewController;

  @override
  void initState() {
    
    super.initState();
    _inicializarWebView();
    _webViewController.loadRequest(Uri.parse(widget.url));
  }

  void _inicializarWebView(){
    // inicializamos el controlador del web view
    // con un callback de onPageFinished, de aqui podemos obtener el codigo del usuario
    _webViewController = WebViewController();
    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) {
          if (url.contains("?code=")) {
              // ----------------------------------> succes volvemos a la anterior con la url
              Navigator.pop(context,url);
          }else if(url == "https://id.twitch.tv/oauth2/authorize"){
            // le ha dado al cancelar
            Navigator.pop(context);
          }

        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"),), // TODO cambiar a algo mas generico
      body: Container(
          color: Theme.of(context).dialogBackgroundColor,
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: WebViewWidget(
            controller: _webViewController,
            
          ),
      ),
    );
  }
}