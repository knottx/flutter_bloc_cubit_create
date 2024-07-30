import 'dart:convert';
import 'dart:js_interop';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_create_page/raw_code.dart';
import 'package:recase/recase.dart';
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:web/web.dart' as web;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bloc/Cubit Create',
      darkTheme: ThemeData.dark().copyWith(
        splashFactory: NoSplash.splashFactory,
      ),
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Highlighter? _highlighter;

  final TextEditingController _nameTextEditingController =
      TextEditingController();

  String _stateCode = '';
  String _cubitCode = '';
  String _screenCode = '';

  final ValueNotifier<String> _nameNotifier = ValueNotifier('');

  final ScrollController _scrollController = ScrollController();
  final ScrollController _stateCodeScrollController = ScrollController();
  final ScrollController _cubitCodeScrollController = ScrollController();
  final ScrollController _screenCodeScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameTextEditingController.addListener(_nameTextEditingListener);
      _nameTextEditingController.text = 'Home';
      _initializeHighlighter();
    });
  }

  @override
  void dispose() {
    _nameTextEditingController.dispose();
    _scrollController.dispose();
    _stateCodeScrollController.dispose();
    _cubitCodeScrollController.dispose();
    _screenCodeScrollController.dispose();
    super.dispose();
  }

  void _initializeHighlighter() async {
    await Highlighter.initialize(['dart']);
    final highlighterDarkTheme = await HighlighterTheme.loadDarkTheme();
    _highlighter = Highlighter(
      language: 'dart',
      theme: highlighterDarkTheme,
    );
    setState(() {});
  }

  void _nameTextEditingListener() {
    final name = _nameTextEditingController.text;
    const suffix = '_screen';
    String validName = name.snakeCase;
    if (validName.endsWith(suffix)) {
      validName = validName.substring(
        0,
        validName.length - suffix.length,
      );
    }
    _stateCode = RawCode.state(validName);
    _cubitCode = RawCode.cubit(validName);
    _screenCode = RawCode.screen(validName);
    _nameNotifier.value = validName;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: _buildBody(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNameField(),
        ValueListenableBuilder(
          valueListenable: _nameNotifier,
          builder: (context, name, child) {
            return Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCode(
                  controller: _stateCodeScrollController,
                  fileName: '${name.snakeCase}_screen_state.dart',
                  code: _stateCode,
                ),
                _buildCode(
                  controller: _cubitCodeScrollController,
                  fileName: '${name.snakeCase}_screen_cubit.dart',
                  code: _cubitCode,
                ),
                _buildCode(
                  controller: _screenCodeScrollController,
                  fileName: '${name.snakeCase}_screen.dart',
                  code: _screenCode,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameTextEditingController,
                style: const TextStyle(fontFamily: 'Consolas'),
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: 'Name',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(width: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              spacing: 4,
              children: [
                IconButton.filledTonal(
                  onPressed: _onTapDownload,
                  icon: const Icon(Icons.download),
                ),
                const Text(
                  'Download',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCode({
    required ScrollController controller,
    required String fileName,
    required String code,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                fileName,
                style: const TextStyle(fontFamily: 'Consolas'),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.black,
                ),
                child: IntrinsicHeight(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: Scrollbar(
                          controller: controller,
                          child: SingleChildScrollView(
                            controller: controller,
                            child: Text.rich(
                              _highlighter != null
                                  ? _highlighter!.highlight(code)
                                  : TextSpan(text: code),
                              style: const TextStyle(fontFamily: 'Consolas'),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton.filledTonal(
                          onPressed: () {
                            _onTapCopy(code);
                          },
                          icon: const Icon(Icons.copy, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapCopy(String data) {
    Clipboard.setData(ClipboardData(text: data));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Copied!'),
          ],
        ),
      ),
    );
  }

  void _onTapDownload() {
    final archive = Archive();

    final name = _nameNotifier.value.snakeCase;

    final stateCodeFileBytes = utf8.encode(_stateCode);
    archive.addFile(
      ArchiveFile(
        'cubit/${name}_screen_state.dart',
        stateCodeFileBytes.length,
        stateCodeFileBytes,
      ),
    );

    final cubitCodeFileBytes = utf8.encode(_cubitCode);
    archive.addFile(
      ArchiveFile(
        'cubit/${name}_screen_cubit.dart',
        cubitCodeFileBytes.length,
        cubitCodeFileBytes,
      ),
    );

    final screenCodeFileBytes = utf8.encode(_screenCode);
    archive.addFile(
      ArchiveFile(
        '${name}_screen.dart',
        screenCodeFileBytes.length,
        screenCodeFileBytes,
      ),
    );

    final zippedData = Uint8List.fromList(ZipEncoder().encode(archive));

    String url = web.URL.createObjectURL(
      web.Blob(
        [zippedData.toJS].toJS,
        web.BlobPropertyBag(type: 'application/zip'),
      ),
    );

    web.Document htmlDocument = web.document;
    web.HTMLAnchorElement anchor =
        htmlDocument.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.style.display = '$name.zip';
    anchor.download = '$name.zip';
    web.document.body!.add(anchor);
    anchor.click();
    anchor.remove();
  }
}
