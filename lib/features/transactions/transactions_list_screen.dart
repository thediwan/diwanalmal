import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/theme/app_form_fields.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/layouts/master_detail_layout.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../core/responsive/responsive_content.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../database/daos/finance_dao.dart';
import '../../models/transaction_category.dart';
import '../../providers/currency_provider.dart';
import '../../providers/dashboard_refresh_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/category_service.dart';
import '../../services/lazarus_database_service.dart';
import '../../services/debt_service.dart';
import '../../services/transaction_list_service.dart';
import '../../services/transaction_service.dart';
import '../../services/transfer_service.dart';
import 'transaction_edit_screen.dart';
import 'models/transaction_list_item.dart';
import 'widgets/transaction_detail_placeholder.dart';
import 'widgets/transaction_list_filter_sheet.dart';
import 'widgets/transaction_list_tile.dart';
import '../../core/extensions/context_feedback.dart';

/// Paginated transactions list with tabs, filters, search, and grouped dates.
class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({
    super.key,
    this.initialTab,
    this.selectedTransactionId,
    this.selectedKind,
  });

  final ActivityFeedTab? initialTab;
  final String? selectedTransactionId;
  final TransactionListKind? selectedKind;

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  final _listService =
      TransactionListService(LazarusDatabaseService.instance);
  final _categoryService =
      CategoryService(LazarusDatabaseService.instance);
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  ActivityFeedFilter _filter = const ActivityFeedFilter();
  List<TransactionListItem> _items = [];
  List<TransactionCategory> _categories = [];
  String? _selectedWalletId;
  String? _selectedWalletName;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  int _page = 0;
  bool _searchVisible = false;
  String _searchQuery = '';

  DashboardRefreshProvider? _refreshProvider;

  @override
  void initState() {
    super.initState();
    if (widget.initialTab != null) {
      _filter = _filter.copyWith(tab: widget.initialTab!);
    }
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      final query = _searchController.text.trim();
      if (query == _searchQuery) return;
      _searchQuery = query;
      _reload();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshProvider = context.read<DashboardRefreshProvider>();
      _refreshProvider!.addListener(_onExternalRefresh);
      _initialize();
    });
  }

  @override
  void dispose() {
    _refreshProvider?.removeListener(_onExternalRefresh);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onExternalRefresh() {
    _reload();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }

  /// Loads the next page when the list is too short to scroll.
  void _schedulePrefetchIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_hasMore || _isLoadingMore || _isLoading) return;
      if (!_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent > 0) return;

      await _loadNextPage();
      if (mounted) _schedulePrefetchIfNeeded();
    });
  }

  bool get _showThisMonthHint =>
      _filter.thisMonthOnly &&
      _filter.dateFrom == null &&
      _filter.dateTo == null &&
      !_isLoading;

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    final currencyProvider = context.read<CurrencyProvider>();
    final walletProvider = context.read<WalletProvider>();

    if (currencyProvider.currencies.isEmpty) {
      await currencyProvider.loadCurrencies();
    }
    if (walletProvider.treasuries.isEmpty) {
      await walletProvider.loadWallets();
    }

    _categories = await _categoryService.getAllCategories();

    if (!mounted) return;
    await _reload(silent: true);
  }

  Future<void> _reload({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _isLoading = true;
        _page = 0;
      });
    } else {
      _page = 0;
    }

    final filter = _filter.copyWith(
      keyword: _searchQuery.isEmpty ? null : _searchQuery,
      clearKeyword: _searchQuery.isEmpty,
      walletId: _selectedWalletId,
      clearWalletId: _selectedWalletId == null,
    );

    try {
      final page = await _fetchPage(0, filter);
      if (!mounted) return;
      setState(() {
        _filter = filter;
        _items = page.items;
        _hasMore = page.hasMore;
        _page = 0;
        _isLoading = false;
      });
      _schedulePrefetchIfNeeded();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.showOperationError(e);
    }
  }

  Future<void> _loadNextPage() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    final nextPage = _page + 1;

    try {
      final page = await _fetchPage(nextPage, _filter);
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...page.items];
        _hasMore = page.hasMore;
        _page = nextPage;
        _isLoadingMore = false;
      });
      _schedulePrefetchIfNeeded();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      context.showOperationError(e);
    }
  }

  Future<TransactionListPage> _fetchPage(
    int page,
    ActivityFeedFilter filter,
  ) {
    final l10n = context.l10n;
    final localeName = Localizations.localeOf(context).toString();
    final baseCode =
        context.read<CurrencyProvider>().baseCurrency?.code ?? 'USD';

    return _listService.fetchPage(
      filter: filter,
      page: page,
      baseCurrencyCode: baseCode,
      l10n: l10n,
      localeName: localeName,
      deleteWindowHours:
          context.read<SettingsProvider>().transactionDeleteWindowHours,
      editWindowDays: context.read<SettingsProvider>().transactionEditWindowDays,
    );
  }


  void _openTransaction(TransactionListItem item, {required WindowSizeClass sizeClass}) {

    if (isExpandedOrWider(sizeClass)) {
      context.go(
        '/transactions/${item.id}?kind=${_kindQueryValue(item.kind)}',
      );
      return;
    }

    context.push('/transactions/${item.id}/edit', extra: item.kind);
  }

  String _kindQueryValue(TransactionListKind kind) {
    return switch (kind) {
      TransactionListKind.expense => 'expense',
      TransactionListKind.income => 'income',
      TransactionListKind.transfer => 'transfer',
      TransactionListKind.debtor => 'debtor',
      TransactionListKind.creditor => 'creditor',
      TransactionListKind.goalDeposit => 'transfer',
      TransactionListKind.goalWithdraw => 'transfer',
    };
  }

  void _redirectCompactSelectionIfNeeded(WindowSizeClass sizeClass) {
    final selectedId = widget.selectedTransactionId;
    if (selectedId == null || isExpandedOrWider(sizeClass)) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final kind = widget.selectedKind ?? TransactionListKind.expense;
      context.replace('/transactions/$selectedId/edit', extra: kind);
    });
  }

  Future<bool> _confirmDelete(TransactionListItem item) async {
    final l10n = context.l10n;
    final settings = context.read<SettingsProvider>();

    if (!item.canDelete) {
      context.showWarningFeedback(l10n.transactionDeleteExpired);
      return false;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.transactionDelete),
        content: Text(l10n.transactionDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.transactionDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return false;

    try {
      if (item.isTransfer) {
        await TransferService(LazarusDatabaseService.instance).delete(
          id: item.id,
          deleteWindowHours: settings.transactionDeleteWindowHours,
        );
      } else if (item.isDebt) {
        await DebtService(LazarusDatabaseService.instance).delete(
          transactionId: item.id,
          deleteWindowHours: settings.transactionDeleteWindowHours,
        );
      } else {
        await TransactionService(LazarusDatabaseService.instance).delete(
          id: item.id,
          deleteWindowHours: settings.transactionDeleteWindowHours,
        );
      }

      if (!mounted) return false;
      await context.read<WalletProvider>().loadWallets();
      context.read<DashboardRefreshProvider>().notifyRefresh();
      await _reload();
      if (!mounted) return false;
      context.showSuccessFeedback(l10n.transactionDeleteSuccess);
      return true;
    } catch (e) {
      if (!mounted) return false;
      context.showOperationError(e);
      return false;
    }
  }

  void _setTab(ActivityFeedTab tab) {
    setState(() {
      _filter = _filter.copyWith(tab: tab);
    });
    _reload();
  }

  void _toggleThisMonth() {
    setState(() {
      final next = !_filter.thisMonthOnly;
      _filter = _filter.copyWith(
        thisMonthOnly: next,
        clearDateFrom: next,
        clearDateTo: next,
      );
    });
    _reload();
  }

  Future<void> _openWalletPicker() async {
    final wallets = context.read<WalletProvider>().treasuries;
    final l10n = context.l10n;

    final picked = await showModalBottomSheet<_WalletPick>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.transactionsListAllWallets),
                trailing: _selectedWalletId == null
                    ? const Icon(Icons.check, color: AppColors.dashboardPrimary)
                    : null,
                onTap: () => Navigator.pop(
                  context,
                  const _WalletPick(id: null, name: null),
                ),
              ),
              for (final wallet in wallets)
                ListTile(
                  title: Text(wallet.name),
                  trailing: _selectedWalletId == wallet.id
                      ? const Icon(
                          Icons.check,
                          color: AppColors.dashboardPrimary,
                        )
                      : null,
                  onTap: () => Navigator.pop(
                    context,
                    _WalletPick(id: wallet.id, name: wallet.name),
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedWalletId = picked.id;
      _selectedWalletName = picked.name;
    });
    _reload();
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<ActivityFeedFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => TransactionListFilterSheet(
        initialFilter: _filter,
        categories: _categories,
      ),
    );

    if (result == null || !mounted) return;
    setState(() => _filter = result);
    _reload();
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) {
        _searchController.clear();
      }
    });
  }

  void _showNotes(TransactionListItem item) {
    final l10n = context.l10n;
    final notes = item.notes?.trim();
    final text = notes == null || notes.isEmpty
        ? l10n.transactionsListNoNotes
        : notes;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.transactionsListNotesTitle,
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAddTransaction() {
    context.push('/transactions/add');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final localeName = Localizations.localeOf(context).toString();
    final groups = _listService.groupByDate(
      items: _items,
      l10n: l10n,
      localeName: localeName,
    );

    return ResponsiveLayout(
      builder: (context, sizeClass) {
        _redirectCompactSelectionIfNeeded(sizeClass);
        final wide = isExpandedOrWider(sizeClass);
        final showFab = sizeClass == WindowSizeClass.compact;

        final listBody = _buildListBody(
          context,
          l10n: l10n,
          colors: colors,
          groups: groups,
          sizeClass: sizeClass,
        );

        final detailPane = widget.selectedTransactionId != null
            ? TransactionEditScreen(
                id: widget.selectedTransactionId!,
                kind: widget.selectedKind ?? TransactionListKind.expense,
              )
            : const TransactionDetailPlaceholder();

        return Scaffold(
          backgroundColor: colors.scaffoldBackground,
          appBar: AppBar(
            title: Text(
              l10n.transactionsListTitle,
              style: AppTextStyles.headingSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.dashboardPrimary,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  _searchVisible ? Icons.close : CupertinoIcons.search,
                  color: AppColors.dashboardPrimary,
                ),
                onPressed: _toggleSearch,
              ),
              if (wide)
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.dashboardPrimary,
                  ),
                  onPressed: _openAddTransaction,
                  tooltip: l10n.transactionsListAdd,
                ),
            ],
          ),
          floatingActionButton: showFab
              ? FloatingActionButton(
                  onPressed: _openAddTransaction,
                  backgroundColor: AppColors.dashboardPrimary,
                  foregroundColor: colors.onPrimary,
                  child: const Icon(Icons.add),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.startFloat,
          body: wide
              ? MasterDetailLayout(
                  master: listBody,
                  detail: detailPane,
                )
              : ResponsiveContent(
                  padding: EdgeInsetsDirectional.zero,
                  child: listBody,
                ),
        );
      },
    );
  }

  Widget _buildListBody(
    BuildContext context, {
    required AppLocalizations l10n,
    required AppThemeColors colors,
    required List<TransactionListDateGroup> groups,
    required WindowSizeClass sizeClass,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_searchVisible) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: AppFormFields.inputTextStyleOf(context),
              decoration: AppFormFields.decoration(
                context,
                hintText: l10n.transactionsListSearchHint,
                fillColor: colors.searchFieldFill,
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  color: colors.textSecondary,
                ),
              ).copyWith(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
        _TypeTabs(
          selected: _filter.tab,
          onSelected: _setTab,
        ),
        const SizedBox(height: 8),
        _FilterChips(
          thisMonthSelected: _filter.thisMonthOnly &&
              _filter.dateFrom == null &&
              _filter.dateTo == null,
          walletLabel: _selectedWalletName ?? l10n.transactionsListAllWallets,
          onFilterTap: _openFilterSheet,
          onThisMonthTap: _toggleThisMonth,
          onWalletTap: _openWalletPicker,
        ),
        if (_showThisMonthHint)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              l10n.transactionsListThisMonthHint,
              style: AppTextStyles.captionOnSurface(colors).copyWith(
                fontSize: 11,
              ),
            ),
          ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? EmptyState(
                      message: _searchQuery.isNotEmpty
                          ? l10n.transactionsListNoData
                          : l10n.transactionsListEmpty,
                      icon: _searchQuery.isNotEmpty
                          ? Icons.search_off_outlined
                          : Icons.receipt_long_outlined,
                      actionLabel: _searchQuery.isNotEmpty
                          ? null
                          : l10n.transactionsListAdd,
                      onAction: _searchQuery.isNotEmpty
                          ? null
                          : _openAddTransaction,
                    )
                  : RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: _listItemCount(groups) +
                            (_isLoadingMore ? 1 : 0) +
                            (_hasMore && !_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          final dataCount = _listItemCount(groups);

                          if (_isLoadingMore && index == dataCount) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (_hasMore &&
                              !_isLoadingMore &&
                              index == dataCount + (_isLoadingMore ? 1 : 0)) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                24,
                              ),
                              child: OutlinedButton(
                                onPressed: _loadNextPage,
                                child: Text(l10n.transactionsListLoadMore),
                              ),
                            );
                          }

                          final resolved = _resolveListIndex(groups, index);
                          if (resolved.isHeader) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                4,
                              ),
                              child: Text(
                                resolved.header!,
                                style: AppTextStyles.captionOnSurface(colors)
                                    .copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }

                          final item = resolved.item!;
                          final isSelected =
                              widget.selectedTransactionId == item.id;

                          return Column(
                            children: [
                              Material(
                                color: isSelected
                                    ? colors.accentSurface
                                    : Colors.transparent,
                                child: TransactionListTile(
                                  item: item,
                                  deleteLabel: l10n.transactionDelete,
                                  onLongPress: () => _showNotes(item),
                                  onTap: () => _openTransaction(
                                    item,
                                    sizeClass: sizeClass,
                                  ),
                                  onEdit: item.canEdit
                                      ? () => _openTransaction(
                                            item,
                                            sizeClass: sizeClass,
                                          )
                                      : null,
                                  onDismissDelete: item.canDelete
                                      ? () => _confirmDelete(item)
                                      : null,
                                ),
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: colors.divider,
                                indent: 16,
                                endIndent: 16,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  int _listItemCount(List<TransactionListDateGroup> groups) {
    var count = 0;
    for (final group in groups) {
      count += 1 + group.items.length;
    }
    return count;
  }

  _ResolvedListIndex _resolveListIndex(
    List<TransactionListDateGroup> groups,
    int index,
  ) {
    var cursor = 0;
    for (final group in groups) {
      if (cursor == index) {
        return _ResolvedListIndex.header(group.header);
      }
      cursor++;

      for (final item in group.items) {
        if (cursor == index) {
          return _ResolvedListIndex.item(item);
        }
        cursor++;
      }
    }
    return _ResolvedListIndex.header('');
  }
}

class _WalletPick {
  const _WalletPick({required this.id, required this.name});

  final String? id;
  final String? name;
}

class _ResolvedListIndex {
  const _ResolvedListIndex._({this.header, this.item});

  factory _ResolvedListIndex.header(String header) =>
      _ResolvedListIndex._(header: header);

  factory _ResolvedListIndex.item(TransactionListItem item) =>
      _ResolvedListIndex._(item: item);

  final String? header;
  final TransactionListItem? item;

  bool get isHeader => header != null;
}

class _TypeTabs extends StatelessWidget {
  const _TypeTabs({
    required this.selected,
    required this.onSelected,
  });

  final ActivityFeedTab selected;
  final ValueChanged<ActivityFeedTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _TabChip(
            label: l10n.transactionsListTabAll,
            selected: selected == ActivityFeedTab.all,
            onTap: () => onSelected(ActivityFeedTab.all),
          ),
          const SizedBox(width: 8),
          _TabChip(
            label: l10n.transactionsListTabExpenses,
            selected: selected == ActivityFeedTab.expense,
            onTap: () => onSelected(ActivityFeedTab.expense),
          ),
          const SizedBox(width: 8),
          _TabChip(
            label: l10n.transactionsListTabIncomes,
            selected: selected == ActivityFeedTab.income,
            onTap: () => onSelected(ActivityFeedTab.income),
          ),
          const SizedBox(width: 8),
          _TabChip(
            label: l10n.transactionsListTabTransfers,
            selected: selected == ActivityFeedTab.transfer,
            onTap: () => onSelected(ActivityFeedTab.transfer),
          ),
          const SizedBox(width: 8),
          _TabChip(
            label: l10n.transactionsListTabDebts,
            selected: selected == ActivityFeedTab.debt,
            onTap: () => onSelected(ActivityFeedTab.debt),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.dashboardPrimary
          : AppColors.dashboardPrimary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.dashboardPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.thisMonthSelected,
    required this.walletLabel,
    required this.onFilterTap,
    required this.onThisMonthTap,
    required this.onWalletTap,
  });

  final bool thisMonthSelected;
  final String walletLabel;
  final VoidCallback onFilterTap;
  final VoidCallback onThisMonthTap;
  final VoidCallback onWalletTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _FilterChip(
            label: l10n.transactionsListFilter,
            icon: Icons.tune,
            selected: false,
            onTap: onFilterTap,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.transactionsListThisMonth,
            selected: thisMonthSelected,
            onTap: onThisMonthTap,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: walletLabel,
            selected: walletLabel != l10n.transactionsListAllWallets,
            onTap: onWalletTap,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bg = selected ? colors.accentSurface : colors.inputFill;
    final fg = selected ? AppColors.dashboardPrimary : colors.textSecondary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
