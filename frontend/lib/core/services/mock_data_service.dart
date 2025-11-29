/// Mock data service for development and testing
/// This provides sample data when API is unavailable or for UI testing
class MockDataService {
  // Mock Community Posts
  static List<Map<String, dynamic>> getMockPosts() {
    return [
      {
        'id': 1,
        'author': 'Jean Baptiste',
        'location': 'Nyagatare, Rwanda',
        'time': '21 Nov 09.30 am',
        'content':
            'I have 20 head of cattle in Nyagatare. Looking for advice on improving milk production and managing grazing during dry season. Any experienced farmers here?',
        'image':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=800', // Cow image
        'tags': [
          'Cattle',
          'Milk Production',
          'Grazing',
          'Livestock Management'
        ],
        'likes': 200,
        'comments': 100,
        'saves': 50,
        'shares': 25,
        'type': 'post',
      },
      {
        'id': 2,
        'author': 'AnimalGuardian Expert',
        'location': 'Nyagatare, Rwanda',
        'time': '21 Nov 09.30 am',
        'content':
            'Important: Vaccination schedule for livestock in Nyagatare district. This year we are seeing increased cases of foot-and-mouth disease. Make sure your cattle, goats, and sheep are vaccinated on time.',
        'videoTitle': 'Livestock Health in Rwanda',
        'duration': '20:17',
        'marketView':
            'Hi Abahinzi (Farmers), The livestock market in Nyagatare is showing strong demand for healthy cattle and goats. Prices are good this season. Make sure your animals are healthy and properly documented before bringing them to market.',
        'tags': ['Vaccination', 'Health', 'Disease Prevention', 'Livestock'],
        'likes': 32,
        'comments': 4,
        'saves': 2,
        'shares': 0,
        'type': 'video',
      },
      {
        'id': 3,
        'author': 'Marie Uwimana',
        'location': 'Nyagatare, Rwanda',
        'time': '20 Nov 02.15 pm',
        'content':
            'Best practices for goat breeding and management. Sharing my experience with Ankole goats - they are well adapted to our climate in Nyagatare. Tips on feeding, housing, and health care.',
        'image':
            'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=800', // Goat image
        'tags': ['Goats', 'Breeding', 'Ankole', 'Livestock Care'],
        'likes': 150,
        'comments': 45,
        'saves': 30,
        'shares': 12,
        'type': 'post',
      },
      {
        'id': 4,
        'author': 'Dr. Paul Nkurunziza',
        'location': 'Nyagatare, Rwanda',
        'time': '19 Nov 10.00 am',
        'content':
            'Livestock management tips for healthy animals in Rwanda. Learn about proper feeding schedules, vaccination programs, and disease prevention. Important for farmers in Nyagatare district.',
        'image':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=800', // Cow image
        'tags': ['Livestock', 'Health', 'Management', 'Vaccination'],
        'likes': 89,
        'comments': 23,
        'saves': 15,
        'shares': 8,
        'type': 'post',
      },
    ];
  }

  // Mock Community Feed Cards
  static List<Map<String, dynamic>> getMockCommunityCards() {
    return [
      {
        'id': 1,
        'title': 'Cattle Breeding Workshop',
        'description':
            'Join the discussion on best practices for cattle breeding and improving herd quality in Nyagatare.',
        'image':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=600', // Cow image
      },
      {
        'id': 2,
        'title': 'Livestock Disease Prevention',
        'description':
            'Meet local veterinarians and discuss disease prevention methods for cattle, goats, and sheep this Saturday.',
        'image':
            'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=600', // Goat image
      },
      {
        'id': 3,
        'title': 'Livestock Health Workshop',
        'description':
            'Learn about common livestock diseases and preventive measures from veterinary experts in Nyagatare.',
        'image':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=600', // Cow image
      },
      {
        'id': 4,
        'title': 'Grazing Management Seminar',
        'description':
            'Discover sustainable grazing methods and pasture management for livestock in Rwanda.',
        'image':
            'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=600', // Sheep image
      },
    ];
  }

