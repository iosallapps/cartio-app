//
//  CartioApp.swift
//  Cartio
//
//  Created by Tudosoiu Vlad Stefan on 3/17/26.
//

import SwiftUI
import CoreData

@main
struct CartioApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
