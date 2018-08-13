static NSString *const kSettingsPath = @"/var/mobile/Library/Preferences/jp.i4m1k0su.markasunreadalert.plist";
static NSString *const kBundlePath = @"/Library/Application Support/MarkasUnreadAlert/MarkasUnreadAlertBundle.bundle";

static NSBundle *bundle;
static BOOL isEnabled = NO;
static int limitMessages = 10;
static unsigned long long selectedMessages = 0;

//設定ファイルロード
static void loadPreferences() {

	NSMutableDictionary *preferences;
	//設定ファイルの有無チェック
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath: kSettingsPath]) {
		//ない場合にデフォルト設定を作成
		NSDictionary *defaultPreferences = @{
			@"sw_enable":@YES,
			@"text_limit_messages":@10
		};

		preferences = [[NSMutableDictionary alloc] initWithDictionary: defaultPreferences];
		[defaultPreferences release];

		#ifdef DEBUG
			if (![preferences writeToFile: kSettingsPath atomically: YES]) {
				 NSLog(@"ファイルの書き込みに失敗");
			}
		#else
			[preferences writeToFile: kSettingsPath atomically: YES];
		#endif
	}
	else {
			//あれば読み込み
			preferences = [[NSMutableDictionary alloc] initWithContentsOfFile: kSettingsPath];
	}
	isEnabled = preferences[@"sw_enable"] ? [preferences[@"sw_enable"] boolValue] : isEnabled;
	limitMessages = preferences[@"text_limit_messages"] ? [preferences[@"text_limit_messages"] intValue] : limitMessages;
	[preferences release];
}

//起動時の処理
%ctor {
	loadPreferences();
	bundle = [NSBundle bundleWithPath:kBundlePath];
}

