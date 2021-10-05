//
//  ContentView.swift
//  iExpense
//
//  Created by Luke Inger on 01/10/2021.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Int
}

class Expenses: ObservableObject {
    @Published var items = [ExpenseItem](){
        didSet {
            let encoder = JSONEncoder()
            
            if let encoded = try? encoder.encode(items){
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init(){
        let decoder = JSONDecoder()
        
        if let items = UserDefaults.standard.data(forKey: "Items"){
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items){
                self.items = decoded
                return
            }
        }
        
        self.items = []
    }
}

struct amountViewModifier : ViewModifier {
    let amount: Int
    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundColor(amount < 10 ? .blue : amount < 30 ? .orange : .purple)
    }
}

extension View {
    func amountTextStyle(amount: Int) -> some View {
        self.modifier(amountViewModifier(amount: amount))
    }
}


struct ContentView: View {
    
    @State private var showingAddView = false
    @ObservedObject var expenses = Expenses()
    
    var body: some View {
        NavigationView{
            List {
                ForEach(expenses.items){ item in
                    HStack{
                        VStack(alignment: .leading){
                            Text(item.name)
                            Text(item.type)
                        }
                        Spacer()
                        Text("£\(item.amount)")
                            .amountTextStyle(amount: item.amount)
                    }
                }
                .onDelete(perform: removeItems)
            }
            
            .navigationBarTitle("iExpense")
            .navigationBarItems(leading: EditButton(), trailing: Button(action:{
                self.showingAddView.toggle()
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddView){
                AddView(expenses: self.expenses)
            }
        }
    }
    
    func removeItems(at offsets: IndexSet){
        expenses.items.remove(atOffsets: offsets)
    }
}

struct YourView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
