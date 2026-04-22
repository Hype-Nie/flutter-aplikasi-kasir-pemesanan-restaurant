import 'package:flutter_bloc/flutter_bloc.dart';

import 'cashier_category_management_event.dart';
import 'cashier_category_management_state.dart';

class CashierCategoryManagementBloc extends Bloc<CashierCategoryManagementEvent, CashierCategoryManagementState> {
  CashierCategoryManagementBloc() : super(const CashierCategoryManagementState()) {
    on<CashierCategoryManagementStarted>(_onStarted);
  }

  Future<void> _onStarted(
    CashierCategoryManagementStarted event,
    Emitter<CashierCategoryManagementState> emit,
  ) async {
    emit(state.copyWith(status: CashierCategoryManagementStatus.loading));

    // TODO: Implement feature logic.
    emit(state.copyWith(status: CashierCategoryManagementStatus.success));
  }
}
