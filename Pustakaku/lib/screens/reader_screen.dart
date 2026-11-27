import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../core/extensions.dart';
import '../widgets/empty_state.dart';

/// Membaca buku domain publik lewat pembaca Internet Archive, di dalam aplikasi.
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.title, required this.url});

  final String title;
  final Uri url;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late final WebViewController _web;
  int _progress = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => setState(() => _progress = p),
        onPageStarted: (_) => setState(() => _failed = false),
        onWebResourceError: (e) {
          if (e.isForMainFrame ?? false) setState(() => _failed = true);
        },
      ))
      ..loadRequest(widget.url);
  }

  Future<void> _openInBrowser() async {
    final ok = await launchUrl(widget.url, mode: LaunchMode.externalApplication);
    if (!ok && mounted) context.showSnack('Browser tidak dapat dibuka', error: true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // Tombol kembali menelusuri halaman pembaca dulu, baru keluar.
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _web.canGoBack()) {
          await _web.goBack();
        } else if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleLarge,
          ),
          actions: [
            IconButton(
              tooltip: 'Muat ulang',
              onPressed: _web.reload,
              icon: const Icon(Icons.refresh_rounded),
            ),
            IconButton(
              tooltip: 'Buka di browser',
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_new_rounded),
            ),
          ],
          bottom: _progress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(value: _progress / 100, minHeight: 3),
                )
              : null,
        ),
        body: _failed
            ? EmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'Buku gagal dimuat',
                message: 'Periksa koneksi internet, lalu coba lagi.',
                action: FilledButton.tonal(
                  onPressed: _web.reload,
                  child: const Text('Coba lagi'),
                ),
              )
            : WebViewWidget(controller: _web),
      ),
    );
  }
}
