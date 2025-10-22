// lib/presentation/widgets/star_rating_input.dart
import 'package:flutter/material.dart';

class StarRatingInput extends StatefulWidget {
  final int initialRating;
  final Function(int) onRatingChanged;
  final Color color;
  final double size;

  const StarRatingInput({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.color = const Color(0xFFFF9500), // starColor
    this.size = 32.0,
  });

  @override
  State<StarRatingInput> createState() => _StarRatingInputState();
}

class _StarRatingInputState extends State<StarRatingInput> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  Widget _buildStar(int index) {
    IconData icon = Icons.star_border;
    if (index < _currentRating) {
      icon = Icons.star;
    }
    return IconButton(
      onPressed: () {
        setState(() {
          _currentRating = index + 1;
        });
        widget.onRatingChanged(_currentRating);
      },
      icon: Icon(icon, color: widget.color, size: widget.size),
      padding: EdgeInsets.zero,
      tooltip: '${index + 1} star${index == 0 ? '' : 's'}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) => _buildStar(index)),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> e51c7f0dc99661f83454b223f01cf3df2db30631
