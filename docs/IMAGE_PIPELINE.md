# StyleSnap - Image Pipeline & Wardrobe Scanning

## 📸 Overview

Complete implementation guide for wardrobe scanning: from camera capture to AI-analyzed clothing items stored in Supabase.

**Flow**: Camera/Gallery → Image Preprocessing → Background Removal (Optional) → Gemini AI Analysis → Save to Database

---

## 🔧 Required Packages

**pubspec.yaml**:
```yaml
dependencies:
  # Image handling
  image_picker: ^1.0.7
  image: ^4.1.7
  
  # ML & AI
  google_ml_kit: ^0.18.0
  google_generative_ai: ^0.4.3
  
  # Storage
  supabase_flutter: ^2.5.6
  
  # Utilities
  path_provider: ^2.1.2
  uuid: ^4.3.3
```

---

## 📱 Step 1: Image Capture

### ImagePickerService

**lib/services/image_picker_service.dart**:
```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Capture image from camera
  Future<File?> captureFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compress to 85% quality
        maxWidth: 1024,   // Max dimension
        maxHeight: 1024,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print('Error capturing from camera: $e');
      return null;
    }
  }

  /// Pick single image from gallery
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      print('Error picking from gallery: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultipleImages(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      return images.map((xfile) => File(xfile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }
}
```

### Usage in UI

**lib/features/wardrobe/screens/add_item_screen.dart**:
```dart
class AddItemScreen extends StatelessWidget {
  final ImagePickerService _imagePicker = ImagePickerService();

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _imagePicker.captureFromCamera();
                if (file != null) {
                  _processImage(context, file);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _imagePicker.pickFromGallery();
                if (file != null) {
                  _processImage(context, file);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Select Multiple'),
              onTap: () async {
                Navigator.pop(context);
                final files = await _imagePicker.pickMultipleFromGallery();
                if (files.isNotEmpty) {
                  _processMultipleImages(context, files);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processImage(BuildContext context, File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageProcessingScreen(imageFile: imageFile),
      ),
    );
  }

  // ... rest of implementation
}
```

---

## 🖼️ Step 2: Image Preprocessing

### ImagePreprocessor

**lib/services/image_preprocessor.dart**:
```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImagePreprocessor {
  /// Optimize image for AI processing
  /// - Resize to 1024x1024 max
  /// - Compress to <500KB
  /// - Convert to JPEG
  Future<File> preprocessImage(File originalFile) async {
    // Read image
    final bytes = await originalFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize if needed (maintain aspect ratio)
    const maxDimension = 1024;
    if (image.width > maxDimension || image.height > maxDimension) {
      image = img.copyResize(
        image,
        width: image.width > image.height ? maxDimension : null,
        height: image.height > image.width ? maxDimension : null,
        interpolation: img.Interpolation.linear,
      );
    }

    // Compress to JPEG
    final compressedBytes = img.encodeJpg(image, quality: 85);

    // Check file size, compress more if needed
    Uint8List finalBytes = Uint8List.fromList(compressedBytes);
    int quality = 85;
    
    while (finalBytes.lengthInBytes > 500000 && quality > 50) {
      quality -= 10;
      finalBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: quality),
      );
    }

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempFile = File('${tempDir.path}/compressed_$timestamp.jpg');
    await tempFile.writeAsBytes(finalBytes);

    return tempFile;
  }

  /// Generate thumbnail
  Future<File> generateThumbnail(File originalFile) async {
    final bytes = await originalFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize to 256x256 thumbnail
    final thumbnail = img.copyResize(
      image,
      width: 256,
      height: 256,
      interpolation: img.Interpolation.linear,
    );

    final thumbnailBytes = img.encodeJpg(thumbnail, quality: 80);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final thumbFile = File('${tempDir.path}/thumb_$timestamp.jpg');
    await thumbFile.writeAsBytes(thumbnailBytes);

    return thumbFile;
  }

  /// Validate image quality
  bool isImageQualityAcceptable(File imageFile) {
    // Check if file exists and is readable
    if (!imageFile.existsSync()) return false;
    
    // Check file size (min 10KB, max 10MB)
    final size = imageFile.lengthSync();
    if (size < 10000 || size > 10000000) return false;

    return true;
  }
}
```

