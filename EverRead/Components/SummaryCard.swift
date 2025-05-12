//
//  SumaryCard.swift
//  EverRead
//
//  Created by user269706 on 4/20/25.
//

import SwiftUI

struct SummaryCard: View {
    var totalBook : String
    var rating : String
    var page : String
    var streak : String
    var body: some View {
        VStack(alignment: .leading){
            Text("Reading Summary").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            Text("Your lifetime reading statistics").foregroundColor(.pinkGray)
            VStack(alignment: .leading){
                HStack{
                    VStack(alignment: .leading){
                        Text("Total Books Read")
                        Text("\(totalBook)").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().padding(2)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading){
                        Text("Page Read")
                        Text("\(page)").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().padding(2)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                    HStack{
                        VStack(alignment: .leading){
                            Text("Reviews")
                            Text("\(rating)").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().padding(2)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        VStack(alignment: .leading){
                            Text("Reading Streak")
                            Text("\(streak) Days").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().padding(2)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
            }.padding()
                .frame(alignment: .leading)
                .background(Color.redPink)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }.frame(width: 350, alignment: .leading)
    }
}

#Preview {
    SummaryCard(totalBook:"42", rating: "4.2", page: "12,458", streak: "8")
}
