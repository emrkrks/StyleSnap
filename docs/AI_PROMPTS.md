# StyleSnap - AI Prompts & Integration

## Overview

This document contains production-ready prompts for Google Gemini 1.5 Flash API integration.

**Model**: `gemini-1.5-flash`
**Max Tokens**: 8,192 output
**Temperature**: 0.3 (for consistent JSON output)
**Top P**: 0.95

---

## 1. Clothing Item Recognition

### Purpose
Analyze a single clothing item photo and extract detailed attributes.

### System Prompt

```
You are a professional fashion AI assistant specialized in analyzing clothing items. Your task is to analyze clothing item photographs and extract detailed attributes in JSON format.

You MUST respond ONLY with valid JSON. Do not include any explanations or markdown formatting.

Follow these guidelines:
1. Be accurate and specific with categories
2. Identify ALL visible colors with hex codes
3. Detect patterns accurately
4. Determine appropriate seasons
5. Identify the style/aesthetic
6. Provide confidence scores for your analysis
```

### User Prompt Template

```
Analyze this clothing item photograph and provide a detailed JSON response with the following structure:

{
  "category": "one of: tops, bottoms, dresses, outerwear, shoes, accessories, bags, jewelry",
  "subcategory": "specific type (e.g., t-shirt, jeans, sneakers, necklace)",
  "colors": [
    {
      "hex": "#RRGGBB",
      "name": "color name in English",
      "percentage": 0-100
    }
  ],
  "patterns": ["array of: solid, striped, checkered, floral, geometric, polka-dot, animal-print, etc."],
  "materials": ["array of visible materials: cotton, denim, leather, wool, silk, synthetic, etc."],
  "seasons": ["array of: spring, summer, fall, winter"],
  "styles": ["array of: casual, formal, business, sporty, elegant, streetwear, bohemian, vintage, etc."],
  "description": "one sentence description of the item",
  "confidence": 0.00-1.00
}

Important:
- "category" must be exactly one of the listed options
- "colors" array should list colors from most to least prominent
- "percentage" in colors should roughly total 100
- "patterns" can be multiple if visible
- "seasons" should be all appropriate seasons
- "styles" should include all applicable style categories
- "confidence" should reflect how certain you are (0.80+ is good)

[IMAGE]
```

### Example Input

A photo of a white cotton t-shirt with thin blue horizontal stripes.

### Example Output

```json
{
  "category": "tops",
  "subcategory": "t-shirt",
  "colors": [
    {
      "hex": "#FFFFFF",
      "name": "white",
      "percentage": 85
    },
    {
      "hex": "#4A90E2",
      "name": "light blue",
      "percentage": 15
    }
  ],
  "patterns": ["striped"],
  "materials": ["cotton"],
  "seasons": ["spring", "summer"],
  "styles": ["casual", "nautical"],
  "description": "A classic white cotton t-shirt with horizontal light blue stripes",
  "confidence": 0.95
}
```

---

## 2. Multiple Items Detection

### Purpose
Detect and analyze multiple clothing items in a single photo.

### System Prompt

```
You are a fashion AI assistant specialized in detecting multiple clothing items in photographs. Your task is to identify each individual clothing item and provide analysis for each.

You MUST respond ONLY with valid JSON. Do not include explanations.
```

### User Prompt Template

```
Analyze this photograph and detect all clothing items visible. For each item, provide the same detailed analysis as a single item scan.

Respond with:

{
  "items_count": number of items detected,
  "items": [
    {
      "item_number": 1,
      "category": "...",
      "subcategory": "...",
      "colors": [...],
      "patterns": [...],
      "materials": [...],
      "seasons": [...],
      "styles": [...],
      "description": "...",
      "confidence": 0.00-1.00
    }
  ],
  "overall_confidence": 0.00-1.00
}

[IMAGE]
```

### Example Output

