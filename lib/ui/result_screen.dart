import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResultScreen extends StatefulWidget {

  final File image;
  final String predictedName;
  final double confidence;

  const ResultScreen({
    super.key,
    required this.image,
    required this.predictedName,
    required this.confidence
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  /*
  * Fetch API TheMealDB
  * */
  Future <Map<String, dynamic>?> fetchFoodDetail(String query) async {
    var url = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$query');
    try {
      var response = await http.get(url);

      debugPrint('📥 Status Code thmealdb: ${response.statusCode}');

      if(response.statusCode == 200) {
        debugPrint('📦 Response Body themealdb: ${response.body}');

        var data = jsonDecode(response.body);
        if(data['meals'] != null) {
          return data['meals'][0];
        }
      }

      // if themealdb has no data about the predicted food
      // use first word
      final words = query.split('');
      if(words.isNotEmpty && words[0].length>2) {
        final fallbackQuery = words[0];
        url = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$fallbackQuery');
        response = await http.get(url);

        if(response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if(data['meals'] != null) {
            return data['meals'][0];
          }
        }
      }



    } catch (e) {
      debugPrint('🌍Error fetching API themealdb: $e');
    }
    return null;
  }


  /*
  * Get rid with inpo ingredient & measure
  * */
  List<Widget> _buildIngredients(Map<String, dynamic> meal) {
    List<Widget> ingredients = [];
    for (int i=1; i<= 20; i++) {
      String? ingredient = meal['strIngredient$i'];
      String? measure = meal['strMeasure$i'];

      if(ingredient != null && ingredient.trim().isNotEmpty) {
        ingredients.add(
          Text('• $ingredient - $measure')
        );
      }
    }
    return ingredients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Food Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.file(
              widget.image,
              height: 248,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.predictedName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    'Confidence: ${(widget.confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const Divider(height: 24, thickness: 1),
                  const Text(
                    'About the food 🥘',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange
                    ),
                  ),
                  const SizedBox(height: 12,),
                  
                  FutureBuilder<Map<String, dynamic>?>(
                      future: fetchFoodDetail(widget.predictedName), 
                      builder: (context, snapshot) {
                        
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if(snapshot.hasError || !snapshot.hasData) {
                          return const Text('Receipt data not found');
                        }
                        
                        final meal = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                meal['strMealThumb'],
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'Food: ${meal['strMeal']}',
                              style: TextStyle(fontWeight: FontWeight.bold) ,
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'Ingredients:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ..._buildIngredients(meal),

                            const SizedBox(height: 12),

                            const Text(
                              'How to make',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 8),

                            Text(meal['strInstructions'] ?? '-')
                          ],
                        );
                      }
                  )
                  
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
