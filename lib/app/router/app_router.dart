import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_home_page.dart';
import '../../features/dashboard/presentation/statistics_page.dart';
import '../../features/plans/presentation/editor/plan_editor_page.dart';
import '../../features/plans/presentation/plans_home_page.dart';
import '../../features/plans/presentation/course_import_page.dart';
import '../../features/pomodoro/presentation/pomodoro_home_page.dart';
import '../../features/settings/presentation/settings_home_page.dart';
import '../../features/vocabulary/presentation/import/word_import_page.dart';
import '../../features/vocabulary/presentation/study/study_page.dart';
import '../../features/vocabulary/presentation/vocabulary_home_page.dart';
import '../../features/vocabulary/presentation/word_book_page.dart';
import '../../features/vocabulary/presentation/builtin_word_books_page.dart';
import '../../features/vocabulary/presentation/mistake_words_page.dart';
import '../../features/vocabulary/presentation/tests/vocabulary_test_center_page.dart';
import '../../features/vocabulary/presentation/tests/vocabulary_test_page.dart';
import '../../features/vocabulary/domain/vocabulary_test_mode.dart';
import '../../features/toolbox/data/exam_materials_repository.dart';
import '../../features/toolbox/presentation/toolbox_home_page.dart';
import '../../features/toolbox/presentation/exam_materials_page.dart';
import '../../features/toolbox/presentation/exam_video_player_page.dart';
import '../../features/toolbox/presentation/exam_text_reader_page.dart';
import '../navigation.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/today',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const DashboardHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/words',
                builder: (context, state) => const VocabularyHomePage(),
                routes: [
                  GoRoute(
                    path: 'library',
                    builder: (context, state) => const BuiltinWordBooksPage(),
                  ),
                  GoRoute(
                    path: 'import',
                    builder: (context, state) => const WordImportPage(),
                  ),
                  GoRoute(
                    path: 'mistakes',
                    builder: (context, state) => const MistakeWordsPage(),
                    routes: [
                      GoRoute(
                        path: 'study',
                        builder: (context, state) => const StudyPage.mistakes(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'tests',
                    builder: (context, state) =>
                        const VocabularyTestCenterPage(),
                    routes: [
                      GoRoute(
                        path: ':mode',
                        builder: (context, state) {
                          final mode = VocabularyTestModeInfo.fromRoute(
                            state.pathParameters['mode'] ?? '',
                          );
                          final bookId = int.tryParse(
                            state.uri.queryParameters['bookId'] ?? '',
                          );
                          if (mode == null || bookId == null) {
                            return const Scaffold(
                              body: Center(child: Text('测试参数无效')),
                            );
                          }
                          return VocabularyTestPage(
                            wordBookId: bookId,
                            mode: mode,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'book/:bookId',
                    builder: (context, state) => WordBookPage(
                      bookId: int.parse(state.pathParameters['bookId']!),
                    ),
                  ),
                  GoRoute(
                    path: 'book/:bookId/study',
                    builder: (context, state) => StudyPage(
                      wordBookId: int.parse(state.pathParameters['bookId']!),
                      wordBookName: state.uri.queryParameters['name'] ?? '单词学习',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plans',
                builder: (context, state) => const PlansHomePage(),
                routes: [
                  GoRoute(
                    path: 'import',
                    builder: (context, state) => const CourseImportPage(),
                  ),
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => PlanEditorPage(
                      initialDate:
                          DateTime.tryParse(
                            state.uri.queryParameters['date'] ?? '',
                          ) ??
                          DateTime.now(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/focus',
                builder: (context, state) => const PomodoroHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tools',
                builder: (context, state) => const ToolboxHomePage(),
                routes: [
                  GoRoute(
                    path: 'materials',
                    builder: (context, state) => const ExamMaterialsPage(),
                    routes: [
                      GoRoute(
                        path: 'video',
                        builder: (context, state) {
                          final video = state.extra;
                          if (video is! ExamMaterial ||
                              video.kind != ExamMaterialKind.video) {
                            return const Scaffold(
                              body: Center(child: Text('视频信息已失效，请返回重新选择')),
                            );
                          }
                          return ExamVideoPlayerPage(material: video);
                        },
                      ),
                      GoRoute(
                        path: 'text',
                        builder: (context, state) {
                          final material = state.extra;
                          if (material is! ExamMaterial ||
                              material.kind != ExamMaterialKind.text) {
                            return const Scaffold(
                              body: Center(child: Text('文本信息已失效，请返回重新选择')),
                            );
                          }
                          return ExamTextReaderPage(material: material);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/statistics',
        builder: (context, state) => const StatisticsPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/settings',
        builder: (context, state) => const SettingsHomePage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '今日',
          ),
          NavigationDestination(
            icon: Icon(Icons.translate_outlined),
            selectedIcon: Icon(Icons.translate),
            label: '单词',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: '计划',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: '番茄钟',
          ),
          NavigationDestination(
            icon: Icon(Icons.handyman_outlined),
            selectedIcon: Icon(Icons.handyman),
            label: '工具箱',
          ),
        ],
      ),
    );
  }
}
