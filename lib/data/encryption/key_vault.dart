import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Length in bytes of the SQLCipher database key (256 bits).
const dbKeyLength = 32;

/// Characters used in recovery codes (Crockford base32: no I, L, O or U, so
/// they are hard to misread).
const _recoveryAlphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

/// Number of characters in a recovery code (20 chars x 5 bits = 100 bits).
const _recoveryCodeLength = 20;

/// Thrown when a password or recovery code doesn't unlock the vault.
class WrongSecretException implements Exception {
  /// Creates the exception.
  const WrongSecretException();

  @override
  String toString() => 'WrongSecretException: the password or code is wrong';
}

/// Cost settings for the Argon2id key-derivation function.
class KdfParams {
  /// Creates KDF settings.
  const KdfParams({
    required this.memoryKib,
    required this.iterations,
    required this.parallelism,
  });

  /// Defaults for real use (OWASP's Argon2id baseline: 19 MiB, 2 passes).
  static const standard = KdfParams(
    memoryKib: 19456,
    iterations: 2,
    parallelism: 1,
  );

  /// Memory cost in KiB.
  final int memoryKib;

  /// Number of passes.
  final int iterations;

  /// Degree of parallelism.
  final int parallelism;

  /// Serializes these settings for the vault file.
  Map<String, Object> toJson() => {
    'alg': 'argon2id',
    'memoryKib': memoryKib,
    'iterations': iterations,
    'parallelism': parallelism,
  };

  /// Reads settings written by [toJson].
  factory KdfParams.fromJson(Map<String, dynamic> json) {
    if (json['alg'] != 'argon2id') {
      throw FormatException('Unsupported KDF: ${json['alg']}');
    }
    return KdfParams(
      memoryKib: json['memoryKib'] as int,
      iterations: json['iterations'] as int,
      parallelism: json['parallelism'] as int,
    );
  }
}

/// The database key encrypted (AES-256-GCM) under a key derived from a secret.
class WrappedKey {
  /// Creates a wrapped key from its parts.
  const WrappedKey({
    required this.salt,
    required this.nonce,
    required this.cipherText,
    required this.mac,
  });

  /// Random Argon2id salt.
  final List<int> salt;

  /// AES-GCM nonce.
  final List<int> nonce;

  /// The encrypted database key.
  final List<int> cipherText;

  /// AES-GCM authentication tag.
  final List<int> mac;

  /// Serializes the wrapped key (base64 fields).
  Map<String, String> toJson() => {
    'salt': base64Encode(salt),
    'nonce': base64Encode(nonce),
    'cipherText': base64Encode(cipherText),
    'mac': base64Encode(mac),
  };

  /// Reads a wrapped key written by [toJson].
  factory WrappedKey.fromJson(Map<String, dynamic> json) => WrappedKey(
    salt: base64Decode(json['salt'] as String),
    nonce: base64Decode(json['nonce'] as String),
    cipherText: base64Decode(json['cipherText'] as String),
    mac: base64Decode(json['mac'] as String),
  );
}

/// Everything needed to unlock the database key, stored next to the database.
///
/// It holds no secrets in the clear: the random database key is wrapped once
/// by the password and once by the recovery code, so either one unlocks it,
/// and changing the password doesn't re-encrypt the database.
class KeyVault {
  /// Creates a vault from its parts.
  const KeyVault({
    required this.kdf,
    required this.passwordWrap,
    required this.recoveryWrap,
  });

  /// Vault file format version (internal only).
  static const formatVersion = 1;

  /// KDF settings used for both wraps.
  final KdfParams kdf;

  /// The database key wrapped by the password.
  final WrappedKey passwordWrap;

  /// The database key wrapped by the recovery code.
  final WrappedKey recoveryWrap;

  /// Serializes the vault.
  Map<String, Object> toJson() => {
    'version': formatVersion,
    'kdf': kdf.toJson(),
    'password': passwordWrap.toJson(),
    'recovery': recoveryWrap.toJson(),
  };

  /// Reads a vault written by [toJson].
  factory KeyVault.fromJson(Map<String, dynamic> json) {
    if (json['version'] != formatVersion) {
      throw FormatException('Unsupported vault version: ${json['version']}');
    }
    return KeyVault(
      kdf: KdfParams.fromJson(json['kdf'] as Map<String, dynamic>),
      passwordWrap: WrappedKey.fromJson(
        json['password'] as Map<String, dynamic>,
      ),
      recoveryWrap: WrappedKey.fromJson(
        json['recovery'] as Map<String, dynamic>,
      ),
    );
  }

  /// Loads a vault from [file], or returns null if it doesn't exist.
  static Future<KeyVault?> load(File file) async {
    if (!await file.exists()) return null;
    final json = jsonDecode(await file.readAsString());
    return KeyVault.fromJson(json as Map<String, dynamic>);
  }