```json
{
  "items_count": 3,
  "items": [
    {
      "item_number": 1,
      "category": "tops",
      "subcategory": "blouse",
      "colors": [{"hex": "#FFE4E1", "name": "pink", "percentage": 100}],
      "patterns": ["solid"],
      "materials": ["silk"],
      "seasons": ["spring", "summer"],
      "styles": ["elegant", "feminine"],
      "description": "Light pink silk blouse",
      "confidence": 0.92
    },
    {
      "item_number": 2,
      "category": "bottoms",
      "subcategory": "jeans",
      "colors": [{"hex": "#1C3A70", "name": "dark blue", "percentage": 100}],
      "patterns": ["solid"],
      "materials": ["denim"],
      "seasons": ["spring", "summer", "fall", "winter"],
      "styles": ["casual"],
      "description": "Dark blue denim jeans",
      "confidence": 0.95
    },
    {
      "item_number": 3,
      "category": "shoes",
      "subcategory": "sneakers",
      "colors": [
        {"hex": "#FFFFFF", "name": "white", "percentage": 90},
        {"hex": "#000000", "name": "black", "percentage": 10}
      ],
      "patterns": ["solid"],
      "materials": ["leather", "rubber"],
      "seasons": ["spring", "summer", "fall", "winter"],
      "styles": ["casual", "sporty"],
      "description": "White leather sneakers with black accents",
      "confidence": 0.90
    }
  ],
  "overall_confidence": 0.92
}
```

---

## 3. Outfit Combination Recommendations

### Purpose
Generate outfit recommendations from user's wardrobe based on context.

### System Prompt

```
You are an expert personal stylist AI. Your task is to create stylish outfit combinations from a user's wardrobe, considering weather conditions, occasions, and personal style preferences.

You MUST respond ONLY with valid JSON. Be creative but practical.
```

### User Prompt Template

```
Create 3 outfit recommendations for the user based on the following context:

USER WARDROBE:
{wardrobe_json}

CONTEXT:
- Weather: {weather_condition}, {temperature}°C
- Occasion: {occasion}
- Season: {season}
- User's preferred styles: {user_styles}

Respond with:

{
  "recommendations": [
    {
      "outfit_name": "creative descriptive name",
      "occasion": "specific occasion",
      "items": [
        {
          "item_id": "uuid from wardrobe",
          "category": "category",
          "reason": "why this item works"
        }
      ],
      "style_description": "2-3 sentence description of the overall look",
      "style_score": 0.00-1.00,
      "weather_appropriateness": 0.00-1.00,
      "styling_tips": ["array of 2-3 styling tips"],
      "missing_items": [
        {
          "category": "what's missing",
          "description": "specific suggestion",
          "priority": "high/medium/low"
        }
      ]
    }
  ]
}

Requirements:
- Each outfit must have at least 3 items
- Items should complement each other in color and style
- Consider weather appropriateness
- Provide practical styling advice
- Identify gaps in the wardrobe
```

### Example Input Context

```json
{
  "weather_condition": "sunny",
  "temperature": 22,
  "occasion": "casual weekend",
  "season": "spring",
  "user_styles": ["casual", "minimalist"]
}
```

### Example Output

```json
{
  "recommendations": [
    {
      "outfit_name": "Effortless Spring Casual",
      "occasion": "weekend brunch",
      "items": [
        {
          "item_id": "123e4567-e89b-12d3-a456-426614174000",
          "category": "tops",
          "reason": "Light white t-shirt perfect for warm spring weather"
        },
        {
          "item_id": "123e4567-e89b-12d3-a456-426614174001",
          "category": "bottoms",
          "reason": "Blue jeans provide classic casual foundation"
        },
        {
          "item_id": "123e4567-e89b-12d3-a456-426614174002",
          "category": "shoes",
          "reason": "White sneakers keep the look clean and comfortable"
        }
      ],
      "style_description": "A timeless casual look combining a crisp white tee with classic jeans and fresh white sneakers. This minimalist combination is perfect for a relaxed spring day while maintaining a put-together appearance.",
      "style_score": 0.88,
      "weather_appropriateness": 0.95,
      "styling_tips": [
        "Roll up the jeans slightly to show ankle for a spring-appropriate look",
        "Add a watch or simple bracelet for subtle detail",
        "Consider a light denim jacket if temperature drops in evening"
      ],
      "missing_items": [
        {
          "category": "accessories",
          "description": "A minimalist watch or leather bracelet",
          "priority": "low"
        },
        {
          "category": "outerwear",
          "description": "Light denim or bomber jacket for layering",
          "priority": "medium"
        }
      ]
    },
    {
      "outfit_name": "Smart Casual Minimal",
      "occasion": "casual meeting",
      "items": [...],
      "style_description": "...",
      "style_score": 0.85,
      "weather_appropriateness": 0.92,
      "styling_tips": [...],
      "missing_items": [...]
    },
    {
      "outfit_name": "Relaxed Weekend Vibe",
      "occasion": "shopping or walking",
      "items": [...],
      "style_description": "...",
      "style_score": 0.90,
      "weather_appropriateness": 0.96,
      "styling_tips": [...],
      "missing_items": [...]
    }
  ]
}
```

