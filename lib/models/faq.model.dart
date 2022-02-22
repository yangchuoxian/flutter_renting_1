class CustomerFAQ {
  String title;
  String content;

  CustomerFAQ({
    this.title,
    this.content,
  });

  factory CustomerFAQ.fromJson(Map<String, dynamic> json) {
    return CustomerFAQ(
      title: json['title'],
      content: json['content'],
    );
  }
}