  // Mock Chat Conversations
  static List<Map<String, dynamic>> getMockChats() {
    return [
      {
        'id': 1,
        'name': 'Nyagatare Livestock Group',
        'lastMessage': 'Please, Upload your docum...',
        'date': '21/11/21',
        'unreadCount': 4,
        'avatar':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=100',
      },
      {
        'id': 2,
        'name': 'Rwanda Farmers Network',
        'lastMessage': 'Photo',
        'date': '21/11/21',
        'unreadCount': 4,
        'avatar':
            'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=100',
      },
      {
        'id': 3,
        'name': 'Livestock Support Group',
        'lastMessage': 'New livestock management tips shared',
        'date': '20/11/21',
        'unreadCount': 2,
        'avatar':
            'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=100',
      },
      {
        'id': 4,
        'name': 'Livestock Care Community',
        'lastMessage': 'Vaccination schedule updated',
        'date': '19/11/21',
        'unreadCount': 0,
        'avatar':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=100',
      },
    ];
  }

  // Mock Market Products (Livestock)
  static List<Map<String, dynamic>> getMockProducts(
      {String category = 'Cattle'}) {
    final allProducts = {
      'Cattle': [
        {
          'id': 1,
          'name': 'Ankole Cattle',
          'price': 'RWF 800,000',
          'image':
              'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=400'
        },
        {
          'id': 2,
          'name': 'Holstein Cow',
          'price': 'RWF 1,200,000',
          'image':
              'https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=400'
        },
        {
          'id': 3,
          'name': 'Jersey Cow',
          'price': 'RWF 1,000,000',
          'image':
              'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=400'
        },
        {
          'id': 4,
          'name': 'Local Breed Bull',
          'price': 'RWF 900,000',
          'image':
              'https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=400'
        },
        {
          'id': 13,
          'name': 'Crossbreed Heifer',
          'price': 'RWF 750,000',
          'image':
              'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=400'
        },
        {
          'id': 14,
          'name': 'Dairy Cow',
          'price': 'RWF 1,100,000',
          'image':
              'https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=400'
        },
      ],
      'Goats': [
        {
          'id': 5,
          'name': 'Ankole Goat',
          'price': 'RWF 80,000',
          'image':
              'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400'
        },
        {
          'id': 6,
          'name': 'Boer Goat',
          'price': 'RWF 120,000',
          'image':
              'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400'
        },
        {
          'id': 7,
          'name': 'Nubian Goat',
          'price': 'RWF 100,000',
          'image':
              'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400'
        },
        {
          'id': 8,
          'name': 'Local Goat',
          'price': 'RWF 60,000',
          'image':
              'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400'
        },
        {
          'id': 15,
          'name': 'Goat Kid',
          'price': 'RWF 40,000',
          'image':
              'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400'
        },
        {
          'id': 16,
          'name': 'Breeding Buck',
          'price': 'RWF 150,000',
          'image':
              'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400'
        },
      ],
      'Sheep': [
        {
          'id': 9,
          'name': 'Dorper Sheep',
          'price': 'RWF 100,000',
          'image':
              'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=400'
        },
        {
          'id': 10,
          'name': 'Merino Sheep',
          'price': 'RWF 90,000',
          'image':
              'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=400'
        },
        {
          'id': 11,
          'name': 'Local Sheep',
          'price': 'RWF 70,000',
          'image':
              'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=400'
        },
        {
          'id': 12,
          'name': 'Ewe',
          'price': 'RWF 85,000',
          'image':
              'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=400'
        },
        {
          'id': 17,
          'name': 'Ram',
          'price': 'RWF 110,000',
          'image':
              'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=400'
        },
        {
          'id': 18,
          'name': 'Lamb',
          'price': 'RWF 50,000',
          'image':
              'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=400'
        },
      ],
    };
    return allProducts[category] ?? [];
  }

