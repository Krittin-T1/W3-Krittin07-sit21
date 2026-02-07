import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ปิดแถบ Debug
      title: 'Snack App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent), // เปลี่ยนเป็นโทนส้มให้ดูน่ากิน
        useMaterial3: true,
        fontFamily: 'Kanit', // ถ้ามีฟอนต์ไทยจะสวยมาก
      ),
      home: const MyHomePage(title: '🍿 Snack Station'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _snackNameCtrl = TextEditingController();
  final _snackTypeCtrl = TextEditingController();
  final _snackPriceCtrl = TextEditingController();

  // ฟังก์ชันบันทึกข้อมูลพร้อม Validation
  Future<void> addSnack() async {
    if (_snackNameCtrl.text.isEmpty || _snackPriceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("snacks").add({
      "snackName": _snackNameCtrl.text,
      "snackType": _snackTypeCtrl.text,
      "snackPrice": int.tryParse(_snackPriceCtrl.text) ?? 0,
      "createdAt": DateTime.now(), // เพิ่มเวลาเพื่อใช้เรียงลำดับ
    });

    _snackNameCtrl.clear();
    _snackTypeCtrl.clear();
    _snackPriceCtrl.clear();

    FocusScope.of(context).unfocus(); // ปิดคีย์บอร์ดหลังบันทึก
  }

  // ฟังก์ชันลบข้อมูล
  Future<void> deleteSnack(String id) async {
    await FirebaseFirestore.instance.collection("snacks").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ส่วนของฟอร์มกรอกข้อมูล (ใส่ Card ครอบให้ดูเด่น)
            Card(
              elevation: 0,
              color: Colors.orange.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField(_snackNameCtrl, "ชื่อขนม", Icons.fastfood),
                    const SizedBox(height: 12),
                    _buildTextField(_snackTypeCtrl, "ประเภท (เช่น ของหวาน, ของคาว)", Icons.category),
                    const SizedBox(height: 12),
                    _buildTextField(_snackPriceCtrl, "ราคา (บาท)", Icons.sell, isNumber: true),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: addSnack,
                        icon: const Icon(Icons.add),
                        label: const Text("เพิ่มรายการขนม", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // ส่วนแสดงรายการ
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("snacks")
                    .orderBy("createdAt", descending: true) // เรียงอันใหม่ขึ้นก่อน
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("ยังไม่มีข้อมูลขนม"));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder( // เปลี่ยนเป็น ListView ให้ดูง่ายกว่า Grid ในกรณีมือถือ
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final snack = doc.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: const Icon(Icons.cookie, color: Colors.orange),
                          ),
                          title: Text(snack['snackName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text("${snack['snackType']} • ${snack['snackPrice']} บาท"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => deleteSnack(doc.id),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SnackDetailPage(snack: snack)),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ช่วยสร้าง TextField เพื่อลดโค้ดซ้ำซ้อน
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class SnackDetailPage extends StatelessWidget {
  final Map<String, dynamic> snack;
  const SnackDetailPage({super.key, required this.snack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("รายละเอียด")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.fastfood, size: 100, color: Colors.orangeAccent),
            const SizedBox(height: 20),
            Text(snack['snackName'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Chip(label: Text(snack['snackType']), backgroundColor: Colors.orange.shade50),
            const SizedBox(height: 20),
            Text("ราคาเพียง ${snack['snackPrice']} บาท", style: const TextStyle(fontSize: 20, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}