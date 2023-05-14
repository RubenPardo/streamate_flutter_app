import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/core/service_locator.dart';
import 'package:streamate_flutter_app/data/model/channel_info.dart';
import 'package:streamate_flutter_app/data/model/stream_category.dart';
import 'package:streamate_flutter_app/domain/repositories/twitch_channel_repository.dart';
import 'package:streamate_flutter_app/presentation/bloc/settings/settings_event.dart';
import 'package:streamate_flutter_app/presentation/bloc/settings/settings_state.dart';

class CattegoryBloc extends Bloc<CategoryEvent,CategoryState>{
  ChannelInfo? channelInfo;

  CattegoryBloc():super(CateogriesLoaded(cateogires: [])){
    
    final TwitchChannelRepository _channelRepository = serviceLocator<TwitchChannelRepository>();

    on<CategorySearch>(
      (event, emit) async{
          try{
            
            
            String gameName = event.gameName;
            List<StreamCategory> cateogries = await _channelRepository.getCategoiresByGameName(gameName: gameName);
            
            emit(CateogriesLoaded(cateogires: cateogries));
           

            
          }catch(e){
            log(e.toString());
            emit(CateogryError());
          }
      },
    );

  }

}

abstract class CategoryEvent{}
class CategorySearch extends CategoryEvent{
  final String gameName;
  CategorySearch({required this.gameName});
}

abstract class CategoryState{}
class CateogriesLoaded extends CategoryState{
  final List<StreamCategory> cateogires;
  CateogriesLoaded({required this.cateogires});
}
class CateogryError extends CategoryState{

}