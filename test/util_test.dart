import 'package:flutter_renting/services/util.dart';
import 'package:test/test.dart';

void main() {
  test('Util metthod testing', () {
    var longText = '人工智能是计算机科学的一个分支，它企图了解智能的实质，并生产出一种新的能以人类智能相似的方式做出反应的智能机器，该领域的研究包括机器人、语言识别、图像识别、自然语言处理和专家系统等。人工智能从诞生以来，理论和技术日益成熟，应用领域也不断扩大，可以设想，未来人工智能带来的科技产品，将会是人类智慧的“容器”。人工智能可以对人的意识、思维的信息过程的模拟。人工智能不是人的智能，但能像人那样思考、也可能超过人的智能。';
    expect(Util().showAbbreviatedText(10, longText), '人工智能是计算机科学...');
  });
}