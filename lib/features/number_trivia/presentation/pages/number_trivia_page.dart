import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latihan_clean_architecture/features/number_trivia/presentation/widgets/trivia_display.dart';
import '../../../../injection_container.dart';
import '../bloc/number_trivia_bloc.dart';
import '../widgets/loading_widget.dart';
import '../widgets/message_display.dart';
import '../widgets/trivia_controls.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Trivia')),
      body: SingleChildScrollView(child: _buildBody(context)),
    );
  }

  BlocProvider<NumberTriviaBloc> _buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Top Half
            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
              if (state is Empty) {
                return const MessageDisplay(message: 'Start searching!');
              } else if (state is Loading) {
                return const LoadingWidget();
              } else if (state is Loaded) {
                return TriviaDisplay(numberTrivia: state.trivia);
              } else if (state is Error) {
                return MessageDisplay(message: state.message);
              } else {
                return Container();
              }
            }),
            const SizedBox(height: 20),
            // Bottom Half
            const TriviaControls()
          ],
        ),
      ),
    );
  }
}
