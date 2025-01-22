import 'dart:ui';

class Recognition {
  String name;
  String createdAt;
  Rect location;
  List<double> embeddings;
  double distance;
  Recognition(this.name, this.createdAt, this.location,this.embeddings,this.distance);
}