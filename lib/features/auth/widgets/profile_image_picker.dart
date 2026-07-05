/// Reusable Profile Image Picker widget for the RUG application.
///
/// Displays a circular avatar with a gold border and emerald glow.
/// Prompts the user with a premium bottom sheet to select from camera or gallery.
/// Handles permissions and square cropping dynamically.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rug/features/splash/widgets/splash_animation_constants.dart';

class ProfileImagePicker extends StatefulWidget {
  const ProfileImagePicker({
    required this.imagePath,
    required this.onImageSelected,
    super.key,
  });

  final String? imagePath;
  final ValueChanged<String?> onImageSelected;

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    // Dismiss the bottom sheet
    Navigator.of(context).pop();

    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        _showPermissionDeniedDialog('Camera');
        return;
      }
    }

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Crop selected image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Photo',
            toolbarColor: const Color(0xFF07150E), // RUG deep green table background
            toolbarWidgetColor: SplashAnimationConstants.gold,
            activeControlsWidgetColor: SplashAnimationConstants.emerald,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            backgroundColor: Colors.black,
          ),
          IOSUiSettings(
            title: 'Crop Profile Photo',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        widget.onImageSelected(croppedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDA3633),
            content: Text('Failed to process image: $e'),
          ),
        );
      }
    }
  }

  void _showPermissionDeniedDialog(String permissionName) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0D1117),
          title: Text(
            '$permissionName Permission Required',
            style: const TextStyle(color: SplashAnimationConstants.gold),
          ),
          content: Text(
            'This application needs $permissionName access to set your profile picture. Please enable it in system settings.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Open Settings', style: TextStyle(color: SplashAnimationConstants.gold)),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0A0F0D), // Premium dark theme matching RUG
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Profile Picture',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: SplashAnimationConstants.gold),
                  title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                const Divider(color: Colors.white10),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: SplashAnimationConstants.gold),
                  title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                if (widget.imagePath != null) ...[
                  const Divider(color: Colors.white10),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Color(0xFFDA3633)),
                    title: const Text('Remove Photo', style: TextStyle(color: Color(0xFFDA3633))),
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onImageSelected(null);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = widget.imagePath != null ? File(widget.imagePath!) : null;

    return Column(
      children: [
        GestureDetector(
          onTap: _showPickerOptions,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: child.key == const ValueKey('avatar_image')
                  ? Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack))
                  : animation, child: child);
            },
            child: Container(
              key: ValueKey(widget.imagePath ?? 'avatar_placeholder'),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0C100E),
                border: Border.all(
                  color: SplashAnimationConstants.gold,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: SplashAnimationConstants.emerald.withValues(alpha: 0.20),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: imageFile != null
                    ? Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                        key: const ValueKey('avatar_image'),
                      )
                    : const Icon(
                        Icons.person,
                        size: 52,
                        color: Colors.white30,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _showPickerOptions,
          style: TextButton.styleFrom(
            foregroundColor: SplashAnimationConstants.gold,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'Add Profile Photo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}
