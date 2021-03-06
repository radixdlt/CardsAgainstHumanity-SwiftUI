//
//  AppDelegate.swift
//  CardsAgainstHumanity
//
//  Created by Alexander Cyon on 2020-05-21.
//  Copyright © 2020 Cyon. All rights reserved.
//

import Cocoa
import SwiftUI

extension View {
    func eraseToAny() -> AnyView {
        AnyView(self)
    }
}

public extension Identifiable where Self: RawRepresentable, ID == RawValue {
    var id: ID { rawValue }
}


// MARK: - RootContent
enum RootContent: Int, Equatable, Identifiable {
    
    case joinOrCreateGame, waitingForGameToStart, playGame
}



// MARK: - ROOT SCREEN
struct RootScreen {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var preferences: Preferences
}

// MARK: View
extension RootScreen: View {
    
    var body: some View {
        Group<AnyView> {
            if appState.rootContent == .joinOrCreateGame {
                return CreateGameScreen()
                    .eraseToAny()
            } else if appState.rootContent == .waitingForGameToStart {
                return WaitingForGameToStartScreen(
                    viewModel: WaitingForGameToStartViewModel(
                        iAmCzar: preferences.iAmCzar!,
                        apiClient: appState.update().appShould.provideAPIClient(),
                        appState: appState
                    )
                )
                    .eraseToAny()
            } else if appState.rootContent == .playGame {
                return GameScreen(
                    viewModel: GameViewModel(
                        game: appState.update().appShould.createGame(),
                        apiClient: appState.update().appShould.provideAPIClient()
                    )
                )
                .eraseToAny()
            } else {
                return Text("⚠️ Unhandled rootContent state").font(.headline).eraseToAny()
            }
        }.font(.headline)
    }
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let preferences = Preferences.default
        preferences.deleteAll()
        preferences.playerId = Player.ID.random()
        let appState = AppState(preferences: preferences)
        
         let rootScreen =  RootScreen()
                .environmentObject(preferences)
                .environmentObject(appState)
                .frame(maxHeight: .infinity)
        
        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1024, height: 2048),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: rootScreen)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

