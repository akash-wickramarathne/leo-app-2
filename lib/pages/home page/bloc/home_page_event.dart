class HomePageEvent{}

class IndexEvent extends HomePageEvent{
  IndexEvent({required this.index});

  final int index;
}