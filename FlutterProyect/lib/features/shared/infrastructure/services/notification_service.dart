import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/i_notification_service.dart';

class NotificationService implements INotificationService {
  @override
  void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      icon: const Icon(Icons.check_circle, color: Colors.green),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
    );
  }

  @override
  void showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      icon: const Icon(Icons.error, color: Colors.red),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
    );
  }

  @override
  void showInfo(String title, String message) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }
}