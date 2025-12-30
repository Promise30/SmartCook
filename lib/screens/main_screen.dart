import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/ingredients_api_service.dart';
import '../models/ingredient.dart';
import '../services/ocr_service.dart';
import '../widgets/error_dialog.dart';
import 'review_ingredients_screen.dart';
import 'history_screen.dart';
import 'bookmarks_screen.dart';
import 'text_ingredients_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final IngredientsAPIService _apiService = IngredientsAPIService();
  final OCRService _ocrService = OCRService();
  
  List<File> _selectedImages = [];
  List<Uint8List> _selectedImageBytes = []; // For web compatibility
  bool _isLoading = false;
  bool _isCapturingMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E8), // Light green at top
              Color(0xFFF0F8F0), // Lighter green at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'SmartCook',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              
              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _isCapturingMode 
                    ? _buildCapturingMode()
                    : _buildSelectionMode(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', true),
                _buildNavItem(Icons.bookmark, 'Bookmarks', false),
                _buildNavItem(Icons.history, 'History', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionMode() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Question
        const Text(
          'What would you like to do?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 40),
        
        // Upload Images button
        _buildActionButton(
          icon: Icons.upload,
          text: 'Upload Images',
          onTap: _pickMultipleImagesFromGallery,
        ),
        
        const SizedBox(height: 20),
        
        // Capture Images button
        _buildActionButton(
          icon: Icons.camera_alt,
          text: 'Capture Images',
          onTap: _startCapturingMode,
        ),
        
        const SizedBox(height: 20),
        
        // Type Ingredients button
        _buildActionButton(
          icon: Icons.edit_note,
          text: 'Type Ingredients',
          onTap: _startTextInputMode,
        ),
        
        const SizedBox(height: 40),
        
        // Help text
        Text(
          'Choose an option above to get started',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildCapturingMode() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              IconButton(
                onPressed: _exitCapturingMode,
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              Expanded(
                child: Text(
                  'Capture Images (${_selectedImages.length})',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
        ),
        
        // Images grid
        Expanded(
          child: _selectedImages.isEmpty
            ? const Center(
                child: Text(
                  'No images captured yet.\nTap the camera button to start!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.only(bottom: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return _buildImageCard(index);
                },
              ),
        ),
        
        // Action buttons
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_a_photo,
                  text: 'Add More',
                  onTap: _showAddMoreOptions,
                ),
              ),
              const SizedBox(width: 10),
              if (_selectedImages.isNotEmpty)
                Expanded(
                  child: _buildActionButton(
                    icon: _isLoading ? Icons.hourglass_empty : Icons.check,
                    text: _isLoading ? 'Analyzing...' : 'Done',
                    onTap: _isLoading ? () {} : _analyzeAllImages,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            kIsWeb
                ? Image.memory(
                    _selectedImageBytes[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Image.file(
                    _selectedImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: ElevatedButton(
                onPressed: () => _retakeImage(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Retake',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50), // Light green
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () => _handleNavigation(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF424242) : Colors.grey,
            size: 24,
          ),
          if (isActive)
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF424242),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  void _handleNavigation(String label) {
    switch (label) {
      case 'Home':
        // Already on home screen
        break;
      case 'Bookmarks':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const BookmarksScreen(),
          ),
        );
        break;
      case 'History':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const HistoryScreen(),
          ),
        );
        break;
    }
  }

  void _startCapturingMode() {
    setState(() {
      _isCapturingMode = true;
      _selectedImages.clear();
      if (kIsWeb) {
        _selectedImageBytes.clear();
      }
    });
  }

  void _exitCapturingMode() {
    setState(() {
      _isCapturingMode = false;
      _selectedImages.clear();
      if (kIsWeb) {
        _selectedImageBytes.clear();
      }
    });
  }

  void _startTextInputMode() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TextIngredientsScreen(),
      ),
    );
  }

  Future<void> _pickMultipleImagesFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      if (kIsWeb) {
        // For web, store both File objects and bytes
        List<Uint8List> imageBytes = [];
        for (var image in images) {
          imageBytes.add(await image.readAsBytes());
        }
        setState(() {
          _selectedImages = images.map((image) => File(image.path)).toList();
          _selectedImageBytes = imageBytes;
          _isCapturingMode = true; // Set capturing mode without clearing images
        });
      } else {
        // For mobile, use File objects
        setState(() {
          _selectedImages = images.map((image) => File(image.path)).toList();
          _isCapturingMode = true; // Set capturing mode without clearing images
        });
      }
    }
  }

  void _showAddMoreOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add More Images'),
        content: const Text('How would you like to add more images?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImageFromCamera();
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImageFromGallery();
            },
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
          if (kIsWeb) {
            // Load bytes for web display
            image.readAsBytes().then((bytes) {
              if (mounted) {
                setState(() {
                  _selectedImageBytes.add(bytes);
                });
              }
            });
          }
        });
      }
    } catch (e) {
      // Show error message for web users
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera not available on web. Please use "Upload Images" instead.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            _selectedImages.add(File(image.path));
            if (kIsWeb) {
              // Load bytes for web display
              image.readAsBytes().then((bytes) {
                if (mounted) {
                  setState(() {
                    _selectedImageBytes.add(bytes);
                  });
                }
              });
            }
          }
          _isCapturingMode = true; // Set capturing mode without clearing images
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (kIsWeb && _selectedImageBytes.length > index) {
        _selectedImageBytes.removeAt(index);
      }
    });
  }

  Future<void> _retakeImage(int index) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImages[index] = File(image.path);
          if (kIsWeb) {
            // Load bytes for web display
            image.readAsBytes().then((bytes) {
              if (mounted && _selectedImageBytes.length > index) {
                setState(() {
                  _selectedImageBytes[index] = bytes;
                });
              }
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera not available on web. Please use "Upload Images" instead.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _analyzeAllImages() async {
    if (_selectedImages.isEmpty) return;

    print('=== Starting image analysis ===');
    print('Number of images: ${_selectedImages.length}');

    setState(() {
      _isLoading = true;
    });

    try {
      // Test connection to Azure API
      print('Testing Azure API connection...');
      final connectionTest = await _apiService.testConnection();
      print('Connection test result: $connectionTest');
      
      if (!connectionTest['success'] && mounted) {
        print('Connection test failed!');
        setState(() {
          _isLoading = false;
        });
        
        final shouldRetry = await ErrorDialog.show(
          context,
          title: connectionTest['cold_start'] == true ? 'AI Service Starting Up' : 'Connection Failed',
          message: connectionTest['message'] ?? 'Unable to connect to the AI service.',
          showRetry: true,
        );
        
        if (shouldRetry) {
          await _analyzeAllImages();
        }
        return;
      }

      // Send images to Azure API for prediction
      print('Sending images to Azure for prediction...');
      final apiResponse = await _apiService.predictMultiple(_selectedImages);
      print('API Response: $apiResponse');
      
      List<Ingredient> ingredients;
      if (apiResponse['success'] == true) {
        print('Success! Converting predictions...');
        // Convert API response to ingredients with OCR fallback
        ingredients = await _convertAPIResponseWithOCRFallback(apiResponse);
        print('Found ${ingredients.length} ingredients');
      } else {
        print('API call failed: ${apiResponse['error']}');
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          final errorType = apiResponse['error'] ?? 'unknown';
          String title = 'Analysis Failed';
          String message = apiResponse['message'] ?? 'Unable to analyze your images.';
          
          if (errorType == 'cold_start') {
            title = 'AI Service Starting Up';
          } else if (errorType == 'timeout') {
            title = 'Request Timed Out';
          } else if (errorType == 'network') {
            title = 'No Internet Connection';
          }
          
          final shouldRetry = await ErrorDialog.show(
            context,
            title: title,
            message: message,
            showRetry: true,
          );
          
          if (shouldRetry) {
            await _analyzeAllImages();
          }
        }
        return;
      }

      // Navigate to review ingredients screen
      if (mounted) {
        print('Navigating to review screen...');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReviewIngredientsScreen(
              ingredients: ingredients,
            ),
          ),
        );
        _exitCapturingMode();
      }
    } catch (e) {
      print('ERROR in _analyzeAllImages: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        final shouldRetry = await ErrorDialog.show(
          context,
          title: 'Unexpected Error',
          message: 'Something went wrong while analyzing your images. Please try again.',
          showRetry: true,
        );
        
        if (shouldRetry) {
          await _analyzeAllImages();
        }
      }
    }
  }

  /// Hybrid detection: ML first, OCR as fallback for low confidence
  /// Handles both raw ingredients (ML) and packaged products (OCR)
  Future<List<Ingredient>> _convertAPIResponseWithOCRFallback(Map<String, dynamic> apiResponse) async {
    if (apiResponse['predictions'] == null) {
      return [];
    }

    List<dynamic> predictions = apiResponse['predictions'] as List;
    List<Ingredient> ingredients = [];
    
    for (var entry in predictions.asMap().entries) {
      final index = entry.key;
      final prediction = entry.value as Map<String, dynamic>;
      
      final imagePath = index < _selectedImages.length ? _selectedImages[index].path : null;
      final confidence = (prediction['confidence'] ?? 0.0).toDouble();
      final ingredientName = prediction['ingredient'] ?? 'Unknown';
      
      // Try ML detection first
      if (confidence >= 0.80) {
        // High confidence - trust ML model
        ingredients.add(Ingredient(
          id: DateTime.now().millisecondsSinceEpoch.toString() + ingredientName + index.toString(),
          name: ingredientName,
          confidence: confidence,
          imagePath: imagePath,
          cookingMethod: null,
          quantityEstimate: null,
          category: _getCategoryFromIngredient(ingredientName),
          isManual: false,
          detectionMethod: 'ml',
        ));
      } else {
        // Low confidence - check if OCR is appropriate before attempting
        print('Low ML confidence ($confidence) for image $index - checking text density');
        
        if (index < _selectedImages.length) {
          try {
            // Pre-check: Analyze text density to determine if OCR is worthwhile
            final shouldUseOCR = await _ocrService.shouldAttemptOCR(_selectedImages[index]);
            
            if (shouldUseOCR) {
              // Image likely has text - attempt OCR
              print('Text detected - attempting OCR processing');
              final ocrText = await _ocrService.extractTextFromImage(_selectedImages[index]);
              final parsedIngredient = _ocrService.parseIngredientFromLabel(ocrText);
              
              if (parsedIngredient != null) {
                final ocrConfidence = _ocrService.getConfidenceLevel(ocrText, parsedIngredient);
                print('OCR detected: $parsedIngredient (confidence: $ocrConfidence)');
                
                ingredients.add(Ingredient(
                  id: DateTime.now().millisecondsSinceEpoch.toString() + parsedIngredient + index.toString(),
                  name: parsedIngredient,
                  confidence: ocrConfidence,
                  imagePath: imagePath,
                  cookingMethod: null,
                  quantityEstimate: null,
                  category: _getCategoryFromIngredient(parsedIngredient),
                  isManual: false,
                  detectionMethod: 'ocr',
                ));
              } else {
                // OCR attempted but failed to parse - apply confidence penalty
                print('OCR failed to parse ingredient - applying 15% confidence penalty');
                final penalizedConfidence = (confidence * 0.85).clamp(0.0, 1.0);
                ingredients.add(Ingredient(
                  id: DateTime.now().millisecondsSinceEpoch.toString() + ingredientName + index.toString(),
                  name: ingredientName,
                  confidence: penalizedConfidence,
                  imagePath: imagePath,
                  cookingMethod: null,
                  quantityEstimate: null,
                  category: _getCategoryFromIngredient(ingredientName),
                  isManual: false,
                  detectionMethod: 'ml',
                ));
              }
            } else {
              // No significant text detected - use ML result as-is
              print('No text detected - using ML result without OCR');
              ingredients.add(Ingredient(
                id: DateTime.now().millisecondsSinceEpoch.toString() + ingredientName + index.toString(),
                name: ingredientName,
                confidence: confidence,
                imagePath: imagePath,
                cookingMethod: null,
                quantityEstimate: null,
                category: _getCategoryFromIngredient(ingredientName),
                isManual: false,
                detectionMethod: 'ml',
              ));
            }
          } catch (e) {
            print('OCR processing error: $e');
            // OCR error - use ML result with penalty
            print('OCR error - applying 15% confidence penalty');
            final penalizedConfidence = (confidence * 0.85).clamp(0.0, 1.0);
            ingredients.add(Ingredient(
              id: DateTime.now().millisecondsSinceEpoch.toString() + ingredientName + index.toString(),
              name: ingredientName,
              confidence: penalizedConfidence,
              imagePath: imagePath,
              cookingMethod: null,
              quantityEstimate: null,
              category: _getCategoryFromIngredient(ingredientName),
              isManual: false,
              detectionMethod: 'ml',
            ));
          }
        }
      }
    }
    
    return ingredients;
  }

  /// Get category for Nigerian ingredients
  String _getCategoryFromIngredient(String ingredient) {
    const Map<String, String> categories = {
      'ewedu': 'Vegetables',
      'okra': 'Vegetables',
      'plantain': 'Vegetables',
      'waterleaf': 'Vegetables',
      'yam': 'Vegetables',
      'beans': 'Proteins',
      'ata_rodo': 'Spices',
      'potato': 'Vegetables',
      'onion': 'Vegetables',
      'egusi': 'Seeds',
      'locust_bean': 'Seasonings',
      'catfish': 'Proteins',
      'tomato': 'Vegetables',
      'rice': 'Grains',
      'ponmo': 'Proteins',
    };
    return categories[ingredient.toLowerCase()] ?? 'Other';
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