  /// Writes this vault to [file] (via a temp file, so a crash can't leave
  /// half a vault behind).
  Future<void> save(File file) async {
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(jsonEncode(toJson()), flush: true);
    await temp.rename(file.path);
  }
}

/// Result of setting up a new vault.
class VaultSetup {
  /// Creates the result.
  const VaultSetup({
    required this.vault,
    required this.dbKey,
    required this.recoveryCode,
  });

  /// The vault to save next to the database.
  final KeyVault vault;

  /// The raw database key, to open SQLCipher with. Never store it.
  final Uint8List dbKey;

  /// The recovery code to show the user once, formatted for reading.
  final String recoveryCode;
}

/// Creates and unlocks [KeyVault]s.
class KeyVaultService {
  /// Creates the service. [random] is injectable for tests only.
  KeyVaultService({Random? random}) : _random = random ?? Random.secure();

  final Random _random;
  final _cipher = AesGcm.with256bits();

  /// Creates a new random database key, wrapped by [password] and by a fresh
  /// recovery code.
  Future<VaultSetup> create({
    required String password,
    KdfParams kdf = KdfParams.standard,
  }) async {
    final dbKey = _randomBytes(dbKeyLength);
    final recoveryCode = generateRecoveryCode();
    final vault = KeyVault(
      kdf: kdf,
      passwordWrap: await _wrap(dbKey, _passwordBytes(password), kdf),
      recoveryWrap: await _wrap(dbKey, _recoveryBytes(recoveryCode), kdf),
    );
    return VaultSetup(vault: vault, dbKey: dbKey, recoveryCode: recoveryCode);
  }

  /// Returns the database key, or throws [WrongSecretException].
  Future<Uint8List> unlockWithPassword(KeyVault vault, String password) =>
      _unwrap(vault.passwordWrap, _passwordBytes(password), vault.kdf);

  /// Returns the database key, or throws [WrongSecretException].
  ///
  /// Case, spaces and dashes in [code] are ignored.
  Future<Uint8List> unlockWithRecoveryCode(KeyVault vault, String code) =>
      _unwrap(vault.recoveryWrap, _recoveryBytes(code), vault.kdf);

  /// Returns a vault where [newPassword] unlocks [dbKey]; the recovery code
  /// keeps working.
  Future<KeyVault> changePassword(
    KeyVault vault, {
    required Uint8List dbKey,
    required String newPassword,
  }) async => KeyVault(
    kdf: vault.kdf,
    passwordWrap: await _wrap(dbKey, _passwordBytes(newPassword), vault.kdf),
    recoveryWrap: vault.recoveryWrap,
  );

  /// Generates a recovery code like `7K2M-9QXA-3BHD-T0WE-56RZ`.
  String generateRecoveryCode() {
    final chars = List.generate(
      _recoveryCodeLength,
      (_) => _recoveryAlphabet[_random.nextInt(_recoveryAlphabet.length)],
    );
    final groups = <String>[];
    for (var i = 0; i < chars.length; i += 4) {
      groups.add(chars.sublist(i, i + 4).join());
    }
    return groups.join('-');
  }

  Future<WrappedKey> _wrap(
    Uint8List dbKey,
    List<int> secret,
    KdfParams kdf,
  ) async {
    final salt = _randomBytes(16);
    final kek = await _deriveKek(secret, salt, kdf);
    final box = await _cipher.encrypt(
      dbKey,
      secretKey: kek,
      nonce: _cipher.newNonce(),
    );
    return WrappedKey(
      salt: salt,
      nonce: box.nonce,
      cipherText: box.cipherText,
      mac: box.mac.bytes,
    );
  }

  Future<Uint8List> _unwrap(
    WrappedKey wrapped,
    List<int> secret,
    KdfParams kdf,
  ) async {
    final kek = await _deriveKek(secret, wrapped.salt, kdf);
    try {
      final clear = await _cipher.decrypt(
        SecretBox(
          wrapped.cipherText,
          nonce: wrapped.nonce,
          mac: Mac(wrapped.mac),
        ),
        secretKey: kek,
      );
      return Uint8List.fromList(clear);
    } on SecretBoxAuthenticationError {
      throw const WrongSecretException();
    }
  }

  Future<SecretKey> _deriveKek(
    List<int> secret,
    List<int> salt,
    KdfParams kdf,
  ) {
    final argon = Argon2id(
      memory: kdf.memoryKib,
      iterations: kdf.iterations,
      parallelism: kdf.parallelism,
      hashLength: 32,
    );
    return argon.deriveKey(secretKey: SecretKey(secret), nonce: salt);
  }

  Uint8List _randomBytes(int length) =>
      Uint8List.fromList(List.generate(length, (_) => _random.nextInt(256)));

  List<int> _passwordBytes(String password) => utf8.encode(password);

  List<int> _recoveryBytes(String code) =>
      utf8.encode(code.toUpperCase().replaceAll(RegExp(r'[\s-]'), ''));
}
