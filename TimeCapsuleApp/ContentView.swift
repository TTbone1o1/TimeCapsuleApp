import SwiftUI

struct ContentView: View {
    
    @State var selection: String = "Journal Entries"
    let filterOptions: [String] = ["Journal Entries", "Capsule"]
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: 361, height: 410)
                .foregroundColor(.blue)
                .cornerRadius(40)
            
            CustomSegmentedControl(selection: $selection, options: filterOptions)
                .frame(width: 325, height: 62)
                .background(Color.black)
                .cornerRadius(51)
            
            HStack {
                Rectangle()
                    .frame(width: 140, height: 140)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(radius: 24, x: 0, y: 7)
                
                Rectangle()
                    .frame(width: 140, height: 140)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(radius: 24, x: 13, y: 7)
            }
            
            HStack {
                Rectangle()
                    .frame(width: 140, height: 140)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(radius: 24, x: 0, y: 17)
                
                Rectangle()
                    .frame(width: 140, height: 140)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(radius: 24, x: 13, y: 7)
            }
        }
        .padding()
    }
}

struct CustomSegmentedControl: View {
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selection = option
                }) {
                    Text(option)
                        .foregroundColor(selection == option ? .black : .white)
                        .frame(width: selection == option ? 141 : 100, height: selection == option ? 38 : 30)
                        .background(selection == option ? Color.white : Color.clear)
                        .cornerRadius(15)
                        .padding(4)
                }
            }
        }
        .background(Color.gray.opacity(0.3))
        .cornerRadius(25)
    }
}

#Preview {
    ContentView()
}
