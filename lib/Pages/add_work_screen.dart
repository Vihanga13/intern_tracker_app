/// This file implements a form for interns to add new work entries
/// including details like work hours, type, description, and attachments
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../utils/app_colors.dart';
// Firebase imports commented out for demo
// import 'package:image_picker/image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

/// Main widget for the work entry form screen
class AddWorkEntryPage extends StatefulWidget {
  const AddWorkEntryPage({Key? key}) : super(key: key);

  @override
  State<AddWorkEntryPage> createState() => _AddWorkEntryPageState();
}

/// State class for the work entry form
/// Manages form state, animations, and submission logic
class _AddWorkEntryPageState extends State<AddWorkEntryPage>
    with TickerProviderStateMixin {
  
  // Animation Controllers and Animations for UI effects
  late AnimationController _fadeController;    // Controls fade in/out effects
  late AnimationController _slideController;   // Controls sliding animations
  late AnimationController _scaleController;   // Controls scaling animations
  late Animation<double> _fadeAnimation;       // Fade animation
  late Animation<Offset> _slideAnimation;      // Slide up animation
  late Animation<double> _scaleAnimation;      // Scale animation

  // Form key and text controllers for form validation and input management
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();       // Work title input
  final _hoursController = TextEditingController();       // Hours worked input
  final _descriptionController = TextEditingController(); // Work description input
  
  // Form state variables
  DateTime? _selectedDate;      // Selected work date
  String? _selectedWorkType;    // Selected category of work
  File? _selectedFile;         // Attached file (if any)
  bool _isSubmitting = false;  // Form submission state

  // Available work type options for the dropdown
  final List<String> _workTypes = [
    'Development',
    'Testing',
    'Documentation',
    'Research',
    'Meeting',
    'Training',
    'Bug Fixing',
    'Code Review',
    'Design',
    'Other'
  ];

  // Image picker instance (commented out for demo)
  // final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  /// Initializes animation controllers and animations
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  /// Starts the animations in sequence with delays
  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _titleController.dispose();
    _hoursController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryRoyalBlue,
              AppColors.secondaryCoralOrange,
              Color(0xFF2D2D2D),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildForm(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Material(
            color: AppColors.cardBackground.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.buttonText,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Work Entry',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.buttonText,
                  ),
                ),
                Text(
                  'Track your daily progress',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.buttonText.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main form UI with sections for date, work details,
  /// description, and file attachment
  Widget _buildForm() {
    return ScaleTransition(
      scale: _scaleAnimation,      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('📅 Date & Time'),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('📝 Work Details'),
              const SizedBox(height: 16),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildWorkTypeDropdown(),
              const SizedBox(height: 16),
              _buildHoursField(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('📄 Description'),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 24),
              
              _buildSectionHeader('📎 Attachment (Optional)'),
              const SizedBox(height: 16),
              _buildFileUpload(),
              const SizedBox(height: 32),
              
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
  /// Creates a styled section header with an emoji icon
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
  /// Builds a custom date picker field with calendar icon
  Widget _buildDatePicker() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF2D2D2D),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryRoyalBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryRoyalBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _selectedDate != null
                          ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                          : 'Choose work date',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate != null 
                            ? AppColors.buttonText
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
  /// Builds the work title input field with validation
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      style: TextStyle(color: AppColors.buttonText),
      decoration: InputDecoration(
        labelText: 'Work Title',
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintText: 'Enter your work title',
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryRoyalBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.work_outline,
            color: AppColors.primaryRoyalBlue,
            size: 16,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryRoyalBlue, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a work title';
        }
        if (value.trim().length < 3) {
          return 'Title must be at least 3 characters long';
        }
        return null;
      },
    );
  }
  /// Builds the work type dropdown with custom styling
  Widget _buildWorkTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedWorkType,
      style: TextStyle(color: AppColors.buttonText),
      dropdownColor: const Color(0xFF2D2D2D),
      decoration: InputDecoration(
        labelText: 'Work Type',
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintText: 'Select work category',
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.secondaryCoralOrange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.category_outlined,
            color: AppColors.secondaryCoralOrange,
            size: 16,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryRoyalBlue, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
      ),
      items: _workTypes.map((String type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(
            type,
            style: TextStyle(color: AppColors.buttonText),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedWorkType = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a work type';
        }
        return null;
      },
    );
  }
  /// Builds the hours worked input field with validation
  /// Accepts decimal values between 0.1 and 24
  Widget _buildHoursField() {
    return TextFormField(
      controller: _hoursController,
      style: TextStyle(color: AppColors.buttonText),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Hours Worked',
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintText: 'Enter hours (0-24)',
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
        suffixText: 'hrs',
        suffixStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.secondaryCoralOrange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.access_time,
            color: AppColors.secondaryCoralOrange,
            size: 16,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryRoyalBlue, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter hours worked';
        }
        final hours = double.tryParse(value);
        if (hours == null) {
          return 'Please enter a valid number';
        }
        if (hours <= 0 || hours > 24) {
          return 'Hours must be between 0.1 and 24';
        }
        return null;
      },
    );
  }
  /// Builds a multi-line description field with validation
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      style: TextStyle(color: AppColors.buttonText),
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintText: 'Describe what you worked on...',
        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
        alignLabelWithHint: true,
        prefixIcon: Container(
          margin: const EdgeInsets.only(top: 12, left: 12, right: 12),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primaryRoyalBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.description_outlined,
            color: AppColors.primaryRoyalBlue,
            size: 16,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryRoyalBlue, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please provide a description';
        }
        if (value.trim().length < 10) {
          return 'Description must be at least 10 characters long';
        }
        return null;
      },
    );
  }
  /// Builds the file upload section with preview and clear functionality
  Widget _buildFileUpload() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickFile,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedFile != null ? AppColors.primaryRoyalBlue : AppColors.textSecondary.withOpacity(0.3),
              width: _selectedFile != null ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _selectedFile != null 
                ? AppColors.primaryRoyalBlue.withOpacity(0.1)
                : const Color(0xFF2D2D2D),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryRoyalBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _selectedFile != null ? Icons.check_circle : Icons.attach_file,
                  color: AppColors.primaryRoyalBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFile != null ? 'File Selected' : 'Attach File',
                      style: TextStyle(
                        fontSize: 12,
                        color: _selectedFile != null 
                            ? AppColors.primaryRoyalBlue 
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _selectedFile != null
                          ? _selectedFile!.path.split('/').last
                          : 'Optional: Add images or documents',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedFile != null 
                            ? AppColors.buttonText
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedFile != null)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  /// Builds an animated submit button that shows loading state
  Widget _buildSubmitButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRoyalBlue,
          foregroundColor: AppColors.buttonText,
          elevation: _isSubmitting ? 0 : 8,
          shadowColor: AppColors.primaryRoyalBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.buttonText.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Submitting...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.buttonText,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20, color: AppColors.buttonText),
                  const SizedBox(width: 8),
                  Text(
                    'Submit Work Entry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.buttonText,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
  /// Shows date picker dialog and handles date selection
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryRoyalBlue,
              onPrimary: AppColors.buttonText,
              surface: const Color(0xFF2D2D2D),
              onSurface: AppColors.buttonText,
              background: const Color(0xFF1E1E1E),
              onBackground: AppColors.buttonText,
            ),
            dialogBackgroundColor: const Color(0xFF2D2D2D),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      HapticFeedback.lightImpact();
    }
  }

  /// Handles file selection (currently simulated)
  Future<void> _pickFile() async {
    // For demonstration purposes, we'll simulate file picking
    // In a real app, you would use ImagePicker or file_picker
    
    // Uncomment this for real implementation:
    /*
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
      });
      HapticFeedback.lightImpact();
    }
    */
      // Simulation for demo
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'File picker would open here',
          style: TextStyle(color: AppColors.buttonText),
        ),
        backgroundColor: AppColors.primaryRoyalBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Validates and submits the form data
  /// Shows loading state and success/error messages
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a date',
            style: TextStyle(color: AppColors.buttonText),
          ),
          backgroundColor: AppColors.secondaryCoralOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Prepare data for submission
      final workEntry = {
        'date': _selectedDate!.toIso8601String(),
        'title': _titleController.text.trim(),
        'workType': _selectedWorkType,
        'hours': double.parse(_hoursController.text),
        'description': _descriptionController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
        'userId': 'current_user_id', // Replace with actual user ID
      };

      // Add file URL if file is selected
      if (_selectedFile != null) {
        // Upload file to storage and get URL
        // workEntry['fileUrl'] = uploadedFileUrl;
        workEntry['hasAttachment'] = true;
      }

      // Submit to Firebase
      // await FirebaseFirestore.instance
      //     .collection('workEntries')
      //     .add(workEntry);      // Show success message
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.buttonText),
                const SizedBox(width: 8),
                Text(
                  'Work entry submitted successfully!',
                  style: TextStyle(color: AppColors.buttonText),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF66BB6A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear the form
        _clearForm();
      }
    } catch (e) {      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error submitting work entry: ${e.toString()}',
              style: TextStyle(color: AppColors.buttonText),
            ),
            backgroundColor: AppColors.secondaryCoralOrange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// Resets the form to its initial state
  /// Clears all inputs and selections
  void _clearForm() {
    _titleController.clear();
    _hoursController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDate = null;
      _selectedWorkType = null;
      _selectedFile = null;
    });
    _formKey.currentState?.reset();
  }
}