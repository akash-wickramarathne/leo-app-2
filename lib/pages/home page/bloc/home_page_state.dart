class HomePageState{
  HomePageState({
    this.index = 0,
  });

  int index;

  HomePageState copyWith({
    int? index,
  }){
    return HomePageState(
      index: index ?? this.index
    );
  }
}