
import SwiftUI

enum ShelfTab{
    case Current
    case Want
    case Finish
}


struct MyShelfView: View{
    @State private var selectedTab: ShelfTab = .Current
    var body: some View {
        ZStack{
            Color.softWhitePink.ignoresSafeArea()
            VStack(alignment: .leading){
                Text("My Shelves").font(.title)
                
                HStack {
                    TabButton(label: "Reading", tab: ShelfTab.Current, selectedTab: $selectedTab)
                    TabButton(label: "Wish List", tab: ShelfTab.Want, selectedTab: $selectedTab)
                    TabButton(label: "Read", tab: ShelfTab.Finish, selectedTab: $selectedTab)
                }.frame(width:350 , height: 50)
                    .background(Color.redPink)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 10)
                
                Group {
                    switch selectedTab {
                    case .Current:
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 30), count: 3), spacing: 20) {
                                ForEach(1..<8) { i in
                                    BookCard(status: "current", img: "BookImg", name: "Babel \(i)", author: "R. F. Kuang", progress: 50)
                                      
                                }
                            }
                            .padding(.horizontal)
                        }

                    case .Want:
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 30), count: 3), spacing: 20) {
                                ForEach(1..<8) { i in
                                    BookCard(status: "want", img: "BookImg", name: "Babel \(i)", author: "R. F. Kuang", progress: 50)
                                      
                                }
                            }
                            .padding(.horizontal)
                        }
                    case .Finish:
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 30), count: 3), spacing: 20) {
                                ForEach(1..<8) { i in
                                    BookCard(status: "finish", img: "BookImg", name: "Babel \(i)", author: "R. F. Kuang", progress: 50)
                                      
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }.padding(30).frame(maxWidth:.infinity,maxHeight: .infinity, alignment: .topLeading)
            
        }
    }
}

#Preview {
    MyShelfView()
}
