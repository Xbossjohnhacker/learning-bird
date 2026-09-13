import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/apps/installed_app_service.dart';

class LinkedAppPicker extends ConsumerStatefulWidget {
  const LinkedAppPicker({super.key});

  @override
  ConsumerState<LinkedAppPicker> createState() => _LinkedAppPickerState();
}

class _LinkedAppPickerState extends ConsumerState<LinkedAppPicker> {
  final _search = TextEditingController();
  late final Future<List<LaunchableApp>> _apps;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _apps = ref.read(installedAppServiceProvider).loadLaunchableApps();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                controller: _search,
                autofocus: true,
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: const InputDecoration(
                  labelText: '选择关联应用',
                  hintText: '搜索 Keep 或其他应用',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<LaunchableApp>>(
                future: _apps,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('应用列表加载失败，请稍后重试'));
                  }
                  final query = _query.toLowerCase();
                  final apps = (snapshot.data ?? const <LaunchableApp>[])
                      .where(
                        (app) =>
                            query.isEmpty ||
                            app.label.toLowerCase().contains(query) ||
                            app.packageName.toLowerCase().contains(query),
                      )
                      .toList(growable: false);
                  if (apps.isEmpty) {
                    return const Center(child: Text('没有找到可打开的应用'));
                  }
                  return ListView.builder(
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      return ListTile(
                        leading: _AppIcon(packageName: app.packageName),
                        title: Text(app.label),
                        subtitle: Text(
                          app.packageName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.pop(context, app),
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
}

class LinkedAppIcon extends ConsumerWidget {
  const LinkedAppIcon({required this.packageName, this.size = 32, super.key});

  final String packageName;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = ref.watch(installedAppIconProvider(packageName));
    return icon.when(
      data: (bytes) => bytes == null
          ? Icon(Icons.apps, size: size)
          : ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.2),
              child: Image.memory(bytes, width: size, height: size),
            ),
      loading: () => SizedBox.square(
        dimension: size,
        child: const Padding(
          padding: EdgeInsets.all(7),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => Icon(Icons.apps, size: size),
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.packageName});

  final String packageName;

  @override
  Widget build(BuildContext context) {
    return LinkedAppIcon(packageName: packageName, size: 40);
  }
}
