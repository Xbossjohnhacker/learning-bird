import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data/course_web_table_parser.dart';
import '../domain/course_import.dart';

class CourseSystemWebPage extends StatefulWidget {
  const CourseSystemWebPage({required this.initialUri, super.key});

  final Uri initialUri;

  @override
  State<CourseSystemWebPage> createState() => _CourseSystemWebPageState();
}

class _CourseSystemWebPageState extends State<CourseSystemWebPage> {
  late final WebViewController _controller;
  var _progress = 0;
  var _reading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _loadError = null);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() => _loadError = '页面加载失败：${error.description}');
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null &&
                (uri.scheme == 'https' || uri.scheme == 'http')) {
              return NavigationDecision.navigate;
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('为保护登录安全，只允许打开 http/https 网页')),
              );
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(widget.initialUri);
  }

  Future<void> _readCurrentPage() async {
    if (_reading) return;
    setState(() => _reading = true);
    try {
      final result = await _controller.runJavaScriptReturningResult(
        _courseTableExtractionScript,
      );
      final sheets = CourseWebTableParser.parseExtractionResult(result);
      if (mounted) Navigator.pop<List<CourseSheet>>(context, sheets);
    } on Object catch (error) {
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('暂未读取到课表'),
            content: Text('$error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('返回网页继续操作'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('教务系统课表读取'),
        actions: [
          IconButton(
            tooltip: '后退',
            onPressed: () async {
              if (await _controller.canGoBack()) await _controller.goBack();
            },
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          IconButton(
            tooltip: '刷新网页',
            onPressed: _controller.reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 8),
                  Expanded(child: Text('请登录并进入完整课表页面，再点击底部“读取当前课表”')),
                ],
              ),
            ),
          ),
          if (_progress < 100) LinearProgressIndicator(value: _progress / 100),
          if (_loadError != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _loadError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(child: WebViewWidget(controller: _controller)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _reading ? null : _readCurrentPage,
                  icon: _reading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.table_view_outlined),
                  label: Text(_reading ? '正在读取…' : '读取当前课表'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _courseTableExtractionScript = r'''
(() => {
  const clean = (value) => (value || '')
    .replace(/\u00a0/g, ' ')
    .replace(/[ \t]+/g, ' ')
    .replace(/\n[ \t]+/g, '\n')
    .trim()
    .slice(0, 500);
  const documents = [document];
  document.querySelectorAll('iframe').forEach((frame) => {
    try {
      if (frame.contentDocument) documents.push(frame.contentDocument);
    } catch (_) {}
  });
  const tables = [];
  for (const doc of documents) {
    for (const table of Array.from(doc.querySelectorAll('table')).slice(0, 20)) {
      const cells = [];
      const occupied = new Set();
      const rows = Array.from(table.rows).slice(0, 2000);
      rows.forEach((row, rowIndex) => {
        let column = 0;
        Array.from(row.cells).forEach((cell) => {
          while (occupied.has(`${rowIndex}:${column}`)) column++;
          const rowSpan = Math.max(1, Math.min(100, Number(cell.rowSpan) || 1));
          const columnSpan = Math.max(1, Math.min(20, Number(cell.colSpan) || 1));
          cells.push({
            row: rowIndex,
            column,
            rowSpan,
            columnSpan,
            text: clean(cell.innerText || cell.textContent)
          });
          for (let r = rowIndex; r < rowIndex + rowSpan; r++) {
            for (let c = column; c < column + columnSpan; c++) {
              occupied.add(`${r}:${c}`);
            }
          }
          column += columnSpan;
        });
      });
      if (cells.length > 0 && cells.length <= 4000) {
        tables.push({
          name: clean(table.caption && table.caption.innerText),
          cells
        });
      }
    }
  }
  return JSON.stringify({
    title: clean(document.title),
    url: location.href,
    tables
  });
})()
''';
