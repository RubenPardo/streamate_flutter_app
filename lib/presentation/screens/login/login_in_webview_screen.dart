import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/services/twitch_api_service.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart';
import 'package:streamate_flutter_app/shared/widgets/app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class LoginWebViewScreen extends StatefulWidget {
  final String url;
  const LoginWebViewScreen({super.key, required this.url});

  @override
  State<LoginWebViewScreen> createState() => _LoginWebViewScreenState();
}

class _LoginWebViewScreenState extends State<LoginWebViewScreen> {

  late final WebViewController _webViewController;
  bool _isWebViewClosed = false; // para controlar que no intente cerrar dos veces el web view y salten errores
  bool _isLoading = false;
  


  // necisitamos saber que pagina es la anterior para diferencias si le ha dado a autorizar o a cancelar
  // cuando le damos a autorizar 
  String _urlAnterior = ""; 

  @override
  void initState() {
    
    super.initState();
    
    _inicializarWebView();
    _webViewController.loadRequest(Uri.parse(widget.url));
  }

  void _inicializarWebView(){
    // inicializamos el controlador del web view
    // con un callback de onPageFinished, de aqui podemos obtener el codigo del usuario
    String urlAutorizacion = serviceLocator<TwitchApiService>().getAutorizationUrl();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) {
          
        },
        onWebResourceError: (error) {
         
        },
        onPageStarted: (url) {
          print("-------------------------------");
          print("URL ------------- $url");
          if (url.contains("?code=") && !_isWebViewClosed) {
            _isWebViewClosed = true;
              // ----------------------------------> succes volvemos a la anterior con la url
              Navigator.pop(context,url);
          }
          // TODO averiguar como detectar que le ha dado al boton de cancelar para devolverlo a la pagina principal
          // ahora sale una pagina en blanco pero puedes volver a atras con el appbar

          /*else if(_urlAnterior.replaceAll("%20", " ") == urlAutorizacion && url == "https://id.twitch.tv/oauth2/authorize" && !_isWebViewClosed){
            // le ha dado al boton de cancelar
            _isWebViewClosed = true;
            Navigator.pop(context);
          }*/
          _urlAnterior = url;
        },
        onProgress: (progress) {
          if(mounted){ // para no hacer un set state cuando no exista el widget
              setState(() {
              _isLoading = progress < 100;
            });
          }
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(iniciarSesion,), // TODO cambiar a algo mas generico
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(),)
        : _urlAnterior == "https://id.twitch.tv/oauth2/authorize" 
          ? Container(
              // TODO saber que poner aqui
          )
          : Container(
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