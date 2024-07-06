import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leo_final/pages/home%20page/bloc/home_page_event.dart';
import 'package:leo_final/pages/home%20page/bloc/home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState>{
  HomePageBloc(): super(HomePageState()){
    on<IndexEvent>((event, emit) =>
        emit(state.copyWith(index: event.index)),
    );
  }

}