import 'package:recase/recase.dart';

class RawCode {
  RawCode._();

  static String state(String name) {
    return '''
import 'package:equatable/equatable.dart';

enum ${name.pascalCase}ScreenStatus {
  initial,
  loading,
  ready,
  failure,
  ;

  bool get isLoading => this == ${name.pascalCase}ScreenStatus.loading;
}

class ${name.pascalCase}ScreenState extends Equatable {
  final ${name.pascalCase}ScreenStatus status;
  final Exception? error;

  const ${name.pascalCase}ScreenState({
    this.status = ${name.pascalCase}ScreenStatus.initial,
    this.error,
  });

  @override
  List<Object?> get props => [
    status,
    error,
  ];

  ${name.pascalCase}ScreenState copyWith({
    ${name.pascalCase}ScreenStatus? status,
    Exception? error,
  }) {
    return ${name.pascalCase}ScreenState(
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  ${name.pascalCase}ScreenState loading() {
    return copyWith(
      status: ${name.pascalCase}ScreenStatus.loading,
    );
  }

  ${name.pascalCase}ScreenState ready() {
    return copyWith(
      status: ${name.pascalCase}ScreenStatus.ready,
    );
  }

  ${name.pascalCase}ScreenState failure(
    Exception error,
  ) {
    return copyWith(
      status: ${name.pascalCase}ScreenStatus.failure,
      error: error,
    );
  }
}
''';
  }

  static String cubit(String name) {
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '${name.snakeCase}_screen_state.dart';

class ${name.pascalCase}ScreenCubit extends Cubit<${name.pascalCase}ScreenState> {
  ${name.pascalCase}ScreenCubit() : super(const ${name.pascalCase}ScreenState());
}
''';
  }

  static String screen(String name) {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/${name.snakeCase}_screen_cubit.dart';
import 'cubit/${name.snakeCase}_screen_state.dart';

class ${name.pascalCase}Screen extends StatelessWidget {
  const ${name.pascalCase}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return ${name.pascalCase}ScreenCubit();
      },
      child: const ${name.pascalCase}ScreenView(),
    );
  }
}

class ${name.pascalCase}ScreenView extends StatefulWidget {
  const ${name.pascalCase}ScreenView({super.key});

  @override
  State<${name.pascalCase}ScreenView> createState() => _${name.pascalCase}ScreenViewState();
}

class _${name.pascalCase}ScreenViewState extends State<${name.pascalCase}ScreenView> {
  late final ${name.pascalCase}ScreenCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<${name.pascalCase}ScreenCubit>();
  }

  void _listener(BuildContext context, ${name.pascalCase}ScreenState state) {
    switch (state.status) {
      case ${name.pascalCase}ScreenStatus.initial:
      case ${name.pascalCase}ScreenStatus.loading:
      case ${name.pascalCase}ScreenStatus.ready:
        break;

      case ${name.pascalCase}ScreenStatus.failure:
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<${name.pascalCase}ScreenCubit, ${name.pascalCase}ScreenState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _listener,
      child: _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('${name.titleCase}'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('${name.titleCase}'),
      ),
    );
  }
}
''';
  }
}
