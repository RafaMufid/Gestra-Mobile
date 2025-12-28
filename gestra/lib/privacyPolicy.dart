import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final titleColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Kebijakan Privasi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terakhir Diperbarui: 27 Desember 2025\nTanggal Efektif: 24 Desember 2025',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Kebijakan Privasi ini menjelaskan kebijakan dari B15A, Jl. Telekomunikasi No.1, Sukapura, Kec. Dayeuhkolot, Kabupaten Bandung, Jawa Barat 40257, email: gestra@translate.com, telepon: 6212345678910 mengenai pengumpulan, penggunaan, dan pengungkapan informasi Anda yang kami kumpulkan saat Anda menggunakan situs web kami (http://www.gestra.com) ("Layanan").\n\nDengan mengakses atau menggunakan Layanan, Anda menyetujui pengumpulan, penggunaan, dan pengungkapan informasi Anda sesuai dengan Kebijakan Privasi ini.',
              style: TextStyle(color: textColor, height: 1.5),
            ),
            const Divider(height: 40),

            _buildSectionTitle('Informasi yang Kami Kumpulkan', titleColor),
            Text(
              'Kami akan mengumpulkan dan memproses informasi pribadi berikut tentang Anda:',
              style: TextStyle(color: textColor, height: 1.5),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Nama', textColor),
            _buildBulletPoint('Email', textColor),
            _buildBulletPoint('Kata Sandi (Password)', textColor),
            const SizedBox(height: 20),

            _buildSectionTitle(
              'Bagaimana Kami Menggunakan Informasi Anda',
              titleColor,
            ),
            Text(
              'Kami akan menggunakan informasi yang kami kumpulkan tentang Anda untuk tujuan berikut:',
              style: TextStyle(color: textColor, height: 1.5),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Membuat akun pengguna', textColor),
            _buildBulletPoint('Info administrasi', textColor),
            _buildBulletPoint('Mengelola akun pengguna', textColor),
            const SizedBox(height: 10),
            Text(
              'Jika kami ingin menggunakan informasi Anda untuk tujuan lain apa pun, kami akan meminta persetujuan Anda terlebih dahulu.',
              style: TextStyle(color: textColor, height: 1.5),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Penyimpanan Informasi Anda', titleColor),
            Text(
              'Kami akan menyimpan informasi pribadi Anda bersama kami selama 90 hari hingga 2 tahun setelah pengguna menutup akun mereka atau selama kami membutuhkannya untuk memenuhi tujuan pengumpulannya. Sisa informasi anonim dapat disimpan tanpa batas waktu.',
              style: TextStyle(color: textColor, height: 1.5),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Hak-Hak Anda', titleColor),
            Text(
              'Tergantung pada hukum yang berlaku, Anda memiliki hak untuk mengakses, memperbaiki, atau menghapus data pribadi Anda. Anda juga berhak menarik persetujuan pemrosesan data. Untuk menggunakan hak-hak ini, Anda dapat menulis kepada kami di gestra@translate.com.',
              style: TextStyle(color: textColor, height: 1.5),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Cookies Dll.', titleColor),
            Text(
              'Untuk mempelajari lebih lanjut tentang bagaimana kami menggunakan teknologi pelacakan ini, silakan merujuk ke Kebijakan Cookie kami.',
              style: TextStyle(color: textColor, height: 1.5),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Keamanan', titleColor),
            Text(
              'Keamanan informasi Anda penting bagi kami. Namun, ingatlah bahwa tidak ada metode transmisi melalui internet yang 100% aman. Kami berusaha sebaik mungkin untuk melindungi data Anda namun tidak dapat menjamin keamanan mutlak.',
              style: TextStyle(color: textColor, height: 1.5),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Petugas Pengaduan', titleColor),
            Text(
              'Jika Anda memiliki pertanyaan atau kekhawatiran tentang pemrosesan informasi Anda, silakan hubungi kami di:\n\nB15A, Jl. Telekomunikasi No.1, Sukapura, Kec. Dayeuhkolot, Kabupaten Bandung\nEmail: gestra@translate.com',
              style: TextStyle(color: textColor, height: 1.5),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

Widget _buildSectionTitle(String title, Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Text(
      title,
      style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _buildBulletPoint(String text, Color color) {
  return Padding(
    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(text, style: TextStyle(color: color)),
        ),
      ],
    ),
  );
}
