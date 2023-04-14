

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:non_linear_slider/models/interval.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/obs_audio_track.dart';
import 'package:streamate_flutter_app/data/model/obs_connection.dart';
import 'package:streamate_flutter_app/data/model/obs_scene.dart';
import 'package:streamate_flutter_app/data/model/token_data.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/data/services/obs_service.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/styles.dart' as styles;
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts;
import 'package:streamate_flutter_app/presentation/bloc/obs/obs_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/obs/obs_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/obs/obs_state.dart';
import 'package:streamate_flutter_app/shared/widgets/large_primary_button.dart';
import 'package:non_linear_slider/non_linear_slider.dart';
import 'package:reactive_forms/reactive_forms.dart';

class OBSScreen extends StatefulWidget {

  final TokenData tokenData;
  final User user;
  

  const OBSScreen({super.key, required this.tokenData, required this.user});

  @override
  State<OBSScreen> createState() => _OBSScreenState();
}

class _OBSScreenState extends State<OBSScreen> {

  FormGroup buildForm() => fb.group(<String, Object>{
        'password': FormControl<String>(
          validators: []
        ),
        'ip': FormControl<String>(
          validators: [
            
          ]
        ),
        'port': FormControl<String>(
          value: '4455',
          validators: []
        ),
      });
  bool _passwordVisible = false;
  OBSConnection? lastConnection;

