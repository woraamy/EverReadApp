import SwiftUI

struct ReadGoalCard: View {
    var yearGoalValue:Int = 29
    var monthGoalValue:Int = 50
    @State var yearGoalTotal:Int = 0
    @State var monthGoalTotal:Int = 0
    @State var showYearlyDialog:Bool = false
    @State var showMonthlyDialog:Bool = false
    var body: some View {
        VStack(alignment: .leading){
            Text("Reading Goals").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            HStack{
                // Yearly Goal
                Button(action: {
                    showYearlyDialog = true
                }){
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "calendar")
                            Text("Yearly Goal")
                        }
                        Text("7").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold()
                        HStack{
                            Text("Of \(yearGoalTotal) books").font(.caption)
                            Spacer()
                            Text("\(yearGoalValue) %").font(.subheadline).bold()
                        }
                        ZStack(alignment: .leading) {
                            Capsule()
                                .frame(height: 10)
                                .foregroundColor(.gray.opacity(0.2))
                            Capsule()
                                .frame(width: CGFloat(yearGoalValue) * 150 * 0.01, height: 10)
                                .foregroundColor(.pink)
                        }
                    }.padding().frame(width: 175,alignment: .leading).background(Color.redPink).clipShape(RoundedRectangle(cornerRadius: 10))
                }.foregroundColor(.black)
                //Monthly Goal
                Button(action: {
                    showMonthlyDialog = true
                }){
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "book.circle")
                            Text("Monthly Goal")
                        }
                        Text("1").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold()
                        HStack{
                            Text("Of \(monthGoalTotal) books").font(.caption)
                            Spacer()
                            Text("\(monthGoalValue)%").font(.subheadline).bold()
                        }
                        ZStack(alignment: .leading) {
                            Capsule()
                                .frame(height: 10)
                                .foregroundColor(.gray.opacity(0.2))
                            Capsule()
                                .frame(width: CGFloat(monthGoalValue) * 150 * 0.01 , height: 10)
                                .foregroundColor(.pink)
                        }
                    }.padding().frame(width: 175,alignment: .leading).background(Color.redPink).clipShape(RoundedRectangle(cornerRadius: 10))
                }.foregroundColor(.black)
            }.sheet(isPresented: $showYearlyDialog) {
                SetYearlytGoalView(goal:$yearGoalTotal)
            }.sheet(isPresented: $showMonthlyDialog) {
                SetMonthlytGoalView(goal:$monthGoalTotal)
            }        }
    }
}

struct SetYearlytGoalView: View {
    @Binding var goal: Int
    @Environment(\.dismiss) var dismiss
    var body: some View {
            ZStack(){
                LinearGradient(
                    gradient: Gradient(colors: [Color.pink.opacity(0.3), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                {
                    Text("Set Yearly Goal")
                            .font(.title)
                            .bold().padding()
                    Text("Set the number of books you want to read this year!")
                    TextField("Books", value: $goal, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle()).multilineTextAlignment(.center).padding().onSubmit {
                            dismiss()
                        }
                        .frame(width: 200)
                }
                .padding()
                
            }
        
    }
}

struct SetMonthlytGoalView: View {
    @Binding var goal: Int
    @Environment(\.dismiss) var dismiss
    var body: some View {
            ZStack(){
                LinearGradient(
                    gradient: Gradient(colors: [Color.pink.opacity(0.3), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                {
                    Text("Set Monthly Goal")
                            .font(.title)
                            .bold().padding()
                    Text("Set the number of books you want to read this month!")
                    TextField("Books", value: $goal, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle()).multilineTextAlignment(.center).padding().onSubmit {
                            dismiss()
                        }
                        .frame(width: 200)
                }
                .padding()
                
            }
        
    }
}
#Preview {
    ReadGoalCard()
}
