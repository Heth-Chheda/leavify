import 'package:flutter/material.dart';
import 'package:leavify/features/User/components/leave_form.dart';
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';

class ExtraDayTab extends StatelessWidget {
  final LeaveViewModel leaveViewModel;

  const ExtraDayTab({super.key, required this.leaveViewModel});

  @override
  Widget build(BuildContext context) {
    return LeaveForm(
      leaveViewModel: leaveViewModel,
      formType: LeaveFormType.extra,
      title: 'Extra Worked 🥳',
    );
  }
}
