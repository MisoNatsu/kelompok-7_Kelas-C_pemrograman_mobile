import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Cache khusus sampul buku.
///
/// Sampul Open Library sering dialihkan ke archive.org. Bila koneksi terputus
/// di tengah jalan, server bisa membalas `200 OK` dengan isi kosong. Cache
/// bawaan akan menyimpan file kosong itu selama 30 hari sehingga sampul tidak
/// pernah muncul. Di sini unduhan yang bukan gambar ditolak, jadi tidak
/// disimpan dan akan dicoba lagi saat sampul ditampilkan berikutnya.
class CoverCacheManager extends CacheManager with ImageCacheManager {
  CoverCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 500,
          fileService: _ValidatingFileService(),
        ));

  static const key = 'pustakaku_covers';
  static final instance = CoverCacheManager._();
}

class _ValidatingFileService extends HttpFileService {
  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    final response = await super.get(url, headers: headers);
    final builder = await response.content.fold<BytesBuilder>(
      BytesBuilder(copy: false),
      (b, chunk) => b..add(chunk),
    );
    final bytes = builder.takeBytes();
    if (response.statusCode == 200 && !looksLikeImage(bytes)) {
      throw HttpExceptionWithStatus(
        response.statusCode,
        'Sampul kosong atau rusak (${bytes.length} byte)',
        uri: Uri.parse(url),
      );
    }
    return _BufferedResponse(response, bytes);
  }
}

/// Cek tanda tangan berkas: JPEG, PNG, GIF, atau WebP.
bool looksLikeImage(List<int> b) {
  if (b.length < 12) return false;
  final jpeg = b[0] == 0xFF && b[1] == 0xD8;
  final png = b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47;
  final gif = b[0] == 0x47 && b[1] == 0x49 && b[2] == 0x46;
  final webp = b[0] == 0x52 && b[1] == 0x49 && b[2] == 0x46 && b[3] == 0x46 &&
      b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50;
  return jpeg || png || gif || webp;
}

/// Respons yang isinya sudah dibaca ke memori (sampul hanya puluhan KB).
class _BufferedResponse implements FileServiceResponse {
  _BufferedResponse(this._inner, this._bytes);

  final FileServiceResponse _inner;
  final Uint8List _bytes;

  @override
  Stream<List<int>> get content => Stream.value(_bytes);

  @override
  int? get contentLength => _bytes.length;

  @override
  int get statusCode => _inner.statusCode;

  @override
  DateTime get validTill => _inner.validTill;

  @override
  String? get eTag => _inner.eTag;

  @override
  String get fileExtension => _inner.fileExtension;
}