  // Mock Weather Data
  static Map<String, dynamic> getMockWeather({String? location}) {
    return {
      'location': location ?? 'Nyagatare, Rwanda',
      'temperature': 24,
      'condition': 'Partly Cloudy',
      'high': 26,
      'low': 18,
      'humidity': 70,
      'windSpeed': 10,
      'hourlyForecast': [
        {'time': 'Now', 'temp': 24, 'icon': 'sunny'},
        {'time': '12 PM', 'temp': 26, 'icon': 'cloudy'},
        {'time': '3 PM', 'temp': 25, 'icon': 'cloudy'},
        {'time': '6 PM', 'temp': 22, 'icon': 'night'},
      ],
    };
  }

  // Mock Trending News
  static Map<String, dynamic> getMockTrendingNews() {
    return {
      'location': 'Karangazi, Nyagatare',
      'temperature': 24,
      'high': 26,
      'low': 18,
      'title': 'Livestock Feed & Nutrition',
      'image':
          'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=600', // Cow image
    };
  }

  // Mock Home Feed Items
  static List<Map<String, dynamic>> getMockHomeFeed({String filter = 'All'}) {
    final allItems = [
      {
        'type': 'card',
        'title': 'How to use app',
        'description': 'learn about all the features of app',
        'image':
            'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=600',
        'category': 'Tutorial',
      },
      {
        'type': 'card',
        'title': 'Breeding Tips',
        'description': 'The best breeding advices for your livestock',
        'image':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=600', // Cow image
        'category': 'Livestock',
      },
      {
        'type': 'card',
        'title': 'Livestock Health Management',
        'description':
            'Essential tips for managing your livestock health effectively',
        'image':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=600', // Cow image
        'category': 'Livestock',
      },
      {
        'type': 'card',
        'title': 'Market Prices',
        'description':
            'Stay updated with current market prices for livestock in Nyagatare',
        'image':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=600', // Cow image
        'category': 'Market',
      },
      {
        'type': 'news',
        'data': getMockTrendingNews(),
        'category': 'News',
      },
    ];

    if (filter == 'All') {
      return allItems;
    }

    return allItems.where((item) => item['category'] == filter).toList();
  }

  // Mock Livestock Data
  static List<Map<String, dynamic>> getMockLivestock() {
    return [
      {
        'id': 1,
        'name': 'Bella',
        'type': 'Cow',
        'breed': 'Holstein',
        'status': 'healthy',
        'age': '3 years',
        'image':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=400', // Cow image
      },
      {
        'id': 2,
        'name': 'Max',
        'type': 'Goat',
        'breed': 'Boer',
        'status': 'healthy',
        'age': '2 years',
        'image':
            'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400', // Goat image
      },
      {
        'id': 3,
        'name': 'Luna',
        'type': 'Sheep',
        'breed': 'Dorper',
        'status': 'sick',
        'age': '1 year',
        'image':
            'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=400', // Sheep image
      },
      {
        'id': 4,
        'name': 'Charlie',
        'type': 'Cow',
        'breed': 'Jersey',
        'status': 'healthy',
        'age': '4 years',
        'image':
            'https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=400', // Cow image
      },
      {
        'id': 5,
        'name': 'Daisy',
        'type': 'Goat',
        'breed': 'Nubian',
        'status': 'healthy',
        'age': '1.5 years',
        'image':
            'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400', // Goat image
      },
      {
        'id': 6,
        'name': 'Wooly',
        'type': 'Sheep',
        'breed': 'Merino',
        'status': 'healthy',
        'age': '2 years',
        'image':
            'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=400', // Sheep image
      },
      {
        'id': 7,
        'name': 'Porky',
        'type': 'Pig',
        'breed': 'Yorkshire',
        'status': 'healthy',
        'age': '1 year',
        'image':
            'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=400', // Pig image
      },
      {
        'id': 8,
        'name': 'Bessie',
        'type': 'Cow',
        'breed': 'Angus',
        'status': 'sick',
        'age': '5 years',
        'image':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=400', // Cow image
      },
    ];
  }