  @override
  void initState() {
    super.initState();
    if(context.read<OBSBloc>().state is OBSUninitialized){
      context.read<OBSBloc>().add(OBSInit());
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OBSBloc,OBSState>(
        builder: (context, state) {
          if(state is OBSInitialized ){
            return _buildInitialized(lastConnection);
          }
          if(state is OBSError){
            return _buildInitialized(lastConnection);
          }
          if(state is OBSConnected){
            return ListView(
              children:[
                _closeConnection(),
               _buildScenes(),
               _buildAudioTracks()
               ]
            );
          }

          return const SizedBox();
        },
        listener: (context, state) {
          if(state is OBSError){
            log(state.message.toString());
            Utils.showSnackBar(context, 'Error al vincular al obs');
          }
          if(state is OBSInitialized){
            setState(() {
              lastConnection = state.lastConnection;
            });
          }
        },
    );
  }

    void _cerrarSesion() async{
      var obs = OBSServiceImpl();
     await obs.connect('10.72.22.90', 4455, 'holaxd');
      await obs.getSceneList();
      //await obs.getAudioTrackList();
      await obs.setVolume('Audio del escritorioxD',0);
      await obs.setVolume('Mic/Aux',0);

      ///context.read<AuthBloc>().add(LogOut()); // ---------------------> cerrar sesion         
  }


  /// funcion que devuelve el widget para conectarse al obs
  /// si [lastConnection] no es null se mostrara un boton para 
  /// connectarse directamente usando esos parametros
  Widget _buildInitialized(OBSConnection? lastConnection) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Flexible(
                  flex: 11,
                  child: Text(texts.linkObsTitle,
                    textAlign: TextAlign.center,style:Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),),
                ),
                const SizedBox(width: 8,),
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    child: Image.asset('assets/images/question_white_icon.png'),
                    onTap: (){
                    _showOBSHelpDialog();
                  }))
              ],
            ),
            const SizedBox(height: 40,),
            LargeButton(
                child: Text(texts.linkObs,style:Theme.of(context).textTheme.bodyLarge,),
                onPressed: () {
                   _showOBSLinkDialog();
                  
                   
                }
              ),
            const SizedBox(height: 40,),
            Text(texts.lastConnection,style:Theme.of(context).textTheme.bodyLarge,),
            const SizedBox(height: 24,),
            LargeButton(
                backgroundColor: MyColors.textoSobreClaro,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tv),
                    const SizedBox(width: 24,),
                    Text('${lastConnection?.address}:${lastConnection?.port}',style:Theme.of(context).textTheme.bodyLarge,)
                  ],
                ),
                onPressed: () {
                   context.read<OBSBloc>().add(OBSConnect(connection: lastConnection!));        
                }
              )
          ],
        ),
      ),
    );
  }
  

  void _showOBSHelpDialog(){
    showDialog(context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        titleTextStyle:Theme.of(context).textTheme.headlineMedium?.copyWith(color: MyColors.textoSobreClaro,fontSize: 24,fontWeight: FontWeight.bold),
        contentTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: MyColors.textoSobreClaro),
        title: const Text(texts.helpObsTitleDialog),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(texts.obsHelp),
            const SizedBox(height: 16,),
            Image.asset('assets/images/obs_help.png')
          ],
        ),
        actions: [
          ElevatedButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: const Text(texts.accept))
        ],
      );
    },);
  }

  /// muestra un dialog con el formulario de la conexión a obs
  /// Si el formulario es correcto añadirá el evento
  void _showOBSLinkDialog(){
   showDialog(context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
        titleTextStyle:Theme.of(context).textTheme.headlineMedium?.copyWith(color: MyColors.textoSobreClaro,fontSize: 24,fontWeight: FontWeight.bold),
        contentTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: MyColors.textoSobreClaro),
        title: const Text(texts.linkObsTitleDialog),
        content:  StatefulBuilder(
          builder: (context,setState) {
            return SizedBox(
              width: MediaQuery.of(context).size.width*0.8,
              child: ReactiveFormBuilder(
                form: buildForm, 
                builder: (context, formGroup, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
            
                      Row(
            
                        children: [
                          // ----------------------------------- ip
                          Flexible(
                            flex: 3,
                            child: ReactiveTextField<String>(
                              formControlName: 'ip',
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(color: MyColors.textoSobreClaro) ,
                              decoration:  const InputDecoration(
                                labelText: texts.ip,
                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color:MyColors.textoError),borderRadius: BorderRadius.all(Radius.circular(12))),
                                errorMaxLines: 2,
                                fillColor:  Colors.white,
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: MyColors.textoSobreClaro), borderRadius: BorderRadius.all(Radius.circular(12))),
                                filled: true,
                                labelStyle: TextStyle(color: MyColors.textoSobreClaro) ,
                                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.red),borderRadius: BorderRadius.all(Radius.circular(12))),
                                
                              ),
                            ),
                          ),
                          const SizedBox(width: 8,),
                          // ----------------------------------- puerto
                          Flexible(
                            flex: 1,
                            child: ReactiveTextField<String>(
                              formControlName: 'port',
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: const TextStyle(color: MyColors.textoSobreClaro) ,
                              decoration:  const InputDecoration(
                                labelText: texts.port,
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: MyColors.textoSobreClaro), borderRadius: BorderRadius.all(Radius.circular(12))),
                                errorBorder: OutlineInputBorder(borderSide: BorderSide(color:MyColors.textoError),borderRadius: BorderRadius.all(Radius.circular(12))),
                                errorMaxLines: 2,
                                fillColor:  Colors.white,
                                filled: true,
                                labelStyle: TextStyle(color: MyColors.textoSobreClaro) ,
                                border: OutlineInputBorder(borderSide: BorderSide(color: MyColors.textoSobreClaro),borderRadius: BorderRadius.all(Radius.circular(12))),
                                
                              ),
                            ),
                          ),
                      
                        ],
                      ),
                      
                      const SizedBox(height: 8,),
                      
                      // ----------------------------------- password
                      ReactiveTextField<String>(
                        formControlName: 'password',
                        obscureText: !_passwordVisible,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(color: MyColors.textoSobreClaro) ,
                        decoration:  InputDecoration(
                          labelText: texts.password,
                          errorBorder: const OutlineInputBorder(borderSide: BorderSide(color:MyColors.textoError),borderRadius: BorderRadius.all(Radius.circular(12))),
                          errorMaxLines: 2,
                          fillColor:  Colors.white,
                          filled: true,
                          labelStyle: const TextStyle(color: MyColors.textoSobreClaro) ,
                          border: const OutlineInputBorder(borderSide: BorderSide(color: MyColors.textoSobreClaro), borderRadius: BorderRadius.all(Radius.circular(12))),
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: MyColors.textoSobreClaro), borderRadius: BorderRadius.all(Radius.circular(12))),
                          suffixIconColor: MyColors.textoSobreClaro,
                          suffixIcon: IconButton(
                            icon: Icon(_passwordVisible ? Icons.visibility: Icons.visibility_off),
                            onPressed: () {
                              setState(() { _passwordVisible = !_passwordVisible;});
                            },
                          )
                        ),
                      ),
                      
                      // ----------------------------------- conectar button
                      const SizedBox(height: 32,),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(onPressed: (){
                                //_removeFocus(context);
                                if(formGroup.valid){
                                  
                                  formGroup.markAllAsTouched();
                                    Navigator.of(context).pop();
                                    context.read<OBSBloc>().add(OBSConnect(connection: OBSConnection.fromJson(formGroup.value)));
                                }else {
                                  formGroup.markAllAsTouched();
                                            
                                }
                               
                              }, child: const Text(texts.connect)),
                            ),
                          ),
                        ],
                      )
                      
                    ],
                  );
                },
              ),
            );
          }
        ),

      );
    },);
  }
  /// devuelve el listado de las escenas
  Widget _buildScenes() {
    return StreamBuilder(
      stream: context.read<OBSBloc>().sceneStream,
      builder: (context, scenesSnapshot) {
        if(scenesSnapshot.hasData){
          List<OBSScene> scenes = scenesSnapshot.data!;
     
          return GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: scenes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8
            ), 
            itemBuilder: (context, index) {
              return _buildSceneItem(scenes[index]);
            },
          );
        }
     

        return const SizedBox();
      },
    );
  }

  /// devuelve el listado de las escenas
  Widget _buildAudioTracks() {
    return StreamBuilder(
      stream: context.read<OBSBloc>().audioTrackStream,
      builder: (context, scenesSnapshot) {
        if(scenesSnapshot.hasData){
          List<OBSAudioTrack> audioTracks = scenesSnapshot.data!;

          return Column(
            children: [
              const Text('Audio general'),
              _buildListAudioTracks(audioTracks.where((element) => element.isGlobal).toList()),
              const Text('Audio de la escena'),
              _buildListAudioTracks(audioTracks.where((element) => !element.isGlobal).toList()),
            
            ],
          );
        }


        return const SizedBox();
      },
    );
  }

  Widget _buildListAudioTracks(List<OBSAudioTrack> audioTracks){
    return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: audioTracks.length,
             
            itemBuilder: (context, index) {
              return _buildAudioTrackSlider(audioTracks[index]);
            },
          );
  }

  Widget _buildAudioTrackSlider(OBSAudioTrack audioTrack){
    return Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(audioTrack.name),
            Text('${Utils.roundDouble(audioTrack.volumenDB, 2)} dB'),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            GestureDetector(
              onTap: () => context.read<OBSBloc>().add(OBSChangeTrackMute(audioTrackName: audioTrack.name, isMuted: !audioTrack.isMuted)),
              child: Icon(audioTrack.isMuted ? Icons.volume_off : Icons.volume_up)),
            const SizedBox(width: 8,),
           
            Expanded(
              child: NonLinearSlider(
                
                intervals: [
                  NLSInterval(-100,-33, 0.25),
                  NLSInterval(-33, -12, 0.25),
                  NLSInterval(-12,-5, 0.25),
                  NLSInterval(-5, 1, 0.25),
                ],
                //overlayColor: Colors.amber,
                value: audioTrack.volumenDB , //_linearValue(audioTrack.volumenDB), 
                onChanged: (newVolumen){
                  context.read<OBSBloc>().add(OBSChangeTrackVolumen(
                      audioTrackName:audioTrack.name, 
                      newVolumen: newVolumen));
                }
                
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildSceneItem(OBSScene scene){
    return GestureDetector(
      onTap: () {
        context.read<OBSBloc>().add(OBSChangeScene(scene: scene));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: scene.isActual ? MyColors.primaryColor: Colors.white,
        child: Center(
          child: Text(
            scene.name,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(color: !scene.isActual ? MyColors.primaryColor: Colors.white,),
          ),
        ),
      ),
    );
  }
  
  Widget _closeConnection() {
    return ElevatedButton(onPressed: (){
      context.read<OBSBloc>().add(OBSClose());
    }, child: const Text('Cerrar obs'));
  }

}