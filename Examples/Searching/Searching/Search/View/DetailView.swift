//
//  DetailView.swift
//  Searching
//
//  Created by Ethan on 4/17/25.
//

import SwiftUI

struct DetailView: View {
    private let item: String
    
    init(item: String) {
        self.item = item
    }
    
    var body: some View {
        VStack {
            Text("Detail for \(item)")
        }
        .navigationTitle(item)
    }
}
