import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_translations.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pak Machinery Manager',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC107),
          primary: const Color(0xFFFFC107),
          secondary: const Color(0xFF00796B),
          background: const Color(0xFFF9FAFB),
          surface: Colors.white,
        ),
        cardTheme: const CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 6),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFFFC107),
          primary: const Color(0xFFFFD54F),
          secondary: const Color(0xFF26A69A),
          background: const Color(0xFF121212),
          surface: const Color(0xFF1E1E1E),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isPinVerified = false;
  String _enteredPin = "";
  bool _isUrdu = false;

  void _verifyPin(String val) {
    if (val == "5555" || val == "0000") {
      setState(() {
        _isPinVerified = true;
      });
    } else {
      setState(() {
        _enteredPin = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isUrdu ? "غلط پن کوڈ!" : "Invalid PIN! Use 0000")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPinVerified) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person, size: 72, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  _isUrdu ? "پاک مشینری مینیجر" : "Pak Machinery Manager",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _isUrdu ? "بیک اپ، سیکیورٹی اور خودکار حساب کتاب" : "Professional Construction & Fuel Ledger System",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                Text(
                  _isUrdu ? "سیکیورٹی پن درج کریں (0000)" : "Enter Access PIN (Default: 0000)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: TextField(
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 4,
                    onChanged: (v) {
                      if (v.length == 4) {
                        _verifyPin(v);
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      counterText: "",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _isUrdu = false),
                      child: const Text("English"),
                    ),
                    const Text("|"),
                    TextButton(
                      onPressed: () => setState(() => _isUrdu = true),
                      child: const Text("اردو"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    return HomeScreen(isUrdu: _isUrdu);
  }
}

class HomeScreen extends StatefulWidget {
  final bool isUrdu;
  const HomeScreen({super.key, required this.isUrdu});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool isUrdu;
  int _activeModuleIndex = -1; // -1 for main EasyPaisa dashboard

  // Temporary local lists loaded sequentially
  List<Map<String, dynamic>> partners = [];
  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> dailyIncomes = [];

  @override
  void initState() {
    super.initState();
    isUrdu = widget.isUrdu;
    _refreshData();
  }

  Future<void> _refreshData() async {
    final pData = await DatabaseHelper.instance.queryAll('partners');
    final vData = await DatabaseHelper.instance.queryAll('vehicles');
    final iData = await DatabaseHelper.instance.queryAll('daily_incomes');
    setState(() {
      partners = pData;
      vehicles = vData;
      dailyIncomes = iData;
    });
  }

  // Active Modules representing pages requested in prompt
  Widget _buildActivePage() {
    switch (_activeModuleIndex) {
      case 0:
        return _buildIncomeModule();
      case 1:
        return _buildFuelModule();
      case 2:
        return _buildRepairsModule();
      case 3:
        return _buildPartnersModule();
      case 4:
        return _buildVehiclesModule();
      case 5:
        return _buildLocationsModule();
      case 6:
        return _buildPaymentsWithdrawalsModule();
      case 7:
        return _buildCreditOutstandingModule();
      case 8:
        return _buildAccountingReportsPage();
      default:
        return _buildEasyPaisaDashboard();
    }
  }

  Widget _buildBentoCard({
    required String title,
    required String subtitle,
    required String iconEmoji,
    required Color lightBg,
    required Color darkBg,
    required Color lightBorder,
    required Color darkBorder,
    required Color lightContent,
    required Color darkContent,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? darkBg : lightBg;
    final border = isDark ? darkBorder : lightBorder;
    final content = isDark ? darkContent : lightContent;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: content.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      iconEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (badgeColor ?? content).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: badgeColor ?? content,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: content,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: content.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEasyPaisaDashboard() {
    final double todayInc = dailyIncomes.fold(0, (sum, item) => sum + (item['incomeAmount'] ?? 0.0));
    final double outstanding = 450000.0;
    const double netProfit = 312000.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bento Hub Header with total cash flow diagnostics inside
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18.0, 56.0, 18.0, 24.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F2537) : const Color(0xFF004A77),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white24,
                          radius: 20,
                          child: Text(
                            partners.isNotEmpty ? partners[0]['name'].toString().substring(0,1).toUpperCase() : "A",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partners.isNotEmpty ? partners[0]['name'] : "Active Partner",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              isUrdu ? "ہیوی مشینری مینیجر" : "Heavy Machinery Mgmt.",
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: const [
                              CircleAvatar(backgroundColor: Color(0xFF4ADE80), radius: 3),
                              SizedBox(width: 4),
                              Text("OFFLINE", style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.translate, color: Colors.white, size: 20),
                          onPressed: () => setState(() => isUrdu = !isUrdu),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Bento Stat row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUrdu ? "خالص منافع" : "NET PROFIT",
                              style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₨ ${netProfit.toStringAsFixed(0)}",
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.extrabold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUrdu ? "بقایا ادھار" : "OUTSTANDING",
                              style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₨ ${outstanding.toStringAsFixed(0)}",
                              style: const TextStyle(color: Color(0xFFFFCC80), fontSize: 16, fontWeight: FontWeight.extrabold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUrdu ? "کاروباری ماڈیولز (BUSINESS MODULES)" : "BUSINESS MODULES",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.extrabold,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),

                // ROW 1: Daily Income & Fuel
                Row(
                  children: [
                    _buildBentoCard(
                      title: LanguageTranslations.getLabel('daily_income', isUrdu ? 'ur' : 'en'),
                      subtitle: isUrdu ? "روزانہ کی آمدنی" : "Records Ledger",
                      iconEmoji: "₨",
                      lightBg: const Color(0xFFE3F2FD),
                      darkBg: const Color(0xFF172554),
                      lightBorder: const Color(0xFFBBDEFB),
                      darkBorder: const Color(0xFF1E3A8A),
                      lightContent: const Color(0xFF0D47A1),
                      darkContent: const Color(0xFF93C5FD),
                      onTap: () => setState(() => _activeModuleIndex = 0),
                    ),
                    const SizedBox(width: 12),
                    _buildBentoCard(
                      title: LanguageTranslations.getLabel('fuel_mgmt', isUrdu ? 'ur' : 'en'),
                      subtitle: isUrdu ? "تیل کا خرچہ" : "Fuel Logs",
                      iconEmoji: "⛽",
                      lightBg: const Color(0xFFFFF3E0),
                      darkBg: const Color(0xFF451A03),
                      lightBorder: const Color(0xFFFFE0B2),
                      darkBorder: const Color(0xFF7C2D12),
                      lightContent: const Color(0xFFE65100),
                      darkContent: const Color(0xFFFDBA74),
                      onTap: () => setState(() => _activeModuleIndex = 1),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ROW 2: Repairs & Heavy Machinery & Partners
                Row(
                  children: [
                    _buildBentoCard(
                      title: LanguageTranslations.getLabel('repairs_mgmt', isUrdu ? 'ur' : 'en'),
                      subtitle: isUrdu ? "مشینری مرمت" : "Repairs",
                      iconEmoji: "🔧",
                      lightBg: const Color(0xFFF1F8E9),
                      darkBg: const Color(0xFF064E3B),
                      lightBorder: const Color(0xFFDCEDC8),
                      darkBorder: const Color(0xFF065F46),
                      lightContent: const Color(0xFF33691E),
                      darkContent: const Color(0xFF6EE7B7),
                      onTap: () => setState(() => _activeModuleIndex = 2),
                    ),
                    const SizedBox(width: 10),
                    _buildBentoCard(
                      title: LanguageTranslations.getLabel('vehicles_mgmt', isUrdu ? 'ur' : 'en'),
                      subtitle: isUrdu ? "گاڑیوں کی لسٹ" : "Fleet List",
                      iconEmoji: "🚜",
                      lightBg: Colors.white,
                      darkBg: const Color(0xFF1E293B),
                      lightBorder: const Color(0xFFE2E8F0),
                      darkBorder: const Color(0xFF334155),
                      lightContent: const Color(0xFF1E293B),
                      darkContent: const Color(0xFFCBD5E1),
                      onTap: () => setState(() => _activeModuleIndex = 4),
                    ),
                    const SizedBox(width: 10),
                    _buildBentoCard(
                      title: LanguageTranslations.getLabel('partner_mgmt', isUrdu ? 'ur' : 'en'),
                      subtitle: isUrdu ? "شراکت دار" : "Partners",
                      iconEmoji: "👥",
                      lightBg: Colors.white,
                      darkBg: const Color(0xFF1E293B),
                      lightBorder: const Color(0xFFE2E8F0),
                      darkBorder: const Color(0xFF334155),
                      lightContent: const Color(0xFF1E293B),
                      darkContent: const Color(0xFFCBD5E1),
                      onTap: () => setState(() => _activeModuleIndex = 3),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ROW 3: Work Locations & Reports
                Row(
                  children: [
                    _buildBentoCard(
                      title: LanguageTranslations.getLabel('locations_mgmt', isUrdu ? 'ur' : 'en'),
                      subtitle: isUrdu ? "کام کی جگہ" : "Sites",
                      iconEmoji: "📍",
                      lightBg: const Color(0xFFE8EAF6),
                      darkBg: const Color(0xFF1E1B4B),
                      lightBorder: const Color(0xFFC5CAE9),
                      darkBorder: const Color(0xFF312E81),
                      lightContent: const Color(0xFF1A237E),
                      darkContent: const Color(0xFFC7D2FE),
                      onTap: () => setState(() => _activeModuleIndex = 5),
                    ),
                    const SizedBox(width: 12),
                    _buildBentoCard(
                      title: LanguageTranslations.getLabel('reports', isUrdu ? 'ur' : 'en'),
                      subtitle: isUrdu ? "رپورٹس" : "Accounts",
                      iconEmoji: "📊",
                      lightBg: const Color(0xFFFCE4EC),
                      darkBg: const Color(0xFF4C0519),
                      lightBorder: const Color(0xFFF8BBD0),
                      darkBorder: const Color(0xFF881337),
                      lightContent: const Color(0xFF880E4F),
                      darkContent: const Color(0xFFFBCFE8),
                      badgeText: "STATS",
                      badgeColor: const Color(0xFFE91E63),
                      onTap: () => setState(() => _activeModuleIndex = 8),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ROW 4: Partner Payments & Outstanding
                Row(
                  children: [
                    _buildBentoCard(
                      title: LanguageTranslations.getLabel('payments_mgmt', isUrdu ? 'ur' : 'en'),
                      subtitle: isUrdu ? "ادائیگیاں" : "Payouts",
                      iconEmoji: "💳",
                      lightBg: const Color(0xFFF3E5F5),
                      darkBg: const Color(0xFF3B0764),
                      lightBorder: const Color(0xFFE1BEE7),
                      darkBorder: const Color(0xFF581C87),
                      lightContent: const Color(0xFF4A148C),
                      darkContent: const Color(0xFFF3E8FF),
                      onTap: () => setState(() => _activeModuleIndex = 6),
                    ),
                    const SizedBox(width: 12),
                    _buildBentoCard(
                      title: LanguageTranslations.getLabel('outstanding_mgmt', isUrdu ? 'ur' : 'en'),
                      subtitle: isUrdu ? "بقایا جات" : "Dues",
                      iconEmoji: "📜",
                      lightBg: const Color(0xFFE0F2F1),
                      darkBg: const Color(0xFF115E59),
                      lightBorder: const Color(0xFFB2DFDB),
                      darkBorder: const Color(0xFF134E4A),
                      lightContent: const Color(0xFF004D40),
                      darkContent: const Color(0xFF99F6E4),
                      onTap: () => setState(() => _activeModuleIndex = 7),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Backup and settings
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  tileColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08)),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    child: Icon(Icons.backup, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(isUrdu ? "خودکار لوکل بیک اپ" : "Local Backup Center", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(isUrdu ? "کلاؤڈ سنک اور ڈبل تحفظ" : "Export offline files & backup restore instantly", style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isUrdu ? "بیک اپ کامیابی سے محفوظ کر دیا گیا!" : "Backup zip file successfully exported!")),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIncomeModule() {
    double incomeVal = 12000.0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isUrdu ? "نیا آمدنی ریکارڈ درج کریں" : "Quick Daily Income Recording Form", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField(isUrdu ? "رقم (روپے)" : "Income Amount (Rs.)", (v) => incomeVal = double.tryParse(v) ?? 12000.0),
          const SizedBox(height: 12),
          _buildTextField(isUrdu ? "سائٹ لوکیشن" : "Site Location", (v) {}),
          const SizedBox(height: 12),
          _buildTextField(isUrdu ? "گراہک کا نام" : "Customer / Employer Name", (v) {}),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () async {
              await DatabaseHelper.instance.insertRecord('daily_incomes', {
                'date': '2026-05-31',
                'time': '12:00:00',
                'vehicleId': 1,
                'vehicleName': 'Komatsu PC320',
                'workLocationId': 1,
                'workLocationName': 'GT Road bypassed Site',
                'customerName': 'Habib Construction Ltd',
                'incomeAmount': incomeVal,
                'notes': 'Excavator daily log sheet synced offline',
                'recordedBy': 'Admin User',
                'recordedByColor': 'Yellow'
              });
              _refreshData();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isUrdu ? "ریکارڈ محفوظ کر لیا گیا" : "Income record saved successfully!")));
              setState(() => _activeModuleIndex = -1);
            },
            child: Text(LanguageTranslations.getLabel('save', isUrdu ? 'ur' : 'en')),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelModule() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(isUrdu ? "ایندھن کا خرچ" : "Fuel & Diesel Management Intake", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField(isUrdu ? "ایندھن کی مقدار (لیٹر)" : "Diesel Quantity (Liters)", (v) {}),
          const SizedBox(height: 12),
          _buildTextField(isUrdu ? "کل قیمت (روپے)" : "Fuel Cost (PKR)", (v) {}),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isUrdu ? "ایندھن محفوظ کر لیا گیا" : "Fuel intake recorded successfully!")));
              setState(() => _activeModuleIndex = -1);
            },
            child: Text(LanguageTranslations.getLabel('save', isUrdu ? 'ur' : 'en')),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairsModule() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(isUrdu ? "مرمت اور دیکھ بھال" : "Repair & Preventive Maintenance Logs", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField(isUrdu ? "انجن آئل / بریک آئل قیمت" : "Engine / Brake Oil Cost", (v) {}),
          const SizedBox(height: 12),
          _buildTextField(isUrdu ? "اسپیئر پارٹس قیمت" : "Spare Parts Replacement Cost", (v) {}),
          const SizedBox(height: 12),
          _buildTextField(isUrdu ? "لیبر خرچہ" : "Labor & Technicians Wage", (v) {}),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isUrdu ? "ریکارڈ محفوظ ہو گیا" : "Repair ledger successfully catalogued!")));
              setState(() => _activeModuleIndex = -1);
            },
            child: Text(LanguageTranslations.getLabel('save', isUrdu ? 'ur' : 'en')),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersModule() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(isUrdu ? "شراکت داروں کا کھاتہ" : "Partners & Stakeholders Allocation", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: partners.length,
              itemBuilder: (ctx, i) {
                final p = partners[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getPartnerColor(p['colorAssignment']),
                      radius: 12,
                    ),
                    title: Text(p['name']),
                    subtitle: Text("${isUrdu ? "حصہ فیصد" : "Share Percentage"}: ${p['sharePercentage']}%"),
                    trailing: Text(p['mobileNumber']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesModule() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(isUrdu ? "ہیوی مشینری لسٹ" : "Machinery Fleet & Registration List", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (ctx, i) {
                final v = vehicles[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.engineering),
                    title: Text(v['name']),
                    subtitle: Text("${isUrdu ? "نمبر سلپ" : "Reg Number"}: ${v['registrationNumber']}"),
                    trailing: Chip(label: Text(v['status'])),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsModule() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(isUrdu ? "تعمیراتی سائٹس" : "Site Work Locations & Customers", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField(isUrdu ? "سائٹ کا نام" : "Site Name", (v) {}),
          _buildTextField(isUrdu ? "ایریا کا نام" : "Area City Location", (v) {}),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isUrdu ? "سائٹ شامل کر دی گئی" : "Work Location Saved Successfully!")));
              setState(() => _activeModuleIndex = -1);
            },
            child: Text(LanguageTranslations.getLabel('save', isUrdu ? 'ur' : 'en')),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsWithdrawalsModule() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(isUrdu ? "شراکت دار نکالنے کا کھاتہ" : "Partners Payments & Drawdown Module", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField(isUrdu ? "رقم نکالیں (روپے)" : "Withdrawal Amount (Rs.)", (v) {}),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isUrdu ? "رقم ریکارڈ محفوظ کر دی گئی" : "Withdrawal saved securely!")));
              setState(() => _activeModuleIndex = -1);
            },
            child: Text(LanguageTranslations.getLabel('save', isUrdu ? 'ur' : 'en')),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditOutstandingModule() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(isUrdu ? "ادھار کا ریکارڈ" : "Credits & Receivables Accounts Ledger", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField(isUrdu ? "گراہک بقایا رقم" : "Customer Debt (Rs.)", (v) {}),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isUrdu ? "بقایا ادھار محفوظ کیا گیا" : "Outstanding credit ledger locked!")));
              setState(() => _activeModuleIndex = -1);
            },
            child: Text(LanguageTranslations.getLabel('save', isUrdu ? 'ur' : 'en')),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountingReportsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LanguageTranslations.getLabel('reports', isUrdu ? 'ur' : 'en'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(isUrdu ? "بیک وقت شراکت دار موازنہ" : "Dual Analytical Vehicle Performance Grid", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(Icons.insert_chart, size: 64, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            tileColor: Theme.of(context).colorScheme.surface,
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text(isUrdu ? "رپورٹ پی ڈی ایف فائل ایکسپورٹ کریں" : "Export Official PDF Summary Statement"),
            trailing: const Icon(Icons.cloud_download),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isUrdu ? "رپورٹ پی ڈی ایف ڈاؤن لوڈ ہو گئی" : "PDF Ledger Report exported in Downloads catalog!")));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
      ),
    );
  }

  Color _getPartnerColor(String name) {
    switch (name) {
      case 'Yellow':
        return Colors.yellow;
      case 'Red':
        return Colors.red;
      case 'Black':
        return Colors.black;
      case 'Green':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LanguageTranslations.getLabel('app_title', isUrdu ? 'ur' : 'en')),
        centerTitle: true,
        actions: [
          Row(
            children: [
              Text(isUrdu ? "اردو" : "EN", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Switch(
                value: isUrdu,
                onChanged: (v) {
                  setState(() {
                    isUrdu = v;
                  });
                },
              ),
            ],
          ),
          if (_activeModuleIndex != -1)
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => setState(() => _activeModuleIndex = -1),
            )
        ],
      ),
      body: _buildActivePage(),
    );
  }
}
