/// 可比较的图像特征向量。
abstract class ImageFeature {
  List<double> get vector;
  int get dim;
  double cosineSimilarity(ImageFeature other);
}
