//
//  SumaryCard.swift
//  EverRead
//
//  Created by user269706 on 4/20/25.
//

import SwiftUI

struct SummaryCard: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("Reading Summary").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            Text("Your lifetime reading statistics").foregroundColor(.pinkGray)
            VStack(alignment: .leading){
                HStack{
                    VStack(alignment: .leading){
                        Text("Total Books Read")
                        Text("42").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().padding(2)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading){
                        Text("Page Read")
                        Text("12,458").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().padding(2)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
                    HStack{
                        VStack(alignment: .leading){
                            Text("Average Rating")
                            Text("4.2").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().padding(2)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        VStack(alignment: .leading){
                            Text("Reading Streak")
                            Text("8 Days").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).bold().padding(2)
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
    SummaryCard()
}
