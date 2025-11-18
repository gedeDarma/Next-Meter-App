import 'dart:math';

class TransactionService {
  // Fixed service fee for every transaction (Rp)
  static const int serviceFee = 3000;
  // Calculate water pulse: Rp 10,000 = 30 pulses
  static int calculateElectricPulse(double amountInRupiah) {
    return ((amountInRupiah / 10000) * 30).toInt();
  }

  // Generate unique transaction ID
  static String generateTransactionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(10000);
    return 'TRX${timestamp.toString().substring(0, 10)}$randomNum';
  }

  // Generate water token (simulated)
  static String generateToken() {
    final random = Random();
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String token = '';
    for (int i = 0; i < 20; i++) {
      token += chars[random.nextInt(chars.length)];
    }
    // Format as: XXXX-XXXX-XXXX-XXXX-XXXX
    return '${token.substring(0, 4)}-${token.substring(4, 8)}-${token.substring(8, 12)}-${token.substring(12, 16)}-${token.substring(16, 20)}';
  }

  // Format currency in Rupiah
  static String formatRupiah(double amount) {
    final formatter = amount.toStringAsFixed(0);
    final parts = <String>[];
    for (int i = formatter.length - 1; i >= 0; i -= 3) {
      final start = i - 2 < 0 ? 0 : i - 2;
      parts.insert(0, formatter.substring(start, i + 1));
      if (start == 0) break;
    }
    return 'Rp ${parts.join('.')}';
  }

  // Same as formatRupiah but without the 'Rp ' prefix.
  static String formatRupiahValue(double amount) {
    final full = formatRupiah(amount);
    return full.replaceFirst(RegExp(r'^Rp\s*'), '');
  }

  // Format date time
  static String formatDateTime(DateTime dateTime) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}
