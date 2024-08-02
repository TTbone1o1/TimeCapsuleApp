//
//  Timecap.swift
//  TimeCapsuleApp
//
//  Created by Abraham May on 8/2/24.
//

import SwiftUI

struct Timecap: View {
    var body: some View {
        Text("Timecap")
            .font(.system(size: 39))
            .fontWeight(.semibold)
            
        Text("only one photo a day.")
            .font(.system(size: 22))
            .foregroundColor(.gray)
    }
}

#Preview {
    Timecap()
}