%hook MailboxContentViewController
	- (void)bulkMarkInteraction:(id)arg1 selectionState:(unsigned long long)arg2 {
		selectedMessages = arg2;
		%orig;
	}

	- (void)_bulkMarkSelectionInteraction:(id)arg1 asRead:(_Bool)arg2 {
		// 全部既読にする時 選択されたメール数が少ない時
		if (!isEnabled || arg2 || selectedMessages < limitMessages) {
			%orig;
			return;
		}
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[bundle localizedStringForKey:@"ALERT_TITLE" value:@"" table:nil]
			message:@"" preferredStyle:UIAlertControllerStyleAlert];
		[alertController addAction:[UIAlertAction actionWithTitle:[bundle localizedStringForKey:@"CANCEL" value:@"" table:nil] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // キャンセルが押された時
    }]];
		[alertController addAction:[UIAlertAction actionWithTitle:[bundle localizedStringForKey:@"OK" value:@"" table:nil] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // OKが押された時
				%orig;
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
	}
%end

/*
%hook MailboxContentViewController
- (void)setShouldResetSources:(_Bool )shouldResetSources { %log; %orig; }
- (_Bool )shouldResetSources { %log; _Bool  r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)setSourceType:(unsigned long long )sourceType { %log; %orig; }
- (unsigned long long )sourceType { %log; unsigned long long  r = %orig; HBLogDebug(@" = %llu", r); return r; }
- (void)setShowRelatedMessages:(_Bool )showRelatedMessages { %log; %orig; }
- (_Bool )showRelatedMessages { %log; _Bool  r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)setMessageViewController:(MessageViewController *)messageViewController { %log; %orig; }
- (void)setTableView:(UITableView *)tableView { %log; %orig; }
- (double)_rowHeightForCurrentConfiguration { %log; double r = %orig; HBLogDebug(@" = %f", r); return r; }
- (_Bool)_wantsCompactMessageListRows { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_invalidateCachedRowHeight { %log; %orig; }
- (void)detailViewControllerConfigurationChanged:(id)arg1 { %log; %orig; }
- (void)_restorePreviewedMessageViewControllerToDetailNavigationController:(id)arg1 { %log; %orig; }
- (void)didDismissPreviewViewController:(id)arg1 committing:(_Bool)arg2 { %log; %orig; }
- (id)committedViewControllerForPreviewViewController:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)willPresentPreviewViewController:(id)arg1 forLocation:(struct CGPoint)arg2 inSourceView:(id)arg3 { %log; %orig; }
- (void)previewingContext:(id)arg1 commitViewController:(id)arg2 { %log; %orig; }
- (id)previewingContext:(id)arg1 viewControllerForLocation:(struct CGPoint)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)_titleForDestructiveAction:(unsigned long long)arg1 inTableView:(id)arg2 atIndexPath:(id)arg3 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)tableView:(id)arg1 iconForSwipeAction:(unsigned long long)arg2 atIndexPath:(id)arg3 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)tableView:(id)arg1 titleForSwipeAction:(unsigned long long)arg2 atIndexPath:(id)arg3 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)tableView:(id)arg1 swipeActionsForCellEdge:(unsigned long long)arg2 atIndexPath:(id)arg3 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)_performDestructiveSwipeAction:(unsigned long long)arg1 atIndexPath:(id)arg2 inTableView:(id)arg3 { %log; %orig; }
- (void)_performFlagToggleSwipeAction:(unsigned long long)arg1 atIndexPath:(id)arg2 inTableView:(id)arg3 { %log; %orig; }
- (void)tableView:(id)arg1 tappedSwipeAction:(unsigned long long)arg2 atIndexPath:(id)arg3 { %log; %orig; }
- (void)tableView:(id)arg1 performSwipeAction:(unsigned long long)arg2 atIndexPath:(id)arg3 { %log; %orig; }
- (void)tableView:(id)arg1 willPerformSwipeAction:(unsigned long long)arg2 atIndexPath:(id)arg3 { %log; %orig; }
- (_Bool)allowBackNavigationForSplitViewController:(id)arg1 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)setProgressUIVisible:(_Bool)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (void)scrollToMessageVisible:(id)arg1 { %log; %orig; }
- (void)handleFailureToContinueDisplayingMessage { %log; %orig; }
- (void)prepareToContinueDisplayingMessage { %log; %orig; }
- (void)_updateMailboxPositionUserActivity { %log; %orig; }
- (id)_focusedMessageAtNormalizedFocalPoint:(struct CGPoint)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)updateUserActivityState:(id)arg1 { %log; %orig; }
- (void)_initializeMailboxBrowseUserActivityWithMailboxes:(id)arg1 { %log; %orig; }
- (void)_endIgnoringUserInteractionForDraftRefresh { %log; %orig; }
- (void)_beginIgnoringUserInteractionForDraftRefresh { %log; %orig; }
- (_Bool)shouldHideWhenRotatingToPortraitOrientation { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (int)propagateChangeDownwards:(id)arg1 { %log; int r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_dumpAndReloadSourcesForMall:(id)arg1 shouldThread:(_Bool)arg2 { %log; %orig; }
- (_Bool)shouldDisplaySearchEditButtons { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)_hasSearchText { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)isSearching { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)dismissSearchResultsAnimated:(_Bool)arg1 { %log; %orig; }
- (void)didDismissSearchController:(id)arg1 { %log; %orig; }
- (void)willDismissSearchController:(id)arg1 { %log; %orig; }
- (void)presentSearchController:(id)arg1 { %log; %orig; }
- (void)willPresentSearchController:(id)arg1 { %log; %orig; }
- (id)_searchFieldFont { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)displaySearchPalette { %log; %orig; }
- (id)newSearchPalette { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (_Bool)_tableViewHostsSearchBar { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)focusSearchBarAnimated:(_Bool)arg1 { %log; %orig; }
- (void)_endBlockingBackgroundOperations { %log; %orig; }
- (void)_beginBlockingBackgroundOperations { %log; %orig; }
- (void)scrollViewDidScroll:(id)arg1 { %log; %orig; }
- (void)scrollViewDidScrollToTop:(id)arg1 { %log; %orig; }
- (void)scrollViewDidEndDecelerating:(id)arg1 { %log; %orig; }
- (void)scrollViewDidEndDragging:(id)arg1 willDecelerate:(_Bool)arg2 { %log; %orig; }
- (void)scrollViewWillBeginDragging:(id)arg1 { %log; %orig; }
- (void)selectionModel:(id)arg1 getSourceStateHasUnread:(_Bool *)arg2 hasUnflagged:(_Bool *)arg3 { %log; %orig; }
- (void)selectionModel:(id)arg1 getConversationStateAtTableIndexPath:(id)arg2 hasUnread:(_Bool *)arg3 hasUnflagged:(_Bool *)arg4 { %log; %orig; }
- (_Bool)selectionModel:(id)arg1 shouldArchiveByDefaultForTableIndexPath:(id)arg2 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)selectionModel:(id)arg1 supportsArchivingForTableIndexPath:(id)arg2 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)selectionModel:(id)arg1 deleteMovesToTrashForTableIndexPath:(id)arg2 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (id)selectionModel:(id)arg1 messageInfosAtTableIndexPath:(id)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)selectionModel:(id)arg1 messagesForMessageInfos:(id)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)selectionModel:(id)arg1 indexPathForMessageInfo:(id)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)selectionModel:(id)arg1 sourceForMessageInfo:(id)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)sourcesForSelectionModel:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)displayMessageFromSpotlight:(id)arg1 { %log; %orig; }
- (void)reconstruct { %log; %orig; }
- (void)purgeForMemoryReclamation { %log; %orig; }
- (void)didReceiveMemoryWarning { %log; %orig; }
- (void)_applicationWillUpdateDefaultImage:(id)arg1 { %log; %orig; }
- (void)_reloadPendingMessagesForMall:(id)arg1 { %log; %orig; }
- (void)_pauseReloadingMessagesForMall:(id)arg1 { %log; %orig; }
- (id)_tableViewForMall:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)_mallForTableView:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)mailboxUpdatedWithNoChanges:(id)arg1 { %log; %orig; }
- (void)miniMallMessagesAtIndexPathsChanged:(id)arg1 { %log; %orig; }
- (void)miniMallDidFinishSearch:(id)arg1 { %log; %orig; }
- (void)miniMallCurrentMessageRemoved:(id)arg1 { %log; %orig; }
- (void)miniMallMessageCountDidChange:(id)arg1 { %log; %orig; }
- (void)miniMallMessageCountWillChange:(id)arg1 { %log; %orig; }
- (void)miniMallDidLoadMessages:(id)arg1 { %log; %orig; }
- (void)miniMallGrowingMailboxesChanged:(id)arg1 { %log; %orig; }
- (void)miniMallFinishedFetch:(id)arg1 { %log; %orig; }
- (void)miniMallStartFetch:(id)arg1 { %log; %orig; }
- (void)_connectionEstablished:(id)arg1 { %log; %orig; }
- (void)setQuasiSelectedCell:(UITableViewCell *)quasiSelectedCell { %log; %orig; }
- (void)_setRowOfDisplayedMessageQuasiSelected:(_Bool)arg1 { %log; %orig; }
- (void)_deselectRowOfDisplayedMessageInTableView:(id)arg1 selectionFadeDuration:(double)arg2 { %log; %orig; }
- (void)_deselectRowOfDisplayedMessageInTableView:(id)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (void)_selectRowOfMessage:(id)arg1 inTableView:(id)arg2 scrollToVisible:(_Bool)arg3 selectionFadeDuration:(double)arg4 { %log; %orig; }
- (void)_selectRowOfDisplayedMessageInTableView:(id)arg1 scrollToVisible:(_Bool)arg2 animated:(_Bool)arg3 { %log; %orig; }
- (id)_displayedMessage { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)_ensureIndexPathVisible:(id)arg1 withTableView:(id)arg2 animated:(_Bool)arg3 { %log; %orig; }
- (_Bool)getContentOffset:(struct CGPoint *)arg1 ensuringIndexPathVisible:(id)arg2 inTableView:(id)arg3 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_updateCurrentMessageOutsideSearchResultsAnimated:(_Bool)arg1 { %log; %orig; }
- (void)_setCurrentMessageOutsideSearchResults:(_Bool)arg1 { %log; %orig; }
- (void)_selectInitialMessageIfNecessaryAndDisplayImmediately:(_Bool)arg1 withOptions:(unsigned long long)arg2 { %log; %orig; }
- (void)_reloadTableData:(id)arg1 sections:(id)arg2 { %log; %orig; }
- (void)_reloadTableData:(id)arg1 { %log; %orig; }
- (void)setRowDeletionEnabled:(_Bool)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (struct CGPoint)tableView:(id)arg1 newContentOffsetAfterUpdate:(struct CGPoint)arg2 context:(id)arg3 { %log; struct CGPoint r = %orig; return r; }
- (void)_presentAlertController:(id)arg1 fromTableView:(id)arg2 indexPath:(id)arg3 { %log; %orig; }
- (void)_showMarkMenuWithSelection:(id)arg1 inTableView:(id)arg2 { %log; %orig; }
- (void)_moreButtonTappedAtIndexPath:(id)arg1 inTableView:(id)arg2 { %log; %orig; }
- (void)_createFetchResumptionTimer { %log; %orig; }
- (void)_invalidateFetchResumptionTimerShouldFire:(_Bool)arg1 { %log; %orig; }
- (void)_resumeMalls:(id)arg1 { %log; %orig; }
- (void)_suspendMalls:(id)arg1 { %log; %orig; }
- (void)tableView:(id)arg1 didEndEditingRowAtIndexPath:(id)arg2 { %log; %orig; }
- (void)tableView:(id)arg1 willBeginEditingRowAtIndexPath:(id)arg2 { %log; %orig; }
- (void)tableView:(id)arg1 didDeselectRowAtIndexPath:(id)arg2 { %log; %orig; }
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 { %log; %orig; }
- (_Bool)tableView:(id)arg1 shouldHighlightRowAtIndexPath:(id)arg2 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (Class)_tableViewCellClass { %log; Class r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)_messageCellDeletionAnimationsDidStopForTableView:(id)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (long long)tableView:(id)arg1 editingStyleForRowAtIndexPath:(id)arg2 { %log; long long r = %orig; HBLogDebug(@" = %lld", r); return r; }
- (_Bool)tableView:(id)arg1 canEditRowAtIndexPath:(id)arg2 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2 { %log; long long r = %orig; HBLogDebug(@" = %lld", r); return r; }
- (void)updateNoContentViewForTableView:(id)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (long long)numberOfSectionsInTableView:(id)arg1 { %log; long long r = %orig; HBLogDebug(@" = %lld", r); return r; }
- (id)tableView:(id)arg1 titleForHeaderInSection:(long long)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)tableView:(id)arg1 viewForHeaderInSection:(long long)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (double)tableView:(id)arg1 heightForHeaderInSection:(long long)arg2 { %log; double r = %orig; HBLogDebug(@" = %f", r); return r; }
- (id)messagesForIndexPath:(id)arg1 inTableView:(id)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)willPerformVisibleStoreFetch:(id)arg1 { %log; %orig; }
- (id)copySourcesCurrentlyVisible { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)_displayNameChanged:(id)arg1 { %log; %orig; }
- (id)_subtitleFormatWithBadgeCount:(unsigned long long)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)_statusBarSubtitleStringWithBadgeCount:(unsigned long long)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)mf_unreadCountForDisplay { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)mf_statusBarSubtitleString { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)_updateBadgeCount { %log; %orig; }
- (void)_unreadCountChanged:(id)arg1 { %log; %orig; }
- (void)updateTitle { %log; %orig; }
- (_Bool)_isMuteThread { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)_isNotifyThread { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (id)_firstMessageSubject { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)_setBackButtonIncludesUnreadCount:(_Bool)arg1 { %log; %orig; }
- (void)_setIsThreadedMCVC:(_Bool)arg1 { %log; %orig; }
- (id)displayThreadedViewForMessage:(id)arg1 mall:(id)arg2 animate:(_Bool)arg3 includeRelatedSources:(_Bool)arg4 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)_showMessageViewingContext:(id)arg1 inMessageViewController:(id)arg2 withOptions:(unsigned long long)arg3 { %log; %orig; }
- (void)displayMessage:(id)arg1 options:(unsigned long long)arg2 animated:(_Bool)arg3 { %log; %orig; }
- (void)displayMessage:(id)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (id)_viewingContextForMessage:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)_makeSplitViewControllerShowMessageViewControllerAnimated:(_Bool)arg1 immediately:(_Bool)arg2 { %log; %orig; }
- (void)_makeSplitViewControllerShowMessageViewController { %log; %orig; }
- (id)cachedAddressCommentForAddressList:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)addressCommentForAddressList:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)myEmailAddresses { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)addressBookManager:(id)arg1 addressBookDidChange:(void *)arg2 { %log; %orig; }
- (void)addressBookPreferencesChangedForAddressBookManager:(id)arg1 { %log; %orig; }
- (void)invalidateCommentCache { %log; %orig; }
- (id)keyCommands { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)mailboxSearchKeyCommand { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)targetForAction:(SEL)arg1 withSender:(id)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (_Bool)canPerformAction:(SEL)arg1 withSender:(id)arg2 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_mailboxSearchKeyCommandInvoked:(id)arg1 { %log; %orig; }
- (void)updateSelectionAnimated:(_Bool)arg1 { %log; %orig; }
- (void)commitSpecialDeleteAnimationWithMessages:(id)arg1 deleteOrArchive:(unsigned long long)arg2 { %log; %orig; }
- (void)prepareForSpecialDeleteAnimation { %log; %orig; }
- (id)messageToSelectAfterDeletedMessages:(id)arg1 mall:(id *)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)_statusBarProgressDidHide:(id)arg1 { %log; %orig; }
- (void)selectInitialMessageWhenAvailable { %log; %orig; }
- (void)_selectInitialMessageNowWithOptions:(unsigned long long)arg1 { %log; %orig; }
- (void)selectInitialMessageASAP { %log; %orig; }
- (void)restoreDraftOrOutboxMessage:(id)arg1 { %log; %orig; }
- (void)expandThreadMessageKeyCommandInvoked { %log; %orig; }
- (void)collapseThreadKeyCommandInvoked { %log; %orig; }
- (void)pulledToRefresh:(id)arg1 { %log; %orig; }
- (void)setIsRefreshing:(_Bool )isRefreshing { %log; %orig; }
- (_Bool )isRefreshing { %log; _Bool  r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)resignPreparedForTransferOfMessages:(_Bool)arg1 { %log; %orig; }
- (void)transferMailboxPickerControllerDidFinish:(id)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (void)transferMailboxPickerController:(id)arg1 didSelectMailbox:(id)arg2 withMessages:(id)arg3 { %log; %orig; }
- (void)didDismiss:(_Bool)arg1 { %log; %orig; }
- (void)_clearIsDismissing { %log; %orig; }
- (void)willDismiss:(_Bool)arg1 { %log; %orig; }
- (_Bool)canDismiss { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)canResignFocus { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_markConversationContainingMessage:(id)arg1 shouldMute:(_Bool)arg2 { %log; %orig; }
- (void)_markConversationContainingMessage:(id)arg1 shouldNotify:(_Bool)arg2 { %log; %orig; }
- (void)_bulkMarkSelectionInteraction:(id)arg1 asJunk:(_Bool)arg2 { %log; %orig; }
- (void)_bulkMarkSelectionInteraction:(id)arg1 asFlagged:(_Bool)arg2 { %log; %orig; }
- (void)_bulkMarkSelectionInteraction:(id)arg1 asRead:(_Bool)arg2 { %log; %orig; }
- (void)bulkMarkInteraction:(id)arg1 selectionState:(unsigned long long)arg2 { %log; %orig; }
- (void)bulkMarkButtonPressed:(id)arg1 { %log; %orig; }
- (void)bulkMarkAllButtonPressed:(id)arg1 { %log; %orig; }
- (void)_finishBulkMarkWhilePausingReloadingMessagesForMall:(id)arg1 shouldPause:(_Bool)arg2 { %log; %orig; }
- (void)transferAllButtonPressed:(id)arg1 { %log; %orig; }
- (void)transferButtonPressed:(id)arg1 { %log; %orig; }
- (void)_transferMessagesWithInteraction:(id)arg1 { %log; %orig; }
- (void)_reallyDeleteMessages:(id)arg1 deleteOrArchive:(unsigned long long)arg2 { %log; %orig; }
- (void)_deleteMessagesWithInteraction:(id)arg1 { %log; %orig; }
- (void)_finishedAnimatingMessageToDeleteButton:(void *)arg1 { %log; %orig; }
- (void)_beginMessageDeletionAnimationForDeleteInteraction:(id)arg1 { %log; %orig; }
- (void)deleteAction:(id)arg1 interaction:(id)arg2 showChoices:(_Bool)arg3 { %log; %orig; }
- (void)deleteAllButtonPressed:(id)arg1 { %log; %orig; }
- (void)deleteButtonLongPressed:(id)arg1 { %log; %orig; }
- (void)deleteButtonPressed:(id)arg1 { %log; %orig; }
- (void)deleteShortcutInvoked:(id)arg1 { %log; %orig; }
- (void)editButtonClicked:(id)arg1 { %log; %orig; }
- (int)_stackViewTransferOptions { %log; int r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_cancelEditModeAnimated:(_Bool)arg1 { %log; %orig; }
- (void)_setInEditMode:(_Bool)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (_Bool)_messageMayHaveRelatedMessages:(id)arg1 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (id)supplementaryRelatedSourcesForMessage:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (_Bool)_shouldUpdateBarButtons { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)updateBarButtons { %log; %orig; }
- (void)updateNavigationBarButtons { %log; %orig; }
- (void)updateToolbarButtons { %log; %orig; }
- (void)updateCurrentEditButton { %log; %orig; }
- (void)updateToolbarButtonTitles { %log; %orig; }
- (_Bool)allowDeleteAll { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (id)currentEditButtonItem { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)markButtonItem { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)moveButtonItem { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)deleteButtonItem { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)_popoverWillBePresented:(id)arg1 { %log; %orig; }
- (void)popoverPresentationControllerDidDismissPopover:(id)arg1 { %log; %orig; }
- (void)prepareForPopoverPresentation:(id)arg1 { %log; %orig; }
- (void)_upsellOfferDidChange:(id)arg1 { %log; %orig; }
- (void)_handleMessageViewingContextReload:(id)arg1 { %log; %orig; }
- (void)_deliveryQueueProcessingStop:(id)arg1 { %log; %orig; }
- (void)_deliveryQueueProcessingStart:(id)arg1 { %log; %orig; }
- (void)_updateTableForSettingsOrTimeChange:(id)arg1 { %log; %orig; }
- (void)_focusedMessageChanged:(id)arg1 { %log; %orig; }
- (void)_changeSetHadError:(id)arg1 { %log; %orig; }
- (void)_accountsChanged:(id)arg1 { %log; %orig; }
- (_Bool)_shouldShowSpinnerAtIndexPath:(id)arg1 forTableView:(id)arg2 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_setShowingSpinner:(_Bool)arg1 inSection:(long long)arg2 forTableView:(id)arg3 { %log; %orig; }
- (_Bool)_isShowingSpinnerInAnySectionForTableView:(id)arg1 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)_isShowingSpinnerInSection:(long long)arg1 forTableView:(id)arg2 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)containsMessageOrConversation:(id)arg1 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)setShouldFadeOutSelectionOnDisappear:(_Bool)arg1 { %log; %orig; }
- (void)_popIfNecessaryWithDelay:(double)arg1 { %log; %orig; }
- (void)_popIfNecessary { %log; %orig; }
- (void)applicationWillSuspend { %log; %orig; }
- (void)applicationDidResume { %log; %orig; }
- (void)_resumeSearchControllerAnimated:(_Bool)arg1 { %log; %orig; }
- (void)_suspendSearchController { %log; %orig; }
- (void)_clearSuspendedSearchState { %log; %orig; }
- (_Bool)snapshotOnTermination { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)willMoveToParentViewController:(id)arg1 { %log; %orig; }
- (void)viewDidDisappear:(_Bool)arg1 { %log; %orig; }
- (void)viewWillDisappear:(_Bool)arg1 { %log; %orig; }
- (void)viewDidAppear:(_Bool)arg1 { %log; %orig; }
- (void)preventScrollOnNextAppear { %log; %orig; }
- (void)preventNextScrollbarFlash { %log; %orig; }
- (void)viewWillReappear:(_Bool)arg1 { %log; %orig; }
- (void)_fetchDelayedIfNecessary { %log; %orig; }
- (void)_didFinishLaunching:(id)arg1 { %log; %orig; }
- (void)viewWillFirstAppear:(_Bool)arg1 { %log; %orig; }
- (void)viewWillAppear:(_Bool)arg1 { %log; %orig; }
- (void)tickleSuggestionsService { %log; %orig; }
- (_Bool)canBecomeFirstResponder { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)statusBarProgressDidChange:(id)arg1 { %log; %orig; }
- (void)updateIsRefreshing { %log; %orig; }
- (void)_updateLandscapeThreadNavigation { %log; %orig; }
- (void)_updateUpsellOffer { %log; %orig; }
- (void)_updateStatusBarWithOurSources { %log; %orig; }
- (id)contentScrollView { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)loadView { %log; %orig; }
- (id)mf_applicationContexts { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (_Bool )viewIsVisible { %log; _Bool  r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool )isDeletingMessages { %log; _Bool  r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool )isEditableMailbox { %log; _Bool  r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)restoreContentOffset { %log; %orig; }
- (void)_removeAllSources { %log; %orig; }
- (void)_endAddingSources { %log; %orig; }
- (void)_addSource:(id)arg1 { %log; %orig; }
- (void)_beginAddingSources { %log; %orig; }
- (NSUndoManager *)undoManager { %log; NSUndoManager * r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)setMailboxes:(id)arg1 sourceType:(unsigned long long)arg2 { %log; %orig; }
- (void)setMailboxes:(id)arg1 { %log; %orig; }
- (id)mailboxes { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)sources { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)mall { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)dealloc { %log; %orig; }
- (id)init { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)initWithNibName:(id)arg1 bundle:(id)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)initWithCoder:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (NSString *)debugDescription { %log; NSString * r = %orig; HBLogDebug(@" = %@", r); return r; }
- (NSString *)description { %log; NSString * r = %orig; HBLogDebug(@" = %@", r); return r; }
- (unsigned long long )hash { %log; unsigned long long  r = %orig; HBLogDebug(@" = %llu", r); return r; }
- (Class )superclass { %log; Class  r = %orig; HBLogDebug(@" = %@", r); return r; }
%end
%hook MessageViewController
+ (_Bool)_shouldForwardViewWillTransitionToSize { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)setSourceType:(unsigned long long )sourceType { %log; %orig; }
- (unsigned long long )sourceType { %log; unsigned long long  r = %orig; HBLogDebug(@" = %llu", r); return r; }
- (void)setIsBeingPreviewed:(_Bool )isBeingPreviewed { %log; %orig; }
- (_Bool )isBeingPreviewed { %log; _Bool  r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)icsPreviewControllerWantsDismissal:(id)arg1 { %log; %orig; }
- (void)previewNewIndicatorAfterSwipeAction:(unsigned long long)arg1 { %log; %orig; }
- (id)getCurrentContext { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)saPersonAttributesFromEmails:(id)arg1 addressBook:(void *)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (_Bool)allowContextProvider:(id)arg1 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_presentAlertController:(id)arg1 fromBarButtonItem:(id)arg2 { %log; %orig; }
- (void)_popIfNecessaryAnimated:(_Bool)arg1 { %log; %orig; }
- (void)_removeStringsFromArray:(id)arg1 thatCaseInsensitiveMatchStringsInArray:(id)arg2 { %log; %orig; }
- (void)_accountsDidChange:(id)arg1 { %log; %orig; }
- (void)_fontSizeDidChange:(id)arg1 { %log; %orig; }
- (void)accessibilityLargeTextDidChange { %log; %orig; }
- (void)animationDidStop:(id)arg1 finished:(_Bool)arg2 { %log; %orig; }
- (void)messagesWereResurrectedNotification:(id)arg1 { %log; %orig; }
- (void)miniMallDidLoadMessages:(id)arg1 { %log; %orig; }
- (void)miniMallDidFinishSearch:(id)arg1 { %log; %orig; }
- (void)miniMallCurrentMessageRemoved:(id)arg1 { %log; %orig; }
- (void)miniMallGrowingMailboxesChanged:(id)arg1 { %log; %orig; }
- (void)miniMallFinishedFetch:(id)arg1 { %log; %orig; }
- (void)miniMallStartFetch:(id)arg1 { %log; %orig; }
- (void)miniMallMessageCountWillChange:(id)arg1 { %log; %orig; }
- (void)miniMallMessagesAtIndexPathsChanged:(id)arg1 { %log; %orig; }
- (void)miniMallMessageCountDidChange:(id)arg1 { %log; %orig; }
- (id)transferMailboxPickerController:(id)arg1 viewForMessage:(id)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)transferMailboxPickerControllerDidFinish:(id)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (void)transferMailboxPickerController:(id)arg1 didSelectMailbox:(id)arg2 withMessages:(id)arg3 { %log; %orig; }
- (void)transferMessages:(id)arg1 toMailbox:(id)arg2 { %log; %orig; }
- (void)messageViewingContext:(id)arg1 attachmentLoadCompleted:(id)arg2 withData:(id)arg3 { %log; %orig; }
- (void)messageViewingContextFullMessageLoadFailed:(id)arg1 { %log; %orig; }
- (void)messageViewingContextContentLoadCompleted:(id)arg1 { %log; %orig; }
- (void)messageViewingContextContentLoadWillBegin:(id)arg1 { %log; %orig; }
- (void)_updateViewingContextToMessage:(id)arg1 { %log; %orig; }
- (id)messageViewingContext { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)setInThread:(_Bool )inThread { %log; %orig; }
- (_Bool )isInThread { %log; _Bool  r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)setSearching:(_Bool )searching { %log; %orig; }
- (_Bool )searching { %log; _Bool  r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)setAllowDelete:(_Bool )allowDelete { %log; %orig; }
- (_Bool )allowDelete { %log; _Bool  r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)setMessageViewingContext:(id)arg1 options:(unsigned long long)arg2 { %log; %orig; }
- (void)_updateMessageDisplayUserActivity { %log; %orig; }
- (void)updateUserActivityState:(id)arg1 { %log; %orig; }
- (void)handleMarkupData:(id)arg1 fileName:(id)arg2 mimeType:(id)arg3 attachment:(id)arg4 { %log; %orig; }
- (void)handleMarkupError:(id)arg1 attachment:(id)arg2 { %log; %orig; }
- (void)dismissMarkupViewController { %log; %orig; }
- (void)presentMarkupViewController:(id)arg1 { %log; %orig; }
- (void)launchMarkupReplyWithAttachment:(id)arg1 { %log; %orig; }
- (void)launchMarkupReply { %log; %orig; }
- (void)markupDocument { %log; %orig; }
- (id)attachmentIcon:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (struct CGRect)markupAttachmentMaskForAttachment:(id)arg1 { %log; struct CGRect r = %orig; return r; }
- (id)markupReplacementAttachment { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (struct CGRect)markupAttachmentBoundsForAttachment:(id)arg1 { %log; struct CGRect r = %orig; return r; }
- (void)exportDocument { %log; %orig; }
- (void)downloadAndSaveAllAttachments { %log; %orig; }
- (void)saveAllAttachments { %log; %orig; }
- (id)localizedTitleForSaveAllAttachmentsAction { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (_Bool)canSaveAllAttachmentsInContext:(int)arg1 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)isAllowedToSaveAttachments { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_getNumberOfImages:(unsigned long long *)arg1 videos:(unsigned long long *)arg2 undownloaded:(unsigned long long *)arg3 { %log; %orig; }
- (void)_handleResponseAction:(unsigned long long)arg1 forMessage:(id)arg2 options:(unsigned long long)arg3 { %log; %orig; }
- (id)nextResponder { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)keyCommands { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)_scrollPage:(long long)arg1 { %log; %orig; }
- (void)_pageKeyCommandInvoke:(id)arg1 { %log; %orig; }
- (void)_threadNavigationKeyCommandInvoked:(id)arg1 { %log; %orig; }
- (void)_navigateMessageKeyCommandInvoked:(id)arg1 { %log; %orig; }
- (void)_markReadKeyCommandInvoked:(id)arg1 { %log; %orig; }
- (void)_flagMessageKeyCommandInvoked:(id)arg1 { %log; %orig; }
- (void)_markAsJunkKeyCommandInvoked:(id)arg1 { %log; %orig; }
- (void)_composeViewDidShow:(id)arg1 { %log; %orig; }
- (void)_accessibilityButtonShapesWereEnabled:(id)arg1 { %log; %orig; }
- (void)_updateMailboxButtonWithTitle:(id)arg1 { %log; %orig; }
- (id)_arrowControlsView { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)arrowControlsView:(id)arg1 didTapButtonWithDirection:(int)arg2 { %log; %orig; }
- (void)_selectNextMessageWithDirection:(int)arg1 { %log; %orig; }
- (void)_updateTitleAndNavigationArrowsForDisplayMode:(long long)arg1 { %log; %orig; }
- (void)updateTitleAndNavigationArrows { %log; %orig; }
- (_Bool)isInExpandedEnvironment { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)_traitCollectionIsLargeLayout:(id)arg1 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)_hasLargeLayout { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_trashAnimationDidStop:(id)arg1 finished:(id)arg2 context:(void *)arg3 { %log; %orig; }
- (void)_startTrashAnimationWithDuration:(double)arg1 { %log; %orig; }
- (void)_commitTrashAnimation { %log; %orig; }
- (void)_prepareTrashAnimation { %log; %orig; }
- (void)_reallyDeleteVisibleMessage { %log; %orig; }
- (id)_snapshotOfCurrentMessageContentAreaLayer:(_Bool)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)beginReallyDeletingVisibleMessage { %log; %orig; }
- (void)_endIgnoringInteractionEventsForMessageRemovalAnimation { %log; %orig; }
- (void)_beginIgnoringInteractionEventsForMessageRemovalAnimation { %log; %orig; }
- (NSUndoManager *)undoManager { %log; NSUndoManager * r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)saveHTMLString:(id)arg1 { %log; %orig; }
- (void)_markConversationContainingMessage:(id)arg1 shouldMute:(_Bool)arg2 { %log; %orig; }
- (void)_markConversationContainingMessage:(id)arg1 shouldNotify:(_Bool)arg2 { %log; %orig; }
- (_Bool)canPerformAction:(SEL)arg1 withSender:(id)arg2 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_markMessage:(id)arg1 asJunk:(_Bool)arg2 popIfNecessary:(_Bool)arg3 { %log; %orig; }
- (void)markMessageAsUnflagged:(id)arg1 { %log; %orig; }
- (void)markMessageAsFlagged:(id)arg1 { %log; %orig; }
- (void)markMessageAsRead:(id)arg1 { %log; %orig; }
- (void)markMessageAsUnread:(id)arg1 { %log; %orig; }
- (void)replyShortcutInvoked:(id)arg1 { %log; %orig; }
- (void)deleteShortcutInvoked:(id)arg1 { %log; %orig; }
- (void)replyButtonClicked:(id)arg1 { %log; %orig; }
- (void)deleteButtonAction:(id)arg1 showChoices:(_Bool)arg2 { %log; %orig; }
- (void)deleteButtonLongPressed:(id)arg1 { %log; %orig; }
- (void)deleteButtonClicked:(id)arg1 { %log; %orig; }
- (void)transferCancelButtonClicked:(id)arg1 { %log; %orig; }
- (void)transferButtonClicked:(id)arg1 { %log; %orig; }
- (id)_selectedMessages { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)markButtonClicked:(id)arg1 { %log; %orig; }
- (void)_toggleReadFlagForMessage:(id)arg1 { %log; %orig; }
- (void)_toggleFlagForMessage:(id)arg1 { %log; %orig; }
- (void)_updateToolbarButtonsForTraitCollection:(id)arg1 displayMode:(long long)arg2 animated:(_Bool)arg3 force:(_Bool)arg4 { %log; %orig; }
- (void)_updateToolbarButtonsForTraitCollection:(id)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (id)_separatorWithWidth:(double)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)splitViewControllerWillChangeToDisplayMode:(long long)arg1 { %log; %orig; }
- (void)updateToolbarButtonsAnimated:(_Bool)arg1 { %log; %orig; }
- (_Bool )isInCombinedInbox { %log; _Bool  r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)updateMailboxInfo { %log; %orig; }
- (id)additionalActivitiesForDocumentInteractionController:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)excludedActivityTypesForDocumentInteractionController:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (_Bool)shouldBlockRemoteImagesInPreviewForDocumentInteractionController:(id)arg1 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (id)documentInteractionControllerTransitionImageForPreview:(id)arg1 contentRect:(struct CGRect *)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)documentInteractionControllerViewForPreview:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (struct CGRect)documentInteractionControllerRectForPreview:(id)arg1 { %log; struct CGRect r = %orig; return r; }
- (id)documentInteractionControllerURLOfDirectoryForUnzippedDocument:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)documentInteractionControllerViewControllerForPreview:(id)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)documentInteractionControllerDidEndPreview:(id)arg1 { %log; %orig; }
- (void)documentInteractionControllerWillBeginPreview:(id)arg1 { %log; %orig; }
- (void)documentInteractionControllerDidDismissOpenInMenu:(id)arg1 { %log; %orig; }
- (void)documentInteractionControllerWillPresentOpenInMenu:(id)arg1 { %log; %orig; }
- (void)documentInteractionControllerDidDismissOptionsMenu:(id)arg1 { %log; %orig; }
- (void)documentInteractionControllerWillPresentOptionsMenu:(id)arg1 { %log; %orig; }
- (void)refreshCertificateViewControllerStatus { %log; %orig; }
- (void)installCertificateWithTrustException:(_Bool)arg1 { %log; %orig; }
- (void)performCertificateActionInstall { %log; %orig; }
- (void)performCertificateActionTrustAndInstall { %log; %orig; }
- (void)performCertificateActionRemove { %log; %orig; }
- (void)updateCertificateAction { %log; %orig; }
- (_Bool)_certificateIsStoredInKeychain { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_certificateControllerDidFinish { %log; %orig; }
- (void)_showCertificate:(id)arg1 { %log; %orig; }
- (void)_addVIPButtonToController:(id)arg1 { %log; %orig; }
- (void)_addVIP:(id)arg1 { %log; %orig; }
- (void)_removeVIP:(id)arg1 { %log; %orig; }
- (void)_preferredContentSizeDidChange:(id)arg1 { %log; %orig; }
- (void)_relayoutHeaderView { %log; %orig; }
- (void)_updatePersonCard { %log; %orig; }
- (void)_trustDidChange { %log; %orig; }
- (void)_removeTrustException:(id)arg1 { %log; %orig; }
- (void)_addTrustException:(id)arg1 { %log; %orig; }
- (void)_configureSecureMIMEPersonHeaderView:(id)arg1 withButtonFactory:(id)arg2 { %log; %orig; }
- (void)_setupHeaderForContactCardViewController:(id)arg1 { %log; %orig; }
- (_Bool)_shouldShowContactHeaderForCurrentMessageViewingContext { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (id)_newPersonViewControllerForPerson:(void *)arg1 emailIdentifier:(int)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)displayViewController:(id)arg1 fromAtom:(id)arg2 allowsEditing:(_Bool)arg3 animated:(_Bool)arg4 { %log; %orig; }
- (void)_showContactCardForAddressAtom:(id)arg1 sender:(_Bool)arg2 { %log; %orig; }
- (void)showCardForRecipientAtom:(id)arg1 { %log; %orig; }
- (void)showCardForSenderAtom:(id)arg1 { %log; %orig; }
- (_Bool)contactViewController:(id)arg1 shouldPerformDefaultActionForContactProperty:(id)arg2 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)contactViewController:(id)arg1 didCompleteWithContact:(id)arg2 { %log; %orig; }
- (_Bool)unknownPersonViewController:(id)arg1 shouldPerformDefaultActionForPerson:(void *)arg2 property:(int)arg3 identifier:(int)arg4 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)unknownPersonViewController:(id)arg1 didResolveToPerson:(void *)arg2 { %log; %orig; }
- (void)personViewController:(id)arg1 willSetEditing:(_Bool)arg2 animated:(_Bool)arg3 { %log; %orig; }
- (_Bool)personViewController:(id)arg1 shouldPerformDefaultActionForPerson:(void *)arg2 property:(int)arg3 identifier:(int)arg4 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)eventViewControllerShouldAlwaysShowNavBar:(id)arg1 { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)eventViewController:(id)arg1 didCompleteWithAction:(long long)arg2 { %log; %orig; }
- (void)eventEditViewController:(id)arg1 didCompleteWithAction:(long long)arg2 { %log; %orig; }
- (void)displayMultipleCallsToAction:(id)arg1 sender:(id)arg2 { %log; %orig; }
- (void)ignoredAction:(id)arg1 sender:(id)arg2 { %log; %orig; }
- (void)confirmedAction:(id)arg1 sender:(id)arg2 { %log; %orig; }
- (void)displayEventSuggestion:(id)arg1 sender:(id)arg2 { %log; %orig; }
- (void)presentEventCancelViewForAction:(id)arg1 sender:(id)arg2 { %log; %orig; }
- (void)presentEventViewForAction:(id)arg1 sender:(id)arg2 { %log; %orig; }
- (void)presentEventEditViewForAction:(id)arg1 sender:(id)arg2 { %log; %orig; }
- (void)displayContactSuggestion:(id)arg1 sender:(id)arg2 { %log; %orig; }
- (void)reloadSuggestionsBanner { %log; %orig; }
- (void)clearSuggestionsBanner:(_Bool)arg1 { %log; %orig; }
- (void)clearSuggestionsBanner { %log; %orig; }
- (void)showMenuForSelectedAttachment:(id)arg1 { %log; %orig; }
- (id)_createDocumentInteractionControllerForAttachment:(id)arg1 withData:(id)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)previewController:(id)arg1 willMarkUpAtURL:(id)arg2 { %log; %orig; }
- (void)showSelectedAttachment:(id)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (void)showSelectedAttachment:(id)arg1 { %log; %orig; }
- (id)topMessageViewController { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)didReceiveMemoryWarning { %log; %orig; }
- (void)_purgeMessageLayer { %log; %orig; }
- (void)_meetingInformationInvalidNote:(id)arg1 { %log; %orig; }
- (void)_cleanUpPresentedPopover:(id)arg1 { %log; %orig; }
- (struct UIEdgeInsets)originalInsetsForMessageView { %log; struct UIEdgeInsets r = %orig; return r; }
- (void)endedDraggingMessageView { %log; %orig; }
- (void)dismissPresentedViewController:(id)arg1 { %log; %orig; }
- (void)showModalViewController:(id)arg1 fromView:(id)arg2 sourceRect:(struct CGRect)arg3 animated:(_Bool)arg4 { %log; %orig; }
- (id)presentedControllerDoneButtonItem { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)presentationController:(id)arg1 willPresentWithAdaptiveStyle:(long long)arg2 transitionCoordinator:(id)arg3 { %log; %orig; }
- (void)popoverPresentationControllerDidDismissPopover:(id)arg1 { %log; %orig; }
- (id)composeView { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)messageContentAreaLayer { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)currentMessage { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)displayMessage:(id)arg1 immediately:(_Bool)arg2 { %log; %orig; }
- (void)_displayMessageWithViewingContext:(id)arg1 options:(unsigned long long)arg2 { %log; %orig; }
- (void)_messageDisplayDidFinish { %log; %orig; }
- (void)messageViewingContextMessageAnalysisCompleted:(id)arg1 { %log; %orig; }
- (void)_addBannersForMessage:(id)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (_Bool)isSuggestionsLoggingEnabled { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)dataDetectorsDidFinishURLification:(id)arg1 { %log; %orig; }
- (void)_contentAnalysisDidTimeout { %log; %orig; }
- (void)messageContentAreaLayerDidDraw:(id)arg1 { %log; %orig; }
- (void)_flushMessageLayerBuffer { %log; %orig; }
- (void)_prepareMessageLayerBuffer { %log; %orig; }
- (id)_hostingViewController { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)viewWillTransitionToSize:(struct CGSize)arg1 withTransitionCoordinator:(id)arg2 { %log; %orig; }
- (void)_redisplayCurrentAttachmentWithTransitionCoordinator:(id)arg1 { %log; %orig; }
- (void)applicationSceneController:(id)arg1 willTransitionToTraitCollection:(id)arg2 withTransitionCoordinator:(id)arg3 { %log; %orig; }
- (void)traitCollectionDidChange:(id)arg1 { %log; %orig; }
- (id)mailboxContentViewController { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (_Bool )isDisplayingDraft { %log; _Bool  r = %orig; HBLogDebug(@" = %d", r); return r; }
- (id)passthroughViews { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)unreadCountChanged:(id)arg1 { %log; %orig; }
- (void)_applicationSuspended:(id)arg1 { %log; %orig; }
- (void)applicationDidResume { %log; %orig; }
- (void)applicationWillSuspend { %log; %orig; }
- (void)setContentAreaNeedsRefold { %log; %orig; }
- (void)setLandscapeThreadNavigationEnabled:(_Bool)arg1 animated:(_Bool)arg2 { %log; %orig; }
- (void)_suspendView { %log; %orig; }
- (void)suspendViewAfterDelay { %log; %orig; }
- (void)resumeView { %log; %orig; }
- (void)viewWillDisappear:(_Bool)arg1 { %log; %orig; }
- (void)_suspend { %log; %orig; }
- (void)viewDidDisappear:(_Bool)arg1 { %log; %orig; }
- (void)viewDidAppear:(_Bool)arg1 { %log; %orig; }
- (void)willBecomeTopViewController { %log; %orig; }
- (id)_previewActionForSwipeAction:(unsigned long long)arg1 withMessage:(id)arg2 forSwipe:(_Bool)arg3 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)_previewActionsForSwipeActions:(id)arg1 excludingSwipeActions:(id)arg2 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)trailingPreviewAction { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)leadingPreviewAction { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)previewActionItems { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)viewWillAppear:(_Bool)arg1 { %log; %orig; }
- (id)mf_applicationContexts { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (void)_applicationWillUpdateDefaultImage:(id)arg1 { %log; %orig; }
- (void)reconstruct { %log; %orig; }
- (void)purgeForMemoryReclamation { %log; %orig; }
- (void)loadView { %log; %orig; }
- (void)_redisplayMessageIfNecessary { %log; %orig; }
- (_Bool)canBecomeFirstResponder { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (_Bool)usePadDisplayStyle { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (void)_clearController { %log; %orig; }
- (void)dealloc { %log; %orig; }
- (id)initWithDisplayStyle:(int)arg1 { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (id)init { %log; id r = %orig; HBLogDebug(@" = %@", r); return r; }
- (_Bool)_isSharedController { %log; _Bool r = %orig; HBLogDebug(@" = %d", r); return r; }
- (NSString *)debugDescription { %log; NSString * r = %orig; HBLogDebug(@" = %@", r); return r; }
- (NSString *)description { %log; NSString * r = %orig; HBLogDebug(@" = %@", r); return r; }
- (unsigned long long )hash { %log; unsigned long long  r = %orig; HBLogDebug(@" = %llu", r); return r; }
%end
*/
