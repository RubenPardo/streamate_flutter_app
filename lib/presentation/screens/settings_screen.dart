import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/utils.dart';
import 'package:streamate_flutter_app/data/model/stream_category.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_channel_repository.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/settings/settings_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/settings/settings_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/settings/settings_state.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
import 'package:streamate_flutter_app/shared/widgets/category_list.dart';
import 'package:streamate_flutter_app/shared/widgets/large_primary_button.dart';
import 'package:streamate_flutter_app/shared/styles.dart' as styles;
import 'package:streamate_flutter_app/shared/texto_para_localizar.dart' as texts;


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.user});

  final User user;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  final TextEditingController _textEditingControllerTitle = TextEditingController();
  final TextEditingController _textEditingControllerCategory = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SettingBloc>().add(InitSettings(idBroadCaster: widget.user.id, fromMemory: context.read<SettingBloc>().channelInfo!=null));
  }
  @override
  void dispose() {
    super.dispose();
    _textEditingControllerCategory.dispose();
    _textEditingControllerTitle.dispose();
  }
   
  InputDecoration inputStyle = const InputDecoration(
            hintText: 'Introduce un título',
            border: UnderlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(8))),
            fillColor: MyColors.backgroundColorSecondary,
            filled: true
          );

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(  
      slivers: [ 
      SliverFillRemaining(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              
              Column(
      
                children: [
                  // perfil ------------
                  _buildProfile(),
                  const SizedBox(height: 32,),
                  BlocConsumer<SettingBloc, SettingsState>(
                    builder: (context, state) {
                      if(state is SettingsLoading){
                        return  const Center(child: CircularProgressIndicator(),);
                      }else if(state is SettingsLoaded || state is SettingsError){
                        return Column(
                          children: [
                            // titulo ------------
                            _buildStremTitle(),
                            const SizedBox(height: 32,),
                            // categoria ------------
                            _buildCategory(streamCategory: state is SettingsLoaded ? state.channelInfo.streamCategory : null),
                          ],
                        );
                      }

                      return const SizedBox();
                    },
                    listener: (context, state) {
                      // actualizar los valores de los edit texts por sus controles 
                      // con un set state en el listener del bloc
                      if(state is SettingsLoaded){
                        setState(() {
                          _textEditingControllerTitle.text = state.channelInfo.title;
                          _textEditingControllerCategory.text = state.channelInfo.streamCategory.gameName;
                        });
                      }
                    },
                  ),
                ],
              ),

              
              // cerrar sesión -----------
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Align(
                  alignment:Alignment.bottomCenter,
                  child: LargeButton(
                    backgroundColor: MyColors.textoError,
                    onPressed: (){
                      Utils.showConfirmDialog(
                        context, 
                        texts.logoutTitleDialog,
                        const Text(texts.logoutContentDialog,style: TextStyle(color: MyColors.textoSobreClaro),), 
                        () => context.read<AuthBloc>().add(LogOut()));
                    }, 
                  child: const  Text('Cerrar sesión',style: styles.textStyleButton,)
                          ),
                ),
              )
            ],
          ),
        ),
      ),
      ]
    );
  }

  /// devuelve un row con la imagen de perfil y el nombre de usuario
  Widget _buildProfile(){
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: Image.network(widget.user.profileImageUrl)),
        const SizedBox(width: 16,),
        Flexible(
          flex: 4,
          child: Text(widget.user.displayName,style: styles.textStyleTitle,))
      ],
    );
  }


  ///
  Widget _buildStremTitle(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Título del directo',style: styles.textStyleTitle2,),
        const SizedBox(height: 8,),
        Focus(
          onFocusChange: (hasFocus) {
            if(!hasFocus){
              }
          },
          child: TextField(
            onSubmitted: (value) {
              context.read<SettingBloc>().add(ChangeStreamTitle(newTitle: value, idBroadCaster: widget.user.id));
            },
            minLines: 5,
            maxLines: 5,
            decoration: inputStyle,
            controller: _textEditingControllerTitle,
          ),
        )
      ],
    );
  }

  ///
  Widget _buildCategory({StreamCategory? streamCategory}){
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CategoryList(initialCategory: streamCategory,user: widget.user,),));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Categoría',style: styles.textStyleTitle2,),
          const SizedBox(height: 8,),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: MyColors.backgroundColorSecondary,
            ),
            child: Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 8,),
                Text(streamCategory?.gameName ?? 'Buscar categoría'),
              ],
            ),
          ),
          
        ],
      ),
    );
  }


}