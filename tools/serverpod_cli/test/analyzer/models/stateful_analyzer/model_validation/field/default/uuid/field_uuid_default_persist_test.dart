import 'package:serverpod_cli/analyzer.dart';
import 'package:serverpod_cli/src/analyzer/code_analysis_collector.dart';
import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/config/experimental_feature.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:test/test.dart';

import '../../../../../../../test_util/builders/generator_config_builder.dart';
import '../../../../../../../test_util/builders/model_source_builder.dart';

void main() {
  var config = GeneratorConfigBuilder().build();

  group('Given a class with fields with a "defaultPersist" keyword', () {
    test(
      'when the field is of type UUID and the defaultPersist is set to "random", then the field\'s default persist value is "random".',
      () {
        var models = [
          ModelSourceBuilder().withYaml(
            '''
          class: Example
          table: example
          fields:
            uuidType: UuidValue?, defaultPersist=random
          ''',
          ).build()
        ];

        var collector = CodeGenerationCollector();
        var definitions =
            StatefulAnalyzer(config, models, onErrorsCollector(collector))
                .validateAll();

        expect(collector.errors, isEmpty);

        var definition = definitions.first as ClassDefinition;
        expect(definition.fields.last.defaultPersistValue, 'random');
      },
    );

    test(
      'when the field is of type UUID and the defaultPersist is set to a valid UUID string with single quotes, then the field\'s default persist value is the provided UUID string.',
      () {
        var models = [
          ModelSourceBuilder().withYaml(
            '''
          class: Example
          table: example
          fields:
            uuidType: UuidValue?, defaultPersist='550e8400-e29b-41d4-a716-446655440000'
          ''',
          ).build()
        ];

        var collector = CodeGenerationCollector();
        var definitions =
            StatefulAnalyzer(config, models, onErrorsCollector(collector))
                .validateAll();

        expect(collector.errors, isEmpty);

        var definition = definitions.first as ClassDefinition;

        expect(
          definition.fields.last.defaultPersistValue,
          '\'550e8400-e29b-41d4-a716-446655440000\'',
        );
      },
    );

    test(
      'when the field is of type UUID and the defaultPersist is set to a valid UUID string with double quotes, then the field\'s default persist value is the provided UUID string converted to single quotes.',
      () {
        var models = [
          ModelSourceBuilder().withYaml(
            '''
          class: Example
          table: example
          fields:
            uuidType: UuidValue?, defaultPersist="550e8400-e29b-41d4-a716-446655440000"
          ''',
          ).build()
        ];

        var collector = CodeGenerationCollector();
        var definitions =
            StatefulAnalyzer(config, models, onErrorsCollector(collector))
                .validateAll();

        expect(collector.errors, isEmpty);

        var definition = definitions.first as ClassDefinition;

        expect(
          definition.fields.last.defaultPersistValue,
          '\'550e8400-e29b-41d4-a716-446655440000\'',
        );
      },
    );

    test(
      'when the field is of type UUID and the defaultPersist is empty, then an error is generated.',
      () {
        var models = [
          ModelSourceBuilder().withYaml(
            '''
          class: Example
          table: example
          fields:
            uuidType: UuidValue?, defaultPersist=
          ''',
          ).build()
        ];

        var collector = CodeGenerationCollector();
        StatefulAnalyzer(config, models, onErrorsCollector(collector))
            .validateAll();

        expect(collector.errors, isNotEmpty);

        var firstError = collector.errors.first as SourceSpanSeverityException;
        expect(
          firstError.message,
          'The "defaultPersist" value must be a "random" or valid UUID string (e.g., "defaultPersist"=random or "defaultPersist"=\'550e8400-e29b-41d4-a716-446655440000\').',
        );
      },
    );

    test(
      'when the field is of type UUID with an invalid defaultPersist value, then an error is generated.',
      () {
        var models = [
          ModelSourceBuilder().withYaml(
            '''
        class: Example
        table: example
        fields:
          uuidInvalid: UuidValue?, defaultPersist=INVALID_UUID
        ''',
          ).build()
        ];

        var collector = CodeGenerationCollector();
        StatefulAnalyzer(config, models, onErrorsCollector(collector))
            .validateAll();

        expect(collector.errors, isNotEmpty);

        var firstError = collector.errors.first as SourceSpanSeverityException;
        expect(
          firstError.message,
          'The "defaultPersist" value must be a "random" or valid UUID string (e.g., "defaultPersist"=random or "defaultPersist"=\'550e8400-e29b-41d4-a716-446655440000\').',
        );
      },
    );

    test(
      'when the field is of type UUID with a malformed UUID in single quotes, then an error is generated.',
      () {
        var models = [
          ModelSourceBuilder().withYaml(
            '''
          class: Example
          table: example
          fields:
            uuidMalformed: UuidValue?, defaultPersist='550e8400-e29b-41d4-a716-INVALID'
          ''',
          ).build()
        ];

        var collector = CodeGenerationCollector();
        StatefulAnalyzer(config, models, onErrorsCollector(collector))
            .validateAll();

        expect(collector.errors, isNotEmpty);

        var firstError = collector.errors.first as SourceSpanSeverityException;
        expect(
          firstError.message,
          'The "defaultPersist" value must be a valid UUID (e.g., \'550e8400-e29b-41d4-a716-446655440000\').',
        );
      },
    );

    test(
      'when the field is of type UUID with a malformed UUID in double quotes, then an error is generated.',
      () {
        var models = [
          ModelSourceBuilder().withYaml(
            '''
          class: Example
          table: example
          fields:
            uuidMalformed: UuidValue?, defaultPersist="550e8400-e29b-41d4-a716-INVALID"
          ''',
          ).build()
        ];

        var collector = CodeGenerationCollector();
        StatefulAnalyzer(config, models, onErrorsCollector(collector))
            .validateAll();

        expect(collector.errors, isNotEmpty);

        var firstError = collector.errors.first as SourceSpanSeverityException;
        expect(
          firstError.message,
          'The "defaultPersist" value must be a valid UUID (e.g., \'550e8400-e29b-41d4-a716-446655440000\').',
        );
      },
    );

    test(
      'when the field is of type UUID with a non-nullable type, then an error is generated.',
      () {
        var models = [
          ModelSourceBuilder().withYaml(
            '''
          class: Example
          table: example
          fields:
            uuidType: UuidValue, defaultPersist=random
          ''',
          ).build()
        ];

        var collector = CodeGenerationCollector();
        StatefulAnalyzer(config, models, onErrorsCollector(collector))
            .validateAll();

        expect(collector.errors, isNotEmpty);

        var error = collector.errors.first as SourceSpanSeverityException;
        expect(
          error.message,
          'When setting only the "defaultPersist" key, its type should be nullable',
        );
      },
    );

    test(
      'when the field has the "!persist" keyword, then an error is generated.',
      () {
        var models = [
          ModelSourceBuilder().withYaml(
            '''
          class: Example
          table: example
          fields:
            uuidType: UuidValue?, defaultPersist=random, !persist
          ''',
          ).build()
        ];

        var collector = CodeGenerationCollector();
        StatefulAnalyzer(config, models, onErrorsCollector(collector))
            .validateAll();

        expect(collector.errors, isNotEmpty);

        var error = collector.errors.first as SourceSpanSeverityException;
        expect(
          error.message,
          'The "defaultPersist" property is mutually exclusive with the "!persist" property.',
        );
      },
    );
  });

  test(
    'Given a class with a declared id field of type UUID with a "defaultPersist" keyword, then an error is collected',
    () {
      var models = [
        ModelSourceBuilder().withYaml(
          '''
          class: Example
          table: example
          fields:
            id: UuidValue, defaultPersist=random
          ''',
        ).build()
      ];

      var config = GeneratorConfigBuilder().withEnabledExperimentalFeatures(
        [ExperimentalFeature.changeIdType],
      ).build();

      var collector = CodeGenerationCollector();
      StatefulAnalyzer(config, models, onErrorsCollector(collector))
          .validateAll();

      expect(
        collector.errors.first.message,
        'The "defaultPersist" key is not allowed on the "id" field. '
        'Use the "default" key instead.',
      );
    },
  );
}