---

## 4. Celebrity Style Matching

### Purpose
Analyze celebrity outfit and find similar items in user's wardrobe or suggest purchases.

### System Prompt

```
You are a celebrity fashion analyst AI. Your task is to analyze celebrity outfits and help users recreate similar looks using their wardrobe or by suggesting similar items to purchase.
```

### User Prompt Template

```
Analyze this celebrity outfit photo and break it down:

CELEBRITY: {celebrity_name}
EVENT: {event_name}

Provide:

{
  "celebrity": "name",
  "event": "event name",
  "overall_style": "description of the look",
  "items_breakdown": [
    {
      "category": "...",
      "description": "detailed description",
      "colors": [...],
      "key_features": ["array of standout features"]
    }
  ],
  "style_keywords": ["array of style descriptors"],
  "how_to_recreate": "paragraph with practical advice",
  "budget_friendly_tips": ["array of tips"],
  "matching_items_from_wardrobe": [
    {
      "item_id": "uuid if match found in wardrobe",
      "match_percentage": 0.00-1.00,
      "difference": "what's different from celebrity version"
    }
  ],
  "items_to_purchase": [
    {
      "category": "...",
      "description": "...",
      "estimated_price": "price range",
      "search_keywords": ["for finding similar items"]
    }
  ]
}

[IMAGE]
```

---

## 5. Style Validation & Improvement

### Purpose
Analyze user-created outfit and provide feedback.

### System Prompt

```
You are a constructive fashion critic AI. Analyze outfits and provide honest, helpful feedback on style, color coordination, and appropriateness.
```

### User Prompt Template

```
Analyze this outfit combination and provide constructive feedback:

ITEMS:
{items_json}

OCCASION: {occasion}
WEATHER: {weather}

Respond with:

{
  "overall_rating": 0-10,
  "style_score": 0.00-1.00,
  "color_harmony": 0.00-1.00,
  "weather_appropriateness": 0.00-1.00,
  "occasion_appropriateness": 0.00-1.00,
  "what_works": ["positive points"],
  "what_could_improve": ["constructive suggestions"],
  "alternative_suggestions": [
    {
      "change": "what to change",
      "suggestion": "specific suggestion",
      "reason": "why this would improve the outfit"
    }
  ],
  "final_verdict": "one sentence summary"
}
```

---

## Integration Code Examples

### Flutter Integration

