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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // ใช้โทนสีม่วง-ชมพู ให้ดูสดใส
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  Future<void> addSnack() async {
    if (_nameCtrl.text.isEmpty) return;
    await FirebaseFirestore.instance.collection("snacks").add({
      "snackName": _nameCtrl.text,
      "snackType": _typeCtrl.text,
      "snackPrice": int.tryParse(_priceCtrl.text) ?? 0,
      "createdAt": FieldValue.serverTimestamp(),
    });
    _nameCtrl.clear(); _typeCtrl.clear(); _priceCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. แต่ง AppBar ด้วยสี Gradient หรือสีพื้นหลังที่เด่น
      appBar: AppBar(
        title: const Text("🍭 My Snack Shop", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 2. ส่วนฟอร์มกรอกข้อมูล (ใช้สีพื้นหลังอ่อนๆ แยกส่วน)
          _buildInputForm(),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [Icon(Icons.list), SizedBox(width: 8), Text("รายการขนมทั้งหมด")]),
          ),
          const Divider(indent: 20, endIndent: 20),

          // 3. ส่วนแสดงผล List
          Expanded(child: _buildSnackList()),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: "ชื่อขนม",
              prefixIcon: Icon(Icons.shopping_bag_outlined),
              border: InputBorder.none, // คลีนๆ ไม่มีเส้นขอบหนา
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _typeCtrl,
                  decoration: const InputDecoration(labelText: "ประเภท", border: InputBorder.none, prefixIcon: Icon(Icons.category_outlined)),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  decoration: const InputDecoration(labelText: "ราคา", border: InputBorder.none, prefixIcon: Icon(Icons.sell_outlined)),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: addSnack,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("บันทึกข้อมูล"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnackList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("snacks").orderBy("createdAt", descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            // สลับสีพื้นหลัง ListTile ให้ดูมีมิติ
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: index % 2 == 0 ? Colors.purple.withOpacity(0.05) : Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple[100],
                  child: const Text("✨"),
                ),
                title: Text(data['snackName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("หมวดหมู่: ${data['snackType']}"),
                trailing: Text("${data['snackPrice']} ฿",
                    style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            );
          },
        );
      },
    );
  }
}