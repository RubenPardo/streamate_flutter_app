import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/auth_event.dart';
import 'package:streamate_flutter_app/shared/colors.dart';
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
                  // titulo ------------
                  _buildStremTitle(),
                  const SizedBox(height: 32,),
                  // categoria ------------
                  _buildCategory(),
                ],
              ),
              // cerrar sesión -----------
              Positioned(
                bottom: 0,
                child: LargeButton(
                  backgroundColor: MyColors.textoError,
                  onPressed: (){
                    context.read<AuthBloc>().add(LogOut());
                  }, 
                child: const  Text('Cerrar sesión',style: styles.textStyleButton,)
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
        TextField(
          minLines: 5,
          maxLines: 5,
          decoration: inputStyle,
        )
      ],
    );
  }

  ///
  Widget _buildCategory(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoría',style: styles.textStyleTitle2,),
        const SizedBox(height: 8,),
        TextField(
          
          decoration: inputStyle.copyWith(hintText: 'Buscar categoría',prefixIcon: const Icon(Icons.search)),
        )
      ],
    );
  }


}