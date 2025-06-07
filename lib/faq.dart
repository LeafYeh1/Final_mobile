// faq.dart
import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      'question': 'Why is gardening a good activity for seniors?',
      'answer': 'Gardening helps older adults stay physically active, improve hand-eye coordination, and maintain flexibility. It also reduces stress, boosts mood, and can even promote better sleep — making it a great activity for both body and mind.'
    },
    {
      'question': 'Is gardening still possible for seniors with limited strength or mobility?',
      'answer': 'Absolutely! Gardening can be adapted to any ability level. Seniors can start with light tasks like watering or pruning. Raised garden beds, container gardening, and ergonomic tools can help make gardening accessible for everyone.'
    },
    {
      'question': 'What are some safe plants for seniors to grow at home?',
      'answer': 'Many herbs and vegetables are easy and safe to grow indoors or in small spaces. Basil, mint, cherry tomatoes, lettuce, and aloe vera are great options. These plants are low-maintenance, non-toxic, and provide a rewarding gardening experience for seniors.'
    },
    {
      'question': 'How can gardening improve mental health for older adults?',
      'answer': 'Gardening offers a sense of purpose and accomplishment, which can reduce feelings of loneliness and depression. Being in nature, caring for plants, and seeing progress over time can boost self-esteem and provide calmness — supporting emotional well-being.'
    },
    {
      'question': 'How often should seniors garden to enjoy its benefits?',
      'answer': 'Even just 15–30 minutes a few times a week can make a difference. Regular short gardening sessions help maintain mobility, lift mood, and provide structure to the day — without overexerting the body. Consistency is more important than duration.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('FAQ'),
        backgroundColor: Colors.brown[400],
      ),
      body: Container(
        color: Color(0xFFDCE8C8),
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            final faq = faqs[index];
            return Card(
              color: Colors.lightGreen[200],
              child: ListTile(
                title: Text('Q${index + 1} : ${faq['question']}', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('A : ${faq['answer']}'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