  // Mock Vet Assigned Cases Data
  static List<Map<String, dynamic>> getMockVetAssignedCases() {
    return [
      {
        'id': 1,
        'caseId': 'CASE-001',
        'livestock': 'Bella (Cow)',
        'farmer': 'Jean Baptiste',
        'farmerPhone': '+250788123456',
        'symptoms': 'Loss of appetite, lethargy',
        'status': 'assigned',
        'urgency': 'high',
        'date': '2024-01-15',
        'location': 'Nyagatare, Rwanda',
        'image':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=400', // Cow image
        'notes': 'Initial assessment needed',
      },
      {
        'id': 2,
        'caseId': 'CASE-002',
        'livestock': 'Luna (Sheep)',
        'farmer': 'Marie Uwimana',
        'farmerPhone': '+250788234567',
        'symptoms': 'Coughing, nasal discharge',
        'status': 'in_progress',
        'urgency': 'medium',
        'date': '2024-01-14',
        'location': 'Karangazi, Nyagatare',
        'image':
            'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=400', // Sheep image
        'notes': 'Treatment in progress',
      },
      {
        'id': 3,
        'caseId': 'CASE-003',
        'livestock': 'Max (Goat)',
        'farmer': 'Paul Nkurunziza',
        'farmerPhone': '+250788345678',
        'symptoms': 'Lameness in left leg',
        'status': 'resolved',
        'urgency': 'low',
        'date': '2024-01-10',
        'location': 'Nyagatare, Rwanda',
        'image':
            'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400', // Goat image
        'notes': 'Successfully treated',
      },
    ];
  }

  // Mock Cases Data
  static List<Map<String, dynamic>> getMockCases() {
    return [
      {
        'id': 1,
        'caseId': 'CASE-001',
        'livestock': 'Bella (Cow)',
        'symptoms': 'Loss of appetite, lethargy',
        'status': 'pending',
        'urgency': 'high',
        'date': '2024-01-15',
        'image':
            'https://images.unsplash.com/photo-1560114928-40f1f1eb26a0?w=400', // Cow image
      },
      {
        'id': 2,
        'caseId': 'CASE-002',
        'livestock': 'Luna (Sheep)',
        'symptoms': 'Coughing, nasal discharge',
        'status': 'under_review',
        'urgency': 'medium',
        'date': '2024-01-14',
        'image':
            'https://images.unsplash.com/photo-1500462918059-b1a0cb512f1d?w=400', // Sheep image
      },
      {
        'id': 3,
        'caseId': 'CASE-003',
        'livestock': 'Max (Goat)',
        'symptoms': 'Lameness in left leg',
        'status': 'resolved',
        'urgency': 'low',
        'date': '2024-01-10',
        'image':
            'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400', // Goat image
      },
      {
        'id': 4,
        'caseId': 'CASE-004',
        'livestock': 'Bessie (Cow)',
        'symptoms': 'Fever, reduced milk production',
        'status': 'pending',
        'urgency': 'high',
        'date': '2024-01-16',
        'image':
            'https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=400', // Cow image
      },
      {
        'id': 5,
        'caseId': 'CASE-005',
        'livestock': 'Porky (Pig)',
        'symptoms': 'Skin lesions, itching',
        'status': 'under_review',
        'urgency': 'medium',
        'date': '2024-01-13',
        'image':
            'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=400', // Pig image
      },
      {
        'id': 6,
        'caseId': 'CASE-006',
        'livestock': 'Daisy (Goat)',
        'symptoms': 'Diarrhea, dehydration',
        'status': 'resolved',
        'urgency': 'low',
        'date': '2024-01-08',
        'image':
            'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=400', // Goat image
      },
    ];
  }
}
