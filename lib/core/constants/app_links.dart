abstract final class AppLinks {
  static final privacyTr = Uri.parse(
    'https://berilblks.github.io/Oynika/privacy.html',
  );
  static final privacyEn = Uri.parse(
    'https://berilblks.github.io/Oynika/privacy-en.html',
  );
  static const supportEmail = 'support.berilapps@gmail.com';
  static const supportSubject = 'Oynika - Destek Talebi';
  static final support = Uri(
    scheme: 'mailto',
    path: supportEmail,
    // Non-HTTP handlers expect percent-encoded spaces, rather than '+'.
    query: 'subject=${Uri.encodeComponent(supportSubject)}',
  );
}
