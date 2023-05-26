
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streamate_flutter_app/data/model/stream_category.dart';
import 'package:streamate_flutter_app/data/model/user.dart';
import 'package:streamate_flutter_app/presentation/bloc/category/category_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/settings/settings_bloc.dart';
import 'package:streamate_flutter_app/presentation/bloc/settings/settings_event.dart';
import 'package:streamate_flutter_app/shared/widgets/category_list_item.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, this.initialCategory, required this.user});
  final StreamCategory? initialCategory;
  final User user;

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {

  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CattegoryBloc>().add(CategorySearch(gameName: ''));
  }

  
  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchCategory(),
      ),
      body: BlocConsumer<CattegoryBloc,CategoryState>(
        builder: (context, state) {
          if(state is CateogriesLoaded){
            return _buildCategoryList((state).cateogires);
          }else{
            // error
            return const Center(child: Text('Ha habido un error'),);
          }
        },
        listener: (context, state) {
          
        },
      ),
    );
  }

  Widget _buildSearchCategory(){
    return TextField(
      controller: _textEditingController,
      onChanged: (value) {
        context.read<CattegoryBloc>().add(CategorySearch(gameName: value));
      },
      decoration: const InputDecoration(
        hintText: 'Buscar categoría',
        suffixIcon: Icon(Icons.search),
        suffixIconColor: Colors.white
      ),
    );
  }
  
  Widget _buildCategoryList(List<StreamCategory> categories) {
    if(categories.isEmpty){
      return const Center(child: Text('Busca una categoria'),);
    }

    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            
            Navigator.of(context).pop(categories[index]);
          },
          child: CategoryListItem(category: categories[index]));
      },
    );
  }
}