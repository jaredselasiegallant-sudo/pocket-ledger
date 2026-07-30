/// PocketLedger - Ghana MoMo & Bank SMS/Notification RegEx Parser Engine
///
/// Parses transaction data from:
/// - MTN Mobile Money (MoMo)
/// - Telecel Cash
/// - AT Money
/// - GCB, Ecobank, Fidelity, Stanbic, Absa, CalBank, etc.
///
/// Extracts: Amount (GH₵), vendor/sender, transaction type, reference
/// All parsing is 100% local — zero network calls.
class GhanaTransactionParser {
  GhanaTransactionParser._();

  // ─── Currency Patterns ───
  // Matches: GH₵ 1,234.56 | GHS 1234.56 | GH¢ 100 | GHC 500.00
  static final _amountPattern = RegExp(
    r'(?:GH[₵¢C]?\s*|GHS\s*)(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // Standalone amount without currency prefix (fallback)
  static final _standaloneAmountPattern = RegExp(
    r'(?:amount|total|value|sum)[:\s]*(?:GH[₵¢C]?\s*|GHS\s*)?(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // ─── Transaction Type Patterns ───
  static final _creditPatterns = [
    RegExp(r'received\s+(?:from|via)', caseSensitive: false),
    RegExp(r'credit(?:ed)?\s+(?:your|account)', caseSensitive: false),
    RegExp(r'payment\s+received', caseSensitive: false),
    RegExp(r'you\s+have\s+received', caseSensitive: false),
    RegExp(r'deposit(?:ed)?\s+(?:to|into)', caseSensitive: false),
    RegExp(r'top[\s-]?up\s+(?:received|successful)', caseSensitive: false),
    RegExp(r'cash\s+in', caseSensitive: false),
    RegExp(r'incoming\s+(?:transfer|payment)', caseSensitive: false),
    RegExp(r'funded\s+(?:your|account)', caseSensitive: false),
    RegExp(r'wallet\s+credited', caseSensitive: false),
  ];

  static final _debitPatterns = [
    RegExp(r'sent\s+to', caseSensitive: false),
    RegExp(r'debit(?:ed)?\s+(?:from|your)', caseSensitive: false),
    RegExp(r'paid\s+to', caseSensitive: false),
    RegExp(r'you\s+(?:have\s+)?(?:sent|paid|transferred)', caseSensitive: false),
    RegExp(r'transfer(?:red)?\s+(?:of|to)', caseSensitive: false),
    RegExp(r'cash\s+out', caseSensitive: false),
    RegExp(r'withdrawal', caseSensitive: false),
    RegExp(r'purchase', caseSensitive: false),
    RegExp(r'outgoing\s+(?:transfer|payment)', caseSensitive: false),
    RegExp(r'bill\s+payment', caseSensitive: false),
    RegExp(r'airtime\s+(?:purchase|bought)', caseSensitive: false),
    RegExp(r'utility\s+(?:payment|bill)', caseSensitive: false),
    RegExp(r'wallet\s+debited', caseSensitive: false),
    RegExp(r'charge[d]?\s+(?:is|of)', caseSensitive: false),
  ];

  static final _transferPatterns = [
    RegExp(r'transfer(?:red)?\s+(?:to|from)', caseSensitive: false),
    RegExp(r'bank\s+(?:transfer|to|from)', caseSensitive: false),
    RegExp(r'momo\s+(?:to|from)\s+bank', caseSensitive: false),
    RegExp(r'bank\s+to\s+momo', caseSensitive: false),
    RegExp(r'inter[\s-]?account', caseSensitive: false),
  ];

  // ─── Sender/Recipient Patterns ───
  static final _senderPatterns = [
    RegExp(r'from\s+([A-Za-z\s]+?)(?:\s+on|\s+at|\s+has|\s+with|\s*\()', caseSensitive: false),
    RegExp(r'received\s+from\s+([A-Za-z\s]+)', caseSensitive: false),
    RegExp(r'sender[:\s]+([A-Za-z\s]+)', caseSensitive: false),
    RegExp(r'by\s+([A-Za-z\s]+?)(?:\s+on|\s+at|\s+has)', caseSensitive: false),
    RegExp(r'payment\s+from\s+([A-Za-z\s]+)', caseSensitive: false),
  ];

  static final _recipientPatterns = [
    RegExp(r'sent\s+to\s+([A-Za-z\s]+?)(?:\s+on|\s+at|\s+has|\s+with|\s*\()', caseSensitive: false),
    RegExp(r'paid\s+to\s+([A-Za-z\s]+)', caseSensitive: false),
    RegExp(r'transfer(?:red)?\s+to\s+([A-Za-z\s]+)', caseSensitive: false),
    RegExp(r'recipient[:\s]+([A-Za-z\s]+)', caseSensitive: false),
    RegExp(r'to\s+([A-Za-z\s]+?)(?:\s+on|\s+at|\s+has)', caseSensitive: false),
  ];

  // ─── Reference / ID Patterns ───
  static final _referencePatterns = [
    RegExp(r'(?:ref(?:erence)?|txn|transaction|id|code)[:\s]*([A-Za-z0-9\-]+)', caseSensitive: false),
    RegExp(r'GC[\d]{8,}', caseSensitive: false),
    RegExp(r'MOMO[\d]{6,}', caseSensitive: false),
    RegExp(r'TXN[\d]{6,}', caseSensitive: false),
  ];

  // ─── Balance Patterns ───
  static final _balancePattern = RegExp(
    r'(?:balance|bal|available)[:\s]*(?:GH[₵¢C]?\s*|GHS\s*)?(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // ─── Fee / Charge Patterns ───
  static final _feePattern = RegExp(
    r'(?:fee|charge|cost)[:\s]*(?:GH[₵¢C]?\s*|GHS\s*)?(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // ─── Provider Detection ───
  static final _providerPatterns = {
    'MTN MoMo': [
      RegExp(r'mtn', caseSensitive: false),
      RegExp(r'momo', caseSensitive: false),
      RegExp(r'mobile\s+money', caseSensitive: false),
    ],
    'Telecel Cash': [
      RegExp(r'telecel', caseSensitive: false),
      RegExp(r'vodafone\s+cash', caseSensitive: false),
    ],
    'AT Money': [
      RegExp(r'at\s+money', caseSensitive: false),
      RegExp(r'airteltigo', caseSensitive: false),
      RegExp(r'airtel', caseSensitive: false),
      RegExp(r'tigo', caseSensitive: false),
    ],
    'GCB': [RegExp(r'gcb', caseSensitive: false)],
    'Ecobank': [RegExp(r'ecobank', caseSensitive: false)],
    'Fidelity': [RegExp(r'fidelity', caseSensitive: false)],
    'Stanbic': [RegExp(r'stanbic', caseSensitive: false)],
    'Absa': [RegExp(r'absa', caseSensitive: false)],
    'CalBank': [RegExp(r'cal\s*bank', caseSensitive: false)],
    'Republic Bank': [RegExp(r'republic\s+bank', caseSensitive: false)],
    'SCB': [RegExp(r'standard\s+chartered|scb', caseSensitive: false)],
    'UBA': [RegExp(r'\buba\b', caseSensitive: false)],
    'Zenith': [RegExp(r'zenith', caseSensitive: false)],
    'CBG': [RegExp(r'consolidated\s+bank|cbg', caseSensitive: false)],
    'Prudential': [RegExp(r'prudential', caseSensitive: false)],
    'First Atlantic': [RegExp(r'first\s+atlantic', caseSensitive: false)],
  };

  /// Parse a raw notification or SMS text into structured transaction data
  static ParsedTransaction? parse(String rawText) {
    if (rawText.isEmpty) return null;

    final amount = _extractAmount(rawText);
    if (amount == null) return null; // No parseable amount found

    final type = _detectTransactionType(rawText);
    final sender = _extractSender(rawText, type);
    final recipient = _extractRecipient(rawText, type);
    final reference = _extractReference(rawText);
    final balance = _extractBalance(rawText);
    final fee = _extractFee(rawText);
    final provider = _detectProvider(rawText);

    return ParsedTransaction(
      rawText: rawText,
      amount: amount,
      currency: 'GHS',
      type: type,
      sender: sender,
      recipient: recipient,
      reference: reference,
      balance: balance,
      fee: fee,
      provider: provider,
      timestamp: DateTime.now(),
    );
  }

  /// Parse multiple messages in batch
  static List<ParsedTransaction> parseBatch(List<String> messages) {
    return messages
        .map((msg) => parse(msg))
        .whereType<ParsedTransaction>()
        .toList();
  }

  // ─── Private Helpers ───

  static double? _extractAmount(String text) {
    // Try primary currency-prefixed pattern first
    var match = _amountPattern.firstMatch(text);
    if (match != null) {
      return _parseAmount(match.group(1));
    }

    // Fallback to standalone amount pattern
    match = _standaloneAmountPattern.firstMatch(text);
    if (match != null) {
      return _parseAmount(match.group(1));
    }

    // Last resort: find any number that looks like money
    final genericAmount = RegExp(r'(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?)');
    final candidates = genericAmount.allMatches(text).toList();

    // Take the most likely candidate (largest amount, or first if all equal)
    if (candidates.isNotEmpty) {
      double? best;
      for (final c in candidates) {
        final val = _parseAmount(c.group(1));
        if (val != null && (best == null || val > best)) {
          best = val;
        }
      }
      return best;
    }

    return null;
  }

  static double? _parseAmount(String? raw) {
    if (raw == null) return null;
    final cleaned = raw.replaceAll(',', '');
    return double.tryParse(cleaned);
  }

  static TransactionType _detectTransactionType(String text) {
    // Check credit patterns
    for (final pattern in _creditPatterns) {
      if (pattern.hasMatch(text)) return TransactionType.credit;
    }

    // Check debit patterns
    for (final pattern in _debitPatterns) {
      if (pattern.hasMatch(text)) return TransactionType.debit;
    }

    // Check transfer patterns
    for (final pattern in _transferPatterns) {
      if (pattern.hasMatch(text)) return TransactionType.transfer;
    }

    // Default: if amount is present but type is unclear, mark as unknown
    return TransactionType.unknown;
  }

  static String? _extractSender(String text, TransactionType type) {
    // For credit transactions, extract sender
    if (type == TransactionType.credit || type == TransactionType.unknown) {
      for (final pattern in _senderPatterns) {
        final match = pattern.firstMatch(text);
        if (match != null && match.groupCount >= 1) {
          return _cleanName(match.group(1));
        }
      }
    }

    // For debit/transfer, sender might be "You" or the account holder
    if (type == TransactionType.debit) {
      return 'You';
    }

    return null;
  }

  static String? _extractRecipient(String text, TransactionType type) {
    if (type == TransactionType.debit || type == TransactionType.transfer) {
      for (final pattern in _recipientPatterns) {
        final match = pattern.firstMatch(text);
        if (match != null && match.groupCount >= 1) {
          return _cleanName(match.group(1));
        }
      }
    }

    return null;
  }

  static String? _extractReference(String text) {
    for (final pattern in _referencePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(0);
      }
    }
    return null;
  }

  static double? _extractBalance(String text) {
    final match = _balancePattern.firstMatch(text);
    if (match != null) {
      return _parseAmount(match.group(1));
    }
    return null;
  }

  static double? _extractFee(String text) {
    final match = _feePattern.firstMatch(text);
    if (match != null) {
      return _parseAmount(match.group(1));
    }
    return null;
  }

  static String _detectProvider(String text) {
    for (final entry in _providerPatterns.entries) {
      for (final pattern in entry.value) {
        if (pattern.hasMatch(text)) return entry.key;
      }
    }
    return 'Unknown';
  }

  static String? _cleanName(String? raw) {
    if (raw == null) return null;
    return raw
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s\-]'), '')
        .trim();
  }
}

/// Transaction type enum
enum TransactionType {
  credit,
  debit,
  transfer,
  unknown,
}

/// Parsed transaction result model
class ParsedTransaction {
  final String rawText;
  final double amount;
  final String currency;
  final TransactionType type;
  final String? sender;
  final String? recipient;
  final String? reference;
  final double? balance;
  final double? fee;
  final String provider;
  final DateTime timestamp;

  const ParsedTransaction({
    required this.rawText,
    required this.amount,
    required this.currency,
    required this.type,
    this.sender,
    this.recipient,
    this.reference,
    this.balance,
    this.fee,
    required this.provider,
    required this.timestamp,
  });

  bool get isCredit => type == TransactionType.credit;
  bool get isDebit => type == TransactionType.debit;
  bool get isTransfer => type == TransactionType.transfer;

  String get formattedAmount => 'GH₵ ${amount.toStringAsFixed(2)}';

  String get typeLabel {
    switch (type) {
      case TransactionType.credit:
        return 'Credit';
      case TransactionType.debit:
        return 'Debit';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.unknown:
        return 'Transaction';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'rawText': rawText,
      'amount': amount,
      'currency': currency,
      'type': type.name,
      'sender': sender,
      'recipient': recipient,
      'reference': reference,
      'balance': balance,
      'fee': fee,
      'provider': provider,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ParsedTransaction($typeLabel $formattedAmount via $provider)';
  }
}