---

## 🎨 Step 3: Background Removal (Optional - Using Google ML Kit)

### BackgroundRemovalService

**lib/services/background_removal_service.dart**:
```dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;

class BackgroundRemovalService {
  /// Use ML Kit Image Segmentation for background removal
  /// Note: This is a simplified version, may need refinement
  Future<File?> removeBackground(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      
      // Use ML Kit's Image Labeling to detect clothing
      final imageLabeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.5),
      );

      final labels = await imageLabeler.processImage(inputImage);
      
      // Check if clothing is detected
      bool hasClothing = labels.any(
        (label) => _isClothingLabel(label.label),
      );

      imageLabeler.close();

      if (!hasClothing) {
        // No clothing detected, return original
        return imageFile;
      }

      // For MVP, we'll skip complex background removal
      // In production, use a dedicated service like Remove.bg API
      // or implement proper segmentation

      return imageFile; // Return original for now
      
    } catch (e) {
      print('Error in background removal: $e');
      return imageFile;
    }
  }

  bool _isClothingLabel(String label) {
    const clothingLabels = [
      'Clothing', 'Shirt', 'T-shirt', 'Pants', 'Jeans',
      'Dress', 'Shoe', 'Footwear', 'Jacket', 'Coat',
      'Skirt', 'Sweater', 'Suit', 'Tie', 'Hat',
    ];
    
    return clothingLabels.any(
      (clothingLabel) => label.toLowerCase().contains(
        clothingLabel.toLowerCase(),
      ),
    );
  }
}

/// Alternative: Use Remove.bg API (Paid but accurate)
class RemoveBgService {
  final String apiKey;

  RemoveBgService({required this.apiKey});

  Future<File?> removeBackground(File imageFile) async {
    // Implementation using remove.bg API
    // https://www.remove.bg/api
    
    // This is a paid service: $0.20 per image
    // Free tier: 50 images/month
    
    // For MVP, recommend skipping or using only for premium users
    throw UnimplementedError('Remove.bg integration - optional for v1.1');
  }
}
```

---

## 🤖 Step 4: AI Analysis with Gemini

Already documented in `AI_PROMPTS.md`, but here's the service integration:

### GeminiClothingAnalysisService

