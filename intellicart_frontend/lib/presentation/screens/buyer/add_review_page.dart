// lib/screens/add_review_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intellicart/presentation/bloc/buyer/product_bloc.dart';
import 'package:intellicart/presentation/widgets/shared/star_rating_input.dart';

class AddReviewPage extends StatefulWidget {
  final String productId; // Pass the product ID to associate the review

  const AddReviewPage({super.key, required this.productId});

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _reviewController = TextEditingController();
  int _currentRating = 0;
  List<XFile> _selectedImages = [];

  @override
  void dispose() {
    _titleController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 images allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final List<XFile>? pickedImages = await picker.pickMultiImage(
      maxHeight: 600,
      maxWidth: 600,
      imageQuality: 80,
    );

    if (pickedImages != null && pickedImages.isNotEmpty) {
      List<XFile> newImages = List.from(_selectedImages);
      newImages.addAll(pickedImages);
      
      if (newImages.length > 10) {
        newImages = newImages.take(10).toList();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 10 images allowed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
      setState(() {
        _selectedImages = newImages;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitReview() {
    if (_formKey.currentState!.validate() && _currentRating > 0) {
      // Use the provided ProductBloc if available, otherwise try to read from context
      final productBloc = context.read<ProductBloc>();
      productBloc.add(
        AddReviewToProduct(
          productId: widget.productId,
          title: _titleController.text,
          reviewText: _reviewController.text,
          rating: _currentRating,
          images: _selectedImages.map((image) => image.path).toList(), // Convert to image paths
        ),
      );
    } else if (_currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF181411);
    const Color accentColor = Color(0xFFD97706);
    final submittingButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
    );
    final normalButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: accentColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Write a Review',
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ReviewSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you for your review!'),
                backgroundColor: Colors.green,
              ),
            );
            // Pop the page and return the new review
            Navigator.pop(context);
          }
          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What is your rating?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: StarRatingInput(
                    onRatingChanged: (rating) {
                      setState(() {
                        _currentRating = rating;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Review Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title for your review.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reviewController,
                  decoration: const InputDecoration(
                    labelText: 'Your Review',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your review.';
    
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Image Upload Section
                const Text(
                  'Add Images',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      // Add button to pick images
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: ElevatedButton(
                          onPressed: _selectedImages.length < 10 ? _pickImages : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: BorderSide(
                                color: _selectedImages.length < 10 ? Colors.grey : Colors.grey.shade400,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: _selectedImages.length < 10 ? Colors.grey : Colors.grey.shade400,
                              ),
                              const Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Display selected images
                      ..._selectedImages.asMap().entries.map((entry) {
                        int index = entry.key;
                        XFile image = entry.value;
                        return SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.file(
                                  File(image.path),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: -5,
                                right: -5,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_selectedImages.length}/10 images',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ReviewSubmitting) {
                        return ElevatedButton(
                          onPressed: null,
                          style: submittingButtonStyle,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }
                      return ElevatedButton(
                        onPressed: _submitReview,
                        style: normalButtonStyle,
                        child: const Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}