//
//  ContentView.swift
//  StessUSE
//
//  Created by Vladimir Grigoryev on 05.04.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var appViewModel = AppViewModel()

    var body: some View {
        ZStack {
            TabView(selection: $appViewModel.selectedTab) {
                NavigationStack {
                    if let selectedDeck = appViewModel.selectedDeck {
                        DeckDetailView(
                            viewModel: DeckDetailViewModel(
                                deck: selectedDeck,
                                weakTopicStats: appViewModel.weakTopicStats,
                                recentResults: appViewModel.history.filter { $0.deckID == selectedDeck.id }
                            ),
                            onStartStressMode: { appViewModel.startStressMode(for: selectedDeck) },
                            onBack: appViewModel.closeDeckDetail
                        )
                    } else {
                        HomeView(
                            decks: appViewModel.decks,
                            history: appViewModel.history,
                            weakTopicStats: appViewModel.weakTopicStats,
                            onSelectDeck: appViewModel.selectDeck,
                            onCreateDeck: appViewModel.presentDeckComposer
                        )
                    }
                }
                .tabItem {
                    Label("Наборы", systemImage: "rectangle.stack.fill")
                }
                .tag(AppTab.decks)

                NavigationStack {
                    MistakesView(
                        mistakesDeck: appViewModel.latestMistakesDeck,
                        weakTopics: appViewModel.topWeakTopics,
                        onStart: appViewModel.startMistakeRecovery
                    )
                }
                .tabItem {
                    Label("Ошибки", systemImage: "arrow.trianglehead.clockwise")
                }
                .tag(AppTab.mistakes)

                NavigationStack {
                    StatisticsView(
                        totalSessions: appViewModel.totalSessionsCount,
                        totalTrainingSeconds: appViewModel.totalTrainingSeconds,
                        averageScorePercent: appViewModel.averageScorePercent,
                        strongestSubject: appViewModel.strongestSubject,
                        recentHistory: appViewModel.history,
                        weakTopics: appViewModel.topWeakTopics
                    )
                }
                .tabItem {
                    Label("Статистика", systemImage: "chart.pie.fill")
                }
                .tag(AppTab.statistics)

                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
            }
            .tint(Color(hex: "#2563EB"))

            if let result = appViewModel.latestResult,
               let deck = appViewModel.resultDeck {
                ResultsView(
                    record: result,
                    deck: deck,
                    weakTopicStats: appViewModel.weakTopicStats,
                    mistakesDeck: appViewModel.latestMistakesDeck,
                    onRetry: appViewModel.retryLastDeck,
                    onOpenMistakesTab: appViewModel.openMistakesTab,
                    onBackToLibrary: appViewModel.returnToLibrary
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }

            if let sessionViewModel = appViewModel.activeSessionViewModel {
                StressSessionView(
                    viewModel: sessionViewModel,
                    onExit: appViewModel.handleSessionExit
                )
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.92), value: appViewModel.navigationState)
        .sheet(
            isPresented: Binding(
                get: { appViewModel.isPresentingDeckComposer },
                set: { isPresented in
                    appViewModel.isPresentingDeckComposer = isPresented
                }
            )
        ) {
            NavigationStack {
                CreateDeckView(
                    viewModel: appViewModel.deckComposerViewModel,
                    onClose: appViewModel.dismissDeckComposer,
                    onSave: appViewModel.saveCustomDeck
                )
            }
            .presentationDetents([.large])
        }
    }
}

#Preview {
    ContentView()
}
