import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ProofApp());
}

// ─── Palette ────────────────────────────────────────────────────────────────

const _bgColor = Color(0xFFF7F5F0);
const _surfaceColor = Color(0xFFFFFFFF);
const _primaryText = Color(0xFF1A1A1A);
const _mutedText = Color(0xFF888580);
const _thinBorder = Color(0x26000000);
const _summaryBg = Color(0xFFF5F3EE);
const _summaryBorder = Color(0xFFCCCAC4);

const _highColor = Color(0xFFC93B3B);
const _medColor = Color(0xFFB87000);
const _lowColor = Color(0xFF2D7A4A);

// ─── Helpers ─────────────────────────────────────────────────────────────────

Color _riskColor(String risk) {
  switch (risk.toUpperCase()) {
    case 'HIGH':
      return _highColor;
    case 'MEDIUM':
      return _medColor;
    default:
      return _lowColor;
  }
}

// ─── App ─────────────────────────────────────────────────────────────────────

class ProofApp extends StatelessWidget {
  const ProofApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.light(useMaterial3: true);
    return MaterialApp(
      title: 'Proof',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: _bgColor,
        colorScheme: base.colorScheme.copyWith(
          surface: _surfaceColor,
          primary: _primaryText,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
          displayLarge: GoogleFonts.merriweather(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _primaryText,
          ),
          displayMedium: GoogleFonts.merriweather(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _primaryText,
          ),
          displaySmall: GoogleFonts.merriweather(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _primaryText,
          ),
        ),
        dividerColor: _thinBorder,
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _thinBorder, width: 0.5),
          ),
          color: _surfaceColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _thinBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _thinBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryText, width: 1.5),
          ),
          hintStyle: GoogleFonts.dmSans(fontSize: 14, color: _mutedText),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          filled: true,
          fillColor: _surfaceColor,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _primaryText,
            foregroundColor: _surfaceColor,
            textStyle: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            textStyle: GoogleFonts.dmSans(fontSize: 14),
          ),
        ),
      ),
      home: const _ProofHome(),
    );
  }
}

// ─── State Enum ──────────────────────────────────────────────────────────────

enum AppView { input, loading, results }

// ─── Home Widget ─────────────────────────────────────────────────────────────

class _ProofHome extends StatefulWidget {
  const _ProofHome();

  @override
  State<_ProofHome> createState() => _ProofHomeState();
}

