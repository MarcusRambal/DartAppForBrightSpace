abstract class INotificationService {
  void showSuccess(String title, String message);
  void showError(String title, String message);
  void showInfo(String title, String message);
}