**lib/services/gemini_clothing_service.dart**:
```dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiClothingService {
  final GenerativeModel _model;

  GeminiClothingService({required String apiKey})
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.3,
            topP: 0.95,
            maxOutputTokens: 8192,
          ),
        );

  /// Analyze clothing item from image
  Future<ClothingAnalysisResult> analyzeClothing(File imageFile) async {
    try {
      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Prepare prompt
      const prompt = '''
Analyze this clothing item and respond with JSON in this exact structure:
{
  "category": "one of: tops, bottoms, dresses, outerwear, shoes, accessories, bags, jewelry",
  "subcategory": "specific type",
  "colors": [{"hex": "#RRGGBB", "name": "color name", "percentage": 0-100}],
  "patterns": ["array of patterns"],
  "materials": ["array of materials"],
  "seasons": ["array of seasons: spring, summer, fall, winter"],
  "styles": ["array of styles"],
  "description": "one sentence description",
  "confidence": 0.00-1.00
}

Respond ONLY with valid JSON, no markdown or explanations.
''';

      // Create content
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      // Generate response
      final response = await _model.generateContent(content);
      final responseText = response.text?.trim() ?? '';

      // Clean JSON (remove markdown if present)
      final cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Parse JSON
      final Map<String, dynamic> data = json.decode(cleanJson);

      return ClothingAnalysisResult.fromJson(data);
      
    } catch (e) {
      print('Error analyzing clothing: $e');
      rethrow;
    }
  }

  /// Analyze multiple items in one image
  Future<List<ClothingAnalysisResult>> analyzeMultipleItems(
    File imageFile,
  ) async {
    try {
      final imageBytes = await imageFile.readAsBytes();

      const prompt = '''
Analyze this photograph and detect all clothing items visible.
For each item, provide analysis.

Respond with valid JSON:
{
  "items_count": number,
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
  ]
}
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final cleanJson = response.text
          ?.trim()
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim() ?? '';

      final Map<String, dynamic> data = json.decode(cleanJson);
      final List<dynamic> itemsJson = data['items'] ?? [];

      return itemsJson
          .map((item) => ClothingAnalysisResult.fromJson(item))
          .toList();
          
    } catch (e) {
      print('Error analyzing multiple items: $e');
      rethrow;
    }
  }
}

/// Data model for analysis result
class ClothingAnalysisResult {
  final String category;
  final String subcategory;
  final List<ColorInfo> colors;
  final List<String> patterns;
  final List<String> materials;
  final List<String> seasons;
  final List<String> styles;
  final String description;
  final double confidence;

  ClothingAnalysisResult({
    required this.category,
    required this.subcategory,
    required this.colors,
    required this.patterns,
    required this.materials,
    required this.seasons,
    required this.styles,
    required this.description,
    required this.confidence,
  });

  factory ClothingAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ClothingAnalysisResult(
      category: json['category'] as String,
      subcategory: json['subcategory'] as String,
      colors: (json['colors'] as List)
          .map((c) => ColorInfo.fromJson(c))
          .toList(),
      patterns: List<String>.from(json['patterns'] ?? []),
      materials: List<String>.from(json['materials'] ?? []),
      seasons: List<String>.from(json['seasons'] ?? []),
      styles: List<String>.from(json['styles'] ?? []),
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

class ColorInfo {
  final String hex;
  final String name;
  final int percentage;

  ColorInfo({
    required this.hex,
    required this.name,
    required this.percentage,
  });

  factory ColorInfo.fromJson(Map<String, dynamic> json) {
    return ColorInfo(
      hex: json['hex'] as String,
      name: json['name'] as String,
      percentage: json['percentage'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'hex': hex,
    'name': name,
    'percentage': percentage,
  };
}
```

---

## ☁️ Step 5: Upload to Supabase Storage

### SupabaseStorageService

**lib/services/supabase_storage_service.dart**:
```dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  /// Upload clothing image
  Future<String> uploadClothingImage(File imageFile) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileName = '${_uuid.v4()}.jpg';
      final filePath = '$userId/$fileName';

      // Upload to 'clothing-images' bucket
      await _supabase.storage
          .from('clothing-images')
          .upload(filePath, imageFile);

      // Get public URL
      final publicUrl = _supabase.storage
          .from('clothing-images')
          .getPublicUrl(filePath);

      return publicUrl;
      
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload thumbnail
  Future<String> uploadThumbnail(File thumbnailFile) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileName = 'thumb_${_uuid.v4()}.jpg';
      final filePath = '$userId/thumbnails/$fileName';

      await _supabase.storage
          .from('clothing-images')
          .upload(filePath, thumbnailFile);

      final publicUrl = _supabase.storage
          .from('clothing-images')
          .getPublicUrl(filePath);

      return publicUrl;
      
    } catch (e) {
      print('Error uploading thumbnail: $e');
      rethrow;
    }
  }

  /// Delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract path from URL
      final uri = Uri.parse(imageUrl);
      final path = uri.pathSegments.skip(2).join('/'); // Skip bucket name

      await _supabase.storage
          .from('clothing-images')
          .remove([path]);
          
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
```

---

## 💾 Step 6: Save to Database

### ClothingRepository

**lib/repositories/clothing_repository.dart**:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/clothing_item.dart';

class ClothingRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Create new clothing item
  Future<ClothingItem> createClothingItem(ClothingItem item) async {
    try {
      final response = await _supabase
          .from('clothes')
          .insert(item.toJson())
          .select()
          .single();

      return ClothingItem.fromJson(response);
      
    } catch (e) {
      print('Error creating clothing item: $e');
      rethrow;
    }
  }

  /// Get all user's clothing items
  Future<List<ClothingItem>> getUserClothingItems() async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      final response = await _supabase
          .from('clothes')
          .select()
          .eq('user_id', userId)
          .is_('deleted_at', null)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ClothingItem.fromJson(item))
          .toList();
          
    } catch (e) {
      print('Error fetching clothing items: $e');
      return [];
    }
  }

  /// Update clothing item
  Future<void> updateClothingItem(ClothingItem item) async {
    try {
      await _supabase
          .from('clothes')
          .update(item.toJson())
          .eq('id', item.id);
          
    } catch (e) {
      print('Error updating clothing item: $e');
      rethrow;
    }
  }

  /// Soft delete
  Future<void> deleteClothingItem(String itemId) async {
    try {
      await _supabase
          .from('clothes')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', itemId);
          
    } catch (e) {
      print('Error deleting clothing item: $e');
      rethrow;
    }
  }
}
```

---

## 🔄 Complete Pipeline Orchestration

### WardrobeScanningService (Main Coordinator)

**lib/services/wardrobe_scanning_service.dart**:
```dart
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/clothing_item.dart';

class WardrobeScanningService {
  final ImagePreprocessor _preprocessor = ImagePreprocessor();
  final GeminiClothingService _aiService;
  final SupabaseStorageService _storage = SupabaseStorageService();
  final ClothingRepository _repository = ClothingRepository();

  WardrobeScanningService({required String geminiApiKey})
      : _aiService = GeminiClothingService(apiKey: geminiApiKey);

  /// Complete pipeline: Image → AI → Database
  Future<ClothingItem> processClothingImage(File originalImage) async {
    try {
      // Step 1: Preprocess image
      final processedImage = await _preprocessor.preprocessImage(originalImage);
      
      // Step 2: Generate thumbnail
      final thumbnail = await _preprocessor.generateThumbnail(processedImage);

      // Step 3: AI Analysis
      final analysis = await _aiService.analyzeClothing(processedImage);

      // Step 4: Upload images
      final imageUrl = await _storage.uploadClothingImage(processedImage);
      final thumbnailUrl = await _storage.uploadThumbnail(thumbnail);

      // Step 5: Create database entry
      final clothingItem = ClothingItem(
        id: const Uuid().v4(),
        userId: Supabase.instance.client.auth.currentUser!.id,
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
        category: analysis.category,
        subcategory: analysis.subcategory,
        colors: analysis.colors.map((c) => c.toJson()).toList(),
        patterns: analysis.patterns,
        materials: analysis.materials,
        seasons: analysis.seasons,
        styles: analysis.styles,
        aiConfidence: analysis.confidence,
        aiModelVersion: 'gemini-1.5-flash',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Step 6: Save to database
      final savedItem = await _repository.createClothingItem(clothingItem);

      // Cleanup temp files
      await processedImage.delete();
      await thumbnail.delete();

      return savedItem;
      
    } catch (e) {
      print('Error in wardrobe scanning pipeline: $e');
      rethrow;
    }
  }

  /// Process multiple images (batch)
  Future<List<ClothingItem>> processMultipleImages(
    List<File> images,
  ) async {
    final results = <ClothingItem>[];

    for (final image in images) {
      try {
        final item = await processClothingImage(image);
        results.add(item);
      } catch (e) {
        print('Error processing image: $e');
        // Continue with next image
      }
    }

    return results;
  }
}
```

---

## 📱 UI Implementation

### ImageProcessingScreen

**lib/features/wardrobe/screens/image_processing_screen.dart**:
```dart
import 'package:flutter/material.dart';
import 'dart:io';

class ImageProcessingScreen extends StatefulWidget {
  final File imageFile;

  const ImageProcessingScreen({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  @override
  State<ImageProcessingScreen> createState() => _ImageProcessingScreenState();
}

class _ImageProcessingScreenState extends State<ImageProcessingScreen> {
  String _status = 'Analyzing image...';
  double _progress = 0.0;
  ClothingItem? _result;
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      final scanningService = WardrobeScanningService(
        geminiApiKey: 'YOUR_GEMINI_API_KEY', // From env
      );

      // Update progress
      setState(() {
        _status = 'Preprocessing image...';
        _progress = 0.2;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _status = 'Analyzing with AI...';
        _progress = 0.5;
      });

      // Process
      final result = await scanningService.processClothingImage(widget.imageFile);

      setState(() {
        _status = 'Saving to wardrobe...';
        _progress = 0.9;
      });

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _result = result;
        _isProcessing = false;
        _progress = 1.0;
      });

      // Navigate to edit screen
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ClothingItemEditScreen(item: result),
          ),
        );
      }
      
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Image preview
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: FileImage(widget.imageFile),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Animated scanning overlay
            if (_isProcessing)
              const SizedBox(
                width: 200,
                child: LinearProgressIndicator(),
              ),

            const SizedBox(height: 20),

            // Status text
            Text(
              _status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            // Progress indicators
            if (_isProcessing)
              Column(
                children: [
                  _buildProgressItem('Detecting category', _progress > 0.3),
                  _buildProgressItem('Identifying colors', _progress > 0.5),
                  _buildProgressItem('Finding patterns', _progress > 0.7),
                  _buildProgressItem('Saving item', _progress > 0.9),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            color: completed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: completed ? Colors.white : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ⚡ Performance Optimization

### Caching Strategy

```dart
class ClothingAnalysisCache {
  static final _cache = <String, ClothingAnalysisResult>{};

  static Future<ClothingAnalysisResult> getOrAnalyze(
    File imageFile,
    Future<ClothingAnalysisResult> Function() analyzer,
  ) async {
    // Create hash from image
    final bytes = await imageFile.readAsBytes();
    final hash = bytes.hashCode.toString();

    // Check cache
    if (_cache.containsKey(hash)) {
      return _cache[hash]!;
    }

    // Analyze and cache
    final result = await analyzer();
    _cache[hash] = result;

    return result;
  }

  static void clear() {
    _cache.clear();
  }
}
```

### Cost Optimization

**Gemini API Cost** (Nov 2025):
- Free tier: 1M tokens/month
- Each image analysis: ~500-1000 tokens
- **Free tier = 1,000-2,000 scans/month**

**Strategy**:
- Cache results in database
- Only re-analyze if user manually requests
- Use free tier for first 1K users
- Upgrade to paid when needed ($0.35/1M tokens)

---

## ✅ Testing Checklist

- [ ] Camera capture works on iOS
- [ ] Camera capture works on Android
- [ ] Gallery picker works (single)
- [ ] Gallery picker works (multiple)
- [ ] Image preprocessing reduces file size <500KB
- [ ] Thumbnail generation works
- [ ] Gemini API returns valid JSON
- [ ] AI accuracy >80% for common items
- [ ] Supabase upload successful
- [ ] Database entry created with all fields
- [ ] Error handling for network failures
- [ ] Error handling for AI failures
- [ ] Loading states show correctly
- [ ] Progress indicators update

---

## 🐛 Common Issues & Solutions

### Issue 1: "Permission denied" on camera

**Solution**: Add permissions to platform configs

**iOS** (ios/Runner/Info.plist):
```xml
<key>NSCameraUsageDescription</key>
<string>Take photos of your clothes to add to wardrobe</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Choose photos from your library</string>
```

**Android** (android/app/src/main/AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### Issue 2: Gemini API returns markdown instead of JSON

**Solution**: Add explicit "no markdown" instruction
```dart
const prompt = '''
IMPORTANT: Respond ONLY with valid JSON. 
Do not include ```json or any markdown formatting.
Just the raw JSON object.

{...}
''';
```

### Issue 3: Image too large for API

**Solution**: Already handled in preprocessor, but add validation:
```dart
if (imageFile.lengthSync() > 5000000) {
  throw Exception('Image too large, please compress');
}
```

---

**Estimated Implementation Time**: Week 4-6 (from timeline)
**Critical for MVP**: ✅ Yes
**Dependencies**: Supabase, Gemini API