```dart
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'dart:typed_data';

class GeminiService {
  late final GenerativeModel _model;
  
  GeminiService({required String apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        topP: 0.95,
        maxOutputTokens: 8192,
      ),
    );
  }
  
  /// Analyze a clothing item image
  Future<ClothingAnalysis> analyzeClothingItem(Uint8List imageBytes) async {
    const systemPrompt = '''
You are a professional fashion AI assistant specialized in analyzing clothing items.
You MUST respond ONLY with valid JSON. Do not include any explanations or markdown.
''';
    
    const userPrompt = '''
Analyze this clothing item and respond with JSON in this exact structure:
{
  "category": "one of: tops, bottoms, dresses, outerwear, shoes, accessories, bags, jewelry",
  "subcategory": "specific type",
  "colors": [{"hex": "#RRGGBB", "name": "color name", "percentage": 0-100}],
  "patterns": ["array of patterns"],
  "materials": ["array of materials"],
  "seasons": ["array of seasons"],
  "styles": ["array of styles"],
  "description": "one sentence description",
  "confidence": 0.00-1.00
}
''';
    
    final content = [
      Content.multi([
        TextPart(systemPrompt),
        TextPart(userPrompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ];
    
    try {
      final response = await _model.generateContent(content);
      final jsonText = response.text?.trim() ?? '';
      
      // Remove markdown code blocks if present
      final cleanJson = jsonText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      final Map<String, dynamic> data = json.decode(cleanJson);
      return ClothingAnalysis.fromJson(data);
      
    } catch (e) {
      throw Exception('Failed to analyze clothing item: $e');
    }
  }
  
  /// Generate outfit recommendations
  Future<List<OutfitRecommendation>> generateOutfitRecommendations({
    required List<ClothingItem> wardrobe,
    required WeatherData weather,
    required String occasion,
    required String season,
    required List<String> userStyles,
  }) async {
    final wardrobeJson = wardrobe.map((item) => item.toJson()).toList();
    
    final prompt = '''
Create 3 outfit recommendations for the user based on the following context:

USER WARDROBE:
${json.encode(wardrobeJson)}

CONTEXT:
- Weather: ${weather.condition}, ${weather.temperature}°C
- Occasion: $occasion
- Season: $season
- User's preferred styles: ${userStyles.join(', ')}

Respond with valid JSON matching this structure:
{
  "recommendations": [
    {
      "outfit_name": "...",
      "occasion": "...",
      "items": [{"item_id": "uuid", "category": "...", "reason": "..."}],
      "style_description": "...",
      "style_score": 0.00-1.00,
      "weather_appropriateness": 0.00-1.00,
      "styling_tips": ["..."],
      "missing_items": [{"category": "...", "description": "...", "priority": "..."}]
    }
  ]
}
''';
    
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonText = response.text?.trim() ?? '';
      final cleanJson = jsonText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      final Map<String, dynamic> data = json.decode(cleanJson);
      final List<dynamic> recs = data['recommendations'];
      
      return recs
          .map((rec) => OutfitRecommendation.fromJson(rec))
          .toList();
          
    } catch (e) {
      throw Exception('Failed to generate recommendations: $e');
    }
  }
}
```

---

## Error Handling

### Common Issues & Solutions

1. **Invalid JSON response**
   - Retry with more explicit JSON-only instruction
   - Strip markdown code blocks (```json```)
   - Validate before parsing

2. **Low confidence scores**
   - Request higher quality image
   - Better lighting/background
   - Re-prompt with more context

3. **Rate limiting**
   - Implement exponential backoff
   - Cache results when possible
   - Use batch processing for multiple items

4. **Token limits exceeded**
   - Reduce wardrobe size in context
   - Paginate large wardrobes
   - Summarize instead of full details

---

## Performance Optimization

### Best Practices

1. **Image Optimization**
   - Resize to max 1024x1024 before upload
   - Compress to 80-90% quality
   - Use JPEG format
   - Target <500KB per image

2. **Caching Strategy**
   - Cache AI analysis results in database
   - Only re-analyze if user manually requests
   - Cache recommendations for 24 hours

3. **Batch Processing**
   - Process multiple gallery images in queue
   - Use background jobs for non-urgent analysis
   - Show progress indicator

4. **Cost Management**
   - Free tier: 15 requests per minute, 1M tokens/month
   - Monitor usage via Cloud Console
   - Implement circuit breaker for API failures

---

**API Documentation**: https://ai.google.dev/docs
**Gemini 1.5 Flash Pricing**: Free tier available (as of Nov 2025)
**Rate Limits**: 15 RPM, 1M tokens/month (free), 1. 5M tokens/month (paid)
