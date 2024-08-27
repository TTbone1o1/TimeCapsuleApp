import SwiftUI

struct Profile: View {
    @State private var currentDate = Date()
    @State private var displayedMonth = Calendar.current.component(.month, from: Date())
    @State private var displayedYear = Calendar.current.component(.year, from: Date())
    @State private var isShowingSetting = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                    .frame(height: 128) // Create a spacer with a height of 128

                ZStack {
                    Circle()
                        .stroke(Color(.systemGray6), lineWidth: 6) // Stroke with width of 6 and gray color
                        .frame(width: 148, height: 148)
                    
                    Circle()
                        .frame(width: 125, height: 125)
                        .onTapGesture {
                            withAnimation {
                                isShowingSetting.toggle()
                            }
                        }
                }
                Spacer()
                    .frame(height: 20)
                Text("Abraham May")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.leading)
                    .foregroundColor(Color.primary)

                // Calendar View
                CalendarView(currentDate: $currentDate, displayedMonth: $displayedMonth, displayedYear: $displayedYear)

                Spacer() // Optional: This will center the circle vertically if more space is available
            }
            .edgesIgnoringSafeArea(.top) // Ignore the safe area to ensure spacing from the very top of the screen
            .gesture(
                DragGesture()
                    .onChanged { value in
                        print("Gesture in progress: \(value.translation.width)")
                    }
                    .onEnded { value in
                        print("Gesture ended: \(value.translation.width)")
                        if value.translation.width > 100 {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
            )
            .onTapGesture {
                // Dismiss view when tapped anywhere on the screen
                self.presentationMode.wrappedValue.dismiss()
            }

            if isShowingSetting {
                Setting(isSignedOut: .constant(false), isShowing: $isShowingSetting)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut)
                    .zIndex(1) // Make sure Setting has a higher zIndex than the Profile content
            }
        }
    }
}

struct CalendarView: View {
    @Binding var currentDate: Date
    @Binding var displayedMonth: Int
    @Binding var displayedYear: Int
    
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    
    var body: some View {
        VStack {
            // Month and Year with Arrows
            HStack {
                Button(action: {
                    changeMonth(by: -1)
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("\(monthName(for: displayedMonth)) \(displayedYear)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    changeMonth(by: 1)
                }) {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            
            // Calendar Grid
            let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth())!.count
            let firstWeekday = calendar.component(.weekday, from: firstOfMonth())
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<daysInMonth + firstWeekday - 1, id: \.self) { i in
                    if i >= firstWeekday - 1 {
                        let day = i - firstWeekday + 2
                        Text("\(day)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(day == currentDay() ? .black : .gray)
                    } else {
                        Text("")
                    }
                }
            }
        }
    }
    
    private func firstOfMonth() -> Date {
        let components = DateComponents(year: displayedYear, month: displayedMonth)
        return calendar.date(from: components)!
    }
    
    private func currentDay() -> Int {
        return calendar.component(.day, from: currentDate)
    }
    
    private func monthName(for month: Int) -> String {
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.monthSymbols[month - 1]
    }
    
    private func changeMonth(by value: Int) {
        var components = DateComponents()
        components.month = value
        if let newDate = calendar.date(byAdding: components, to: firstOfMonth()) {
            displayedMonth = calendar.component(.month, from: newDate)
            displayedYear = calendar.component(.year, from: newDate)
            currentDate = newDate
        }
    }
}

#Preview {
    Profile()
}
