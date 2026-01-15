// lib/utils/url_launcher_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk Clipboard
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  // Fungsi untuk membuka URL dengan berbagai skema
  static Future<void> launchUrlWithFallback({
    required BuildContext context,
    required String url,
    String? fallbackUrl,
    String? errorMessage,
  }) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else if (fallbackUrl != null) {
        final fallbackUri = Uri.parse(fallbackUrl);
        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(
            fallbackUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          _showErrorDialog(context, errorMessage ?? 'Tidak dapat membuka URL');
        }
      } else {
        _showErrorDialog(context, errorMessage ?? 'Tidak dapat membuka URL');
      }
    } catch (e) {
      print('Error launching URL: $e');
      _showErrorDialog(context, 'Terjadi kesalahan: $e');
    }
  }

  // Fungsi khusus untuk membuka Google Maps
  static Future<void> openGoogleMaps({
    required BuildContext context,
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude${label != null ? '&query=$label' : ''}';
    final String geoUrl =
        'geo:$latitude,$longitude?q=$latitude,$longitude${label != null ? '($label)' : ''}';

    try {
      // Coba Google Maps app (Android)
      final googleMapsAppUri = Uri.parse(
          'comgooglemaps://?q=$latitude,$longitude&center=$latitude,$longitude&zoom=15');

      if (await canLaunchUrl(googleMapsAppUri)) {
        await launchUrl(
          googleMapsAppUri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      // Coba skema geo (Android)
      final geoUri = Uri.parse(geoUrl);
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(
          geoUri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      // Fallback ke Google Maps web
      final webUri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      // Jika semua gagal, tampilkan dialog dengan koordinat
      _showLocationCoordinatesDialog(
        context,
        latitude,
        longitude,
        label: label,
      );
    } catch (e) {
      print('Error opening Google Maps: $e');
      _showLocationCoordinatesDialog(
        context,
        latitude,
        longitude,
        label: label,
      );
    }
  }

  // Fungsi untuk membuka Apple Maps (iOS)
  static Future<void> openAppleMaps({
    required BuildContext context,
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final String appleMapsUrl =
        'https://maps.apple.com/?q=$latitude,$longitude&ll=$latitude,$longitude';

    try {
      final uri = Uri.parse(appleMapsUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback ke Google Maps web
        await openGoogleMaps(
          context: context,
          latitude: latitude,
          longitude: longitude,
          label: label,
        );
      }
    } catch (e) {
      print('Error opening Apple Maps: $e');
      _showLocationCoordinatesDialog(
        context,
        latitude,
        longitude,
        label: label,
      );
    }
  }

  // Fungsi untuk membuka peta berdasarkan platform
  static Future<void> openMaps({
    required BuildContext context,
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    // Deteksi platform
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      await openAppleMaps(
        context: context,
        latitude: latitude,
        longitude: longitude,
        label: label,
      );
    } else {
      await openGoogleMaps(
        context: context,
        latitude: latitude,
        longitude: longitude,
        label: label,
      );
    }
  }

  // Fungsi untuk membuka email
  static Future<void> openEmail({
    required BuildContext context,
    required String email,
    String? subject,
    String? body,
  }) async {
    final String emailUrl =
        'mailto:$email${subject != null ? '?subject=${Uri.encodeComponent(subject)}' : ''}${body != null ? '${subject != null ? '&' : '?'}body=${Uri.encodeComponent(body)}' : ''}';

    await launchUrlWithFallback(
      context: context,
      url: emailUrl,
      errorMessage: 'Tidak dapat membuka aplikasi email',
    );
  }

  // Fungsi untuk membuka telepon
  static Future<void> openPhone({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    final String phoneUrl = 'tel:$phoneNumber';

    await launchUrlWithFallback(
      context: context,
      url: phoneUrl,
      errorMessage: 'Tidak dapat membuka aplikasi telepon',
    );
  }

  // Fungsi untuk membuka WhatsApp
  static Future<void> openWhatsApp({
    required BuildContext context,
    required String phoneNumber,
    String? message,
  }) async {
    final String messageText =
        message != null ? Uri.encodeComponent(message) : '';
    final String whatsappUrl =
        'https://wa.me/$phoneNumber${message != null ? '?text=$messageText' : ''}';
    final String whatsappAppUrl =
        'whatsapp://send?phone=$phoneNumber${message != null ? '&text=$messageText' : ''}';

    await launchUrlWithFallback(
      context: context,
      url: whatsappAppUrl,
      fallbackUrl: whatsappUrl,
      errorMessage: 'Tidak dapat membuka WhatsApp',
    );
  }

  // Fungsi untuk membuka browser web
  static Future<void> openBrowser({
    required BuildContext context,
    required String url,
  }) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    await launchUrlWithFallback(
      context: context,
      url: url,
      errorMessage: 'Tidak dapat membuka browser',
    );
  }

  // Dialog untuk menampilkan koordinat lokasi
  static void _showLocationCoordinatesDialog(
    BuildContext context,
    double latitude,
    double longitude, {
    String? label,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final coordinates = '$latitude, $longitude';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Koordinat Lokasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
            ],
            const Text('Salin koordinat di bawah ini:'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: coordinates));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Koordinat berhasil disalin'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        coordinates,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.content_copy,
                      color: Colors.blue,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap untuk menyalin',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Coba buka dengan Google Maps web sebagai fallback
              final webUrl =
                  'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
              final uri = Uri.parse(webUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            child: const Text('Buka Web Maps'),
          ),
        ],
      ),
    );
  }

  // Dialog untuk menampilkan error
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gagal Membuka'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membuka URL secara langsung (tanpa fallback)
  static Future<void> launchUrlDirectly(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Error launching URL directly: $e');
    }
  }

  // Fungsi untuk mengecek apakah URL bisa dibuka
  static Future<bool> canLaunch(String url) async {
    try {
      final uri = Uri.parse(url);
      return await canLaunchUrl(uri);
    } catch (e) {
      print('Error checking if URL can launch: $e');
      return false;
    }
  }
}
