import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/number_trivia_bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key? key,
  }) : super(key: key);

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  late String inputStr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), hintText: 'Input a Number'),
          onChanged: (value) => inputStr = value,
          onSubmitted: (_) => dispatchConcrete(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                        child: Text('Search'), onPressed: dispatchConcrete))),
            const SizedBox(width: 10),
            Expanded(
                child: SizedBox(
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.grey[300]),
                  onPressed: dispatchRandom,
                  child: const Text('Get random trivia',
                      style: TextStyle(color: Colors.black))),
            )),
          ],
        )
      ],
    );
  }

  void dispatchConcrete() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForConcreteNumber(inputStr));
    debugPrint(inputStr);
  }

  void dispatchRandom() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context).add(GetTriviaForRandomNumber());
    debugPrint(inputStr);
  }
}
