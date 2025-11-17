import '../models/case_model.dart';
import '../models/livestock_model.dart';
import '../models/community_model.dart';

/// Mock data service for development and testing
/// This provides sample data when API is unavailable or for UI testing
class MockDataService {
  // Mock Community Posts
  static List<Map<String, dynamic>> getMockPosts() {
    return [
      {
        'id': 1,
        'author': 'Rajendra Deshpande',
        'location': 'Latur, Maharashtra',
        'time': '21 Nov 09.30 am',
        'content': 'I have 40 Acres of Wheat farming in Latur. I want to export my Wheat out of India. How can I grow faster and export quality?',
        'image': 'assets/images/community_post_1.jpg',
        'tags': ['Rain', 'Weather', 'Problem', 'Wheat', 'Export'],
        'likes': 200,
        'comments': 100,
        'saves': 50,
        'shares': 25,
        'type': 'post',
      },
      {
        'id': 2,
        'author': 'Farmzi Expert',
        'location': 'Yavatmal, Maharashtra',
        'time': '21 Nov 09.30 am',
        'content': 'I have 40 Acres of Wheat farming in Latur. I want to export my Wheat out of India. How can I grow faster and export quality?',
        'videoTitle': 'Indian Agriculture',
        'duration': '20:17',
        'marketView': 'Hi Kisan Brothers, Production of Soyabean this year is less than last years production. Also damage of crop is increase this year around the world which result in high demand and low supply of Soyabean.',
        'tags': ['Rain', 'Weather', 'Problem', 'Wheat', 'Export'],
        'likes': 32,
        'comments': 4,
        'saves': 2,
        'shares': 0,
        'type': 'video',
      },
    ];
  }

  // Mock Community Feed Cards
  static List<Map<String, dynamic>> getMockCommunityCards() {
    return [
      {
        'id': 1,
        'title': 'Crop Rotation Techniques',
        'description': 'Join the discussion on best practices for crop rotation to enhance soil fertility.',
        'image': 'assets/images/crop_rotation.jpg',
      },
      {
        'id': 2,
        'title': 'Pest Control Meetup',
        'description': 'Meet local experts and discuss organic pest control methods this Saturday.',
        'image': 'assets/images/pest_control.jpg',
      },
    ];
  }

  // Mock Chat Conversations
  static List<Map<String, dynamic>> getMockChats() {
    return [
      {
        'id': 1,
        'name': 'Latur Kisan Vibhag',
        'lastMessage': 'Please, Upload your docum...',
        'date': '21/11/21',
        'unreadCount': 4,
        'avatar': 'assets/images/chat_avatar_1.jpg',
      },
      {
        'id': 2,
        'name': 'Ner Kisan Vibhag',
        'lastMessage': 'Photo',
        'date': '21/11/21',
        'unreadCount': 4,
        'avatar': 'assets/images/chat_avatar_2.jpg',
      },
    ];
  }

  // Mock Market Products
  static List<Map<String, dynamic>> getMockProducts({String category = 'Vegetables'}) {
    final allProducts = {
      'Vegetables': [
        {'id': 1, 'name': 'Tomatoes', 'price': '\$1.99/kg', 'image': 'assets/images/tomatoes.jpg'},
        {'id': 2, 'name': 'Potatoes', 'price': '\$0.79/kg', 'image': 'assets/images/potatoes.jpg'},
        {'id': 3, 'name': 'Lettuce', 'price': '\$2.49/head', 'image': 'assets/images/lettuce.jpg'},
        {'id': 4, 'name': 'Carrots', 'price': '\$1.59/kg', 'image': 'assets/images/carrots.jpg'},
      ],
      'Fruits': [
        {'id': 5, 'name': 'Apples', 'price': '\$2.99/kg', 'image': 'assets/images/apples.jpg'},
        {'id': 6, 'name': 'Bananas', 'price': '\$1.49/kg', 'image': 'assets/images/bananas.jpg'},
        {'id': 7, 'name': 'Oranges', 'price': '\$2.29/kg', 'image': 'assets/images/oranges.jpg'},
        {'id': 8, 'name': 'Mangoes', 'price': '\$3.99/kg', 'image': 'assets/images/mangoes.jpg'},
      ],
      'Grains': [
        {'id': 9, 'name': 'Wheat', 'price': '\$0.89/kg', 'image': 'assets/images/wheat.jpg'},
        {'id': 10, 'name': 'Rice', 'price': '\$1.29/kg', 'image': 'assets/images/rice.jpg'},
        {'id': 11, 'name': 'Corn', 'price': '\$0.99/kg', 'image': 'assets/images/corn.jpg'},
        {'id': 12, 'name': 'Barley', 'price': '\$1.19/kg', 'image': 'assets/images/barley.jpg'},
      ],
    };
    return allProducts[category] ?? [];
  }

  // Mock Weather Data
  static Map<String, dynamic> getMockWeather({String? location}) {
    return {
      'location': location ?? 'Vellore, Tamil Nadu',
      'temperature': 28,
      'condition': 'Partly Cloudy',
      'high': 30,
      'low': 15,
      'humidity': 65,
      'windSpeed': 12,
      'hourlyForecast': [
        {'time': 'Now', 'temp': 28, 'icon': 'sunny'},
        {'time': '12 PM', 'temp': 30, 'icon': 'cloudy'},
        {'time': '3 PM', 'temp': 29, 'icon': 'cloudy'},
        {'time': '6 PM', 'temp': 27, 'icon': 'night'},
      ],
    };
  }

  // Mock Trending News
  static Map<String, dynamic> getMockTrendingNews() {
    return {
      'location': 'Karangazi, Nyagatare',
      'temperature': 28,
      'high': 30,
      'low': 15,
      'title': 'Nutritious Feeds',
      'image': 'assets/images/trending_news.jpg',
    };
  }

  // Mock Home Feed Items
  static List<Map<String, dynamic>> getMockHomeFeed({String filter = 'All'}) {
    return [
      {
        'type': 'card',
        'title': 'How to use app',
        'description': 'learn about all the features of app',
        'image': 'assets/images/how_to_use.jpg',
      },
      {
        'type': 'card',
        'title': 'Breeding Tips',
        'description': 'The best breeding advices for your livestock',
        'image': 'assets/images/breeding_tips.jpg',
      },
      {
        'type': 'news',
        'data': getMockTrendingNews(),
      },
    ];
  }
}

