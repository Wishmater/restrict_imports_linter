/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

// export 'src/restrict_imports_linter_base.dart';


// This is the entrypoint of our custom linter
PluginBase createPlugin() => _RestrictImportsLinter();

/// A plugin class is used to list all the assists/lints defined by a plugin.
class _RestrictImportsLinter extends PluginBase {
  /// We list all the custom warnings/infos/errors
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    final customImportRestrictionRules = configs.rules['custom_import_restrictions'];
    return [
      if (customImportRestrictionRules?.enabled ?? false)
        ForbiddenImportRestrictionCode(customImportRestrictionRules!.json),
    ];
  }
}

class ForbiddenImportRestrictionCode extends DartLintRule {

  final Map<String, Object?> options;

  ForbiddenImportRestrictionCode(this.options) : super(code: _code);

  static const _code = LintCode(
    name: 'custom_import_restrictions',
    errorSeverity: ErrorSeverity.ERROR,
    problemMessage: "Don't import files from that module into this module",
  );

  @override
  void run(
      CustomLintResolver resolver,
      ErrorReporter reporter,
      CustomLintContext context,
      ) {

    context.registry.addImportDirective((node) {
      if (node.element?.importedLibrary==null) return;
      final current = node.element!.library.identifier;
      final importing = node.element!.importedLibrary!.identifier;
      for (final disallowedFrom in options.keys) {
        final disallowedTos = options[disallowedFrom]!;
        if (disallowedTos is List) {
          for (final disallowedTo in disallowedTos) {
            print ('     $disallowedFrom -- $disallowedTo');
            if (current.startsWith(disallowedFrom)
                && importing.startsWith(disallowedTo)) {
              reporter.reportErrorForNode(LintCode(
                  name: _code.name,
                  errorSeverity: _code.errorSeverity,
                  problemMessage: "Don't import files from $disallowedFrom into $disallowedTo"
              ), node);
            }
          }
        }
      }
    });
  }
}