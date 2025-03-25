import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/translation_service.dart'; // DeepL 翻訳サービスをインポート
import 'login_screen.dart'; // ログアウト後に遷移する画面をインポート

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();
  final TranslationService _translationService = TranslationService(); // DeepL翻訳サービス

  String _translatedText = ""; // 翻訳後のテキスト

  /// メッセージを Firestore に送信する関数
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      try {
        await _db.collection('messages').add({
          'user_id': FirebaseAuth.instance.currentUser?.uid,
          'message': _controller.text,
          'timestamp': Timestamp.now(),
        });

        // `mounted` をチェックして `context` を安全に使用
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('メッセージを送信しました')));

        _controller.clear();
      } catch (e) {
        // `mounted` をチェックして `context` を安全に使用
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('送信エラー: $e')));
      }
    }
  }

  /// ログアウト処理
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  /// メッセージを翻訳する関数
  Future<void> _translateMessage(String message, String targetLang) async {
    String? translated = await _translationService.translate(
      message,
      targetLang,
    );

    // 非同期処理後に `mounted` をチェックして `context` を安全に使用
    if (!mounted) return;

    if (translated != null) {
      setState(() {
        _translatedText = translated;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('翻訳に失敗しました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EduConnect"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // ログアウトボタン
            tooltip: "ログアウト",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream:
                  _db
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("メッセージがありません"));
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((doc) {
                        return ListTile(
                          title: Text(doc['message']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc['timestamp'].toDate().toString(),
                              ), // メッセージの時間
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.translate),
                                    onPressed:
                                        () => _translateMessage(
                                          doc['message'],
                                          "JA",
                                        ), // 日本語に翻訳
                                    tooltip: "日本語に翻訳",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.translate),
                                    onPressed:
                                        () => _translateMessage(
                                          doc['message'],
                                          "PT",
                                        ), // ポルトガル語に翻訳
                                    tooltip: "ポルトガル語に翻訳",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "ここにメッセージを入力…",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _sendMessage,
                        child: const Text("送信"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "翻訳結果: $_translatedText",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
