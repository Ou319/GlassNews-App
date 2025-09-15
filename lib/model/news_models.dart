class NewsResponse {
  final String status;
  final int totalResults;
  final List<Article> articles;

  NewsResponse({required this.status, required this.totalResults, required this.articles});

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] as String? ?? 'error',
      totalResults: json['totalResults'] as int? ?? 0,
      articles: (json['articles'] as List<dynamic>? ?? [])
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Article {
  final ArticleSource? source;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;

  Article({
    this.source,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: json['source'] != null ? ArticleSource.fromJson(json['source'] as Map<String, dynamic>) : null,
      author: json['author'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: (json['publishedAt'] as String?) != null ? DateTime.tryParse(json['publishedAt'] as String) : null,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source?.toJson(),
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
    };
  }
}

class ArticleSource {
  final String? id;
  final String? name;

  ArticleSource({this.id, this.name});

  factory ArticleSource.fromJson(Map<String, dynamic> json) {
    return ArticleSource(
      id: json['id'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}


