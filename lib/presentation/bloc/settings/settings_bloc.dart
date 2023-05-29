import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/channel_info.dart';
import 'package:streamate_flutter_app/data/model/stream_category.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_channel_repository.dart';
import 'package:streamate_flutter_app/presentation/bloc/settings/settings_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/settings/settings_state.dart';

class SettingBloc extends Bloc<SettingsEvent,SettingsState>{
  ChannelInfo? channelInfo;

  SettingBloc():super(SettingsUninitialized()){
    
    final TwitchChannelRepository _channelRepository = serviceLocator<TwitchChannelRepository>();
    

    /// T/F, Texto -> InitSettings -> ChannelInfo
    /// si event.fromMemory es true emite el estado loaded del chanelInfo ya guardado
    /// si no lo obtiene de api 
    on<InitSettings>(
      (event, emit) async{
        try{
           if(event.fromMemory && channelInfo != null){
            emit(SettingsLoaded(channelInfo: channelInfo!));
          }else{
            // obtener el titulo y la categoria del directo
            emit(SettingsLoading());
            channelInfo = await _channelRepository.getChannelInfo(event.idBroadCaster);
            emit(SettingsLoaded(channelInfo: channelInfo!));

          }
        }catch(e){
          emit(SettingsError());
        }
        
      },
    );

    on<ChangeStreamSettings>(
      (event, emit) async{
        try{
            
            // obtener el titulo y la categoria del directo
            emit(SettingsLoading());
            StreamCategory newCategory = event.category;
            String newTitle = event.newTitle;

            bool valid = await _channelRepository.updateChannelInfo(newGameId: newCategory.gameId,newTitle: newTitle, idBroadCaster: event.idBroadCaster);
            // si ha ido todo ok cambiar el channel info por los datos nuevos y volver a emitirlos
            if(valid){
              channelInfo!.streamCategory = newCategory;
              channelInfo!.title = newTitle;
            }
            emit(SettingsLoaded(channelInfo: channelInfo!));
           

            
          }catch(e){
            emit(SettingsError());
          }
      },
    );

  }

}