class _ProofHomeState extends State<_ProofHome>
    with TickerProviderStateMixin {
  AppView _view = AppView.input;
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _result;

  // Loading animation controllers
  late final List<AnimationController> _dotControllers;
  late final List<Animation<double>> _dotOpacity;
  late final List<Animation<double>> _dotScale;

  @override
  void initState() {
    super.initState();
    _dotControllers = List.generate(3, (i) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) controller.repeat(reverse: true);
      });
      return controller;
    });

    _dotOpacity = _dotControllers
        .map((c) => Tween<double>(begin: 0.3, end: 1.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    _dotScale = _dotControllers
        .map((c) => Tween<double>(begin: 0.7, end: 1.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _dotControllers) {
      c.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  // ─── Sample Contract ──────────────────────────────────────────────────────

  static const _sampleContract = '''FREELANCE SERVICES AGREEMENT

This Agreement is entered into between Acme Corp ("Client") and the undersigned freelancer ("Contractor").

1. REVISIONS
Contractor shall perform unlimited revisions until Client is fully satisfied with all deliverables, at no additional cost.

2. PAYMENT
Payment shall be withheld at Client's sole discretion until Client determines, in its absolute judgment, that all deliverables fully meet Client's expectations. Client reserves the right to withhold any or all payments for any reason.

3. INTELLECTUAL PROPERTY
All intellectual property rights, including but not limited to all concepts, drafts, rejected work, preliminary designs, and final deliverables, shall transfer to Client immediately upon creation, whether or not payment has been made. Contractor hereby irrevocably waives all moral rights in any work product.

4. NON-COMPETE
Contractor agrees not to work with any company, individual, or entity operating in any industry worldwide for a period of 24 months following termination of this agreement.

5. CONFIDENTIALITY
Contractor agrees to maintain strict confidentiality of all information, including publicly available information, indefinitely and without limitation.

6. TERMINATION
Client may terminate this Agreement at any time without notice. Upon termination for any reason, Contractor forfeits all unpaid compensation for work already completed.

7. INDEMNIFICATION
Contractor shall indemnify and hold harmless Client from any and all claims, damages, losses, or expenses arising from any cause whatsoever, including causes solely attributable to Client's own actions or negligence.
''';

  void _loadSample() {
    _controller.text = _sampleContract;
  }

  // ─── API Call ─────────────────────────────────────────────────────────────

  Future<void> _analyze() async {
    final contractText = _controller.text.trim();
    if (contractText.isEmpty) return;

    setState(() => _view = AppView.loading);

    try {
      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': const String.fromEnvironment('ANTHROPIC_API_KEY',
              defaultValue: ''),
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1000,
          'messages': [
            {'role': 'user', 'content': _buildPrompt(contractText)}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final rawText =
            (body['content'] as List).first['text'] as String;
        final cleaned = _stripMarkdownFences(rawText);
        final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
        setState(() {
          _result = parsed;
          _view = AppView.results;
        });
      } else {
        _showError();
      }
    } catch (_) {
      _showError();
    }
  }

  String _stripMarkdownFences(String text) {
    final stripped = text.trim();
    final noFence = stripped
        .replaceAll(RegExp(r'^```[a-z]*\s*', multiLine: false), '')
        .replaceAll(RegExp(r'```\s*$', multiLine: false), '');
    return noFence.trim();
  }

  void _showError() {
    setState(() => _view = AppView.input);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analysis failed. Please try again.')),
      );
    }
  }

  String _buildPrompt(String contract) {
    return '''You are an expert contract lawyer reviewing a freelance agreement on behalf of the freelancer. Analyze the following contract and identify genuinely risky clauses.

Return ONLY raw JSON (no markdown, no backticks, no explanation) in exactly this shape:
{
  "overall_risk": "HIGH|MEDIUM|LOW",
  "risk_score": <integer 1-10>,
  "flags_count": <integer>,
  "summary": "<2-sentence plain English overview of the contract's main risks>",
  "clauses": [
    {
      "title": "<short descriptive name>",
      "risk": "HIGH|MEDIUM|LOW",
      "quote": "<exact problematic text from contract, max 80 chars>",
      "issue": "<why this clause is dangerous for the freelancer>",
      "suggestion": "<better alternative language the freelancer should propose>"
    }
  ]
}

Order clauses HIGH risk first, then MEDIUM, then LOW. Only flag genuinely risky clauses.

CONTRACT TO ANALYZE:
$contract''';
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_view) {
          AppView.input => _buildInputView(),
          AppView.loading => _buildLoadingView(),
          AppView.results => _buildResultsView(),
        },
      ),
    );
  }

  // ─── VIEW 1: Input ────────────────────────────────────────────────────────

  Widget _buildInputView() {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Proof',
                      style: GoogleFonts.merriweather(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _primaryText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI CONTRACT ANALYZER',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: _mutedText,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: _thinBorder, thickness: 1),
                const SizedBox(height: 28),

                // Headline
                Text(
                  'Know what you\'re signing.',
                  style: GoogleFonts.merriweather(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _primaryText,
                  ),
                ),
                const SizedBox(height: 12),

                // Subheadline
                Text(
                  'Paste any freelance contract below. Proof flags risky clauses and suggests better terms — in seconds.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: _mutedText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // TextField
                TextField(
                  controller: _controller,
                  minLines: 6,
                  maxLines: null,
                  style: GoogleFonts.dmSans(fontSize: 14, color: _primaryText),
                  decoration: const InputDecoration(
                    hintText: 'Paste your contract here...',
                  ),
                ),
                const SizedBox(height: 8),

                // Load sample
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _loadSample,
                    child: const Text('Load sample contract'),
                  ),
                ),
                const SizedBox(height: 16),

                // Analyze button
                FilledButton(
                  onPressed: _analyze,
                  child: const Text('Analyze contract'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── VIEW 2: Loading ──────────────────────────────────────────────────────

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: AnimatedBuilder(
                  animation: _dotControllers[i],
                  builder: (_, __) => Opacity(
                    opacity: _dotOpacity[i].value,
                    child: Transform.scale(
                      scale: _dotScale[i].value,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _mutedText,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Text(
            'Reading the fine print...',
            style: GoogleFonts.dmSans(fontSize: 14, color: _mutedText),
          ),
        ],
      ),
    );
  }

  // ─── VIEW 3: Results ──────────────────────────────────────────────────────

  Widget _buildResultsView() {
    if (_result == null) return const SizedBox.shrink();

    final overallRisk = (_result!['overall_risk'] as String?) ?? 'LOW';
    final riskScore = _result!['risk_score']?.toString() ?? '–';
    final flagsCount = _result!['flags_count']?.toString() ?? '0';
    final summary = (_result!['summary'] as String?) ?? '';
    final clauses = (_result!['clauses'] as List<dynamic>?) ?? [];

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Proof',
                      style: GoogleFonts.merriweather(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _primaryText,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI CONTRACT ANALYZER',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: _mutedText,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: _thinBorder, thickness: 1),
                const SizedBox(height: 20),

                // Metric row
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: 'RISK LEVEL',
                          value: overallRisk,
                          valueColor: _riskColor(overallRisk),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          label: 'RISK SCORE',
                          value: '$riskScore/10',
                          valueColor: _riskColor(overallRisk),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          label: 'ISSUES FOUND',
                          value: flagsCount,
                          valueColor: _riskColor(overallRisk),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Summary box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _summaryBg,
                    borderRadius: BorderRadius.circular(12),
                    border: const Border(
                      left: BorderSide(color: _summaryBorder, width: 3),
                    ),
                  ),
                  child: Text(
                    summary,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: _primaryText,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Section label
                Text(
                  'FLAGGED CLAUSES',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: _mutedText,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Clause cards
                ...clauses.map((clause) {
                  final c = clause as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ClauseCard(clause: c),
                  );
                }),

                const SizedBox(height: 8),

                // Analyze another
                Center(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _result = null;
                        _view = AppView.input;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryText,
                      side: const BorderSide(color: _thinBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: GoogleFonts.dmSans(fontSize: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Analyze another contract'),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Metric Card ─────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _thinBorder, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: _mutedText,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.merriweather(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Clause Card ─────────────────────────────────────────────────────────────

class _ClauseCard extends StatelessWidget {
  const _ClauseCard({required this.clause});

  final Map<String, dynamic> clause;

  @override
  Widget build(BuildContext context) {
    final risk = (clause['risk'] as String?) ?? 'LOW';
    final title = (clause['title'] as String?) ?? '';
    final quote = (clause['quote'] as String?) ?? '';
    final issue = (clause['issue'] as String?) ?? '';
    final suggestion = (clause['suggestion'] as String?) ?? '';
    final riskColor = _riskColor(risk);

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: riskColor, width: 3),
          top: const BorderSide(color: _thinBorder, width: 0.5),
          right: const BorderSide(color: _thinBorder, width: 0.5),
          bottom: const BorderSide(color: _thinBorder, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: badge + title
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  risk.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: riskColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quote with left border accent
          if (quote.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.only(left: 12),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: _summaryBorder, width: 2),
                ),
              ),
              child: Text(
                '"$quote"',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: _mutedText,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Issue
          Text(
            issue,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: _primaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Suggestion label
          Text(
            'SUGGESTED LANGUAGE',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: _mutedText,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          // Suggestion box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _summaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              suggestion,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: _primaryText,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
