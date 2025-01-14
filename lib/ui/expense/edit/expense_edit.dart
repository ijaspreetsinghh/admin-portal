import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/ui/app/app_border.dart';
import 'package:invoiceninja_flutter/ui/expense/edit/expense_edit_desktop.dart';
import 'package:invoiceninja_flutter/ui/expense/edit/expense_edit_details.dart';
import 'package:invoiceninja_flutter/ui/expense/edit/expense_edit_notes.dart';
import 'package:invoiceninja_flutter/ui/expense/edit/expense_edit_settings.dart';
import 'package:invoiceninja_flutter/ui/expense/edit/expense_edit_vm.dart';
import 'package:invoiceninja_flutter/ui/app/edit_scaffold.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:invoiceninja_flutter/utils/platforms.dart';

class ExpenseEdit extends StatefulWidget {
  const ExpenseEdit({
    Key key,
    @required this.viewModel,
  }) : super(key: key);

  final ExpenseEditVM viewModel;

  @override
  _ExpenseEditState createState() => _ExpenseEditState();
}

class _ExpenseEditState extends State<ExpenseEdit>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  static final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(debugLabel: '_expenseEdit');

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final viewModel = widget.viewModel;
    final expense = viewModel.expense;
    final state = viewModel.state;
    final store = StoreProvider.of<AppState>(context);
    final prefState = state.prefState;
    final isFullscreen = prefState.isEditorFullScreen(EntityType.expense);

    return EditScaffold(
      isFullscreen: isFullscreen,
      entity: expense,
      title: expense.isNew ? localization.newExpense : localization.editExpense,
      onCancelPressed: (context) => viewModel.onCancelPressed(context),
      onSavePressed: (context) {
        final bool isValid = _formKey.currentState.validate();

        /*
        setState(() {
          autoValidate = !isValid ?? false;
        })
         */

        if (!isValid) {
          return;
        }

        viewModel.onSavePressed(context);
      },
      appBarBottom: TabBar(
        controller: _controller,
        //isScrollable: true,
        tabs: [
          Tab(
            text: localization.details,
          ),
          Tab(
            text: localization.notes,
          ),
          Tab(
            text: localization.settings,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: isFullscreen
            ? ExpenseEditDesktop(
                viewModel: viewModel,
                key: ValueKey(viewModel.expense.id),
              )
            : TabBarView(
                key: ValueKey(viewModel.expense.id),
                controller: _controller,
                children: <Widget>[
                  ExpenseEditDetails(
                    viewModel: widget.viewModel,
                  ),
                  ExpenseEditNotes(
                    viewModel: widget.viewModel,
                  ),
                  ExpenseEditSettings(
                    viewModel: widget.viewModel,
                  ),
                ],
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Theme.of(context).cardColor,
        shape: CircularNotchedRectangle(),
        child: SizedBox(
          height: kTopBottomBarHeight,
          child: AppBorder(
            isTop: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDesktop(context))
                  Tooltip(
                    message: isFullscreen
                        ? localization.sidebarEditor
                        : localization.fullscreenEditor,
                    child: InkWell(
                      onTap: () => store
                          .dispatch(ToggleEditorLayout(EntityType.expense)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(isFullscreen
                            ? Icons.chevron_right
                            : Icons.chevron_left),
                      ),
                    ),
                  ),
                AppBorder(
                  isLeft: isDesktop(context),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          localization.expenseTotal +
                              ': ' +
                              formatNumber(expense.grossAmount, context,
                                  currencyId: expense.currencyId),
                          style: TextStyle(
                            color: viewModel.state.prefState.enableDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontSize: 20.0,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
