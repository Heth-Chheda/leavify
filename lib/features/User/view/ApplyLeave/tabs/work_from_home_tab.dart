import 'package:flutter/material.dart';
import 'package:leavify/features/User/components/leave_form.dart';
import 'package:leavify/features/User/viewmodel/leave_view_model.dart';

class WorkFromHomeTab extends StatelessWidget {
  final LeaveViewModel leaveViewModel;

  const WorkFromHomeTab({
    super.key,
    required this.leaveViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return LeaveForm(
      leaveViewModel: leaveViewModel,
      formType: LeaveFormType.workFromHome,
      title: 'Work From Home',
    );
  }
}