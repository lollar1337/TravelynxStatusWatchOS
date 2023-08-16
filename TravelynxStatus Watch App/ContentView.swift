//
//  ContentView.swift
//  TravelynxStatus Watch App
//
//  Created by Lola Schwan on 15.08.23.
//

import SwiftUI


struct ContentView: View {
    @State private var TrainType: String = "Train Type"
    @State private var Destination: String = "Destination"
    @State private var Status: String = "Status"
    @State private var autorefresh: Bool = true
    @State private var timer: Timer?

    
    func fetchDataFromServer() {
        if let url = URL(string: "https://travelynx.de/api/v1/status/1007-397766d5-2e36-484b-8c60-e70be257c47a") {
            let session = URLSession.shared
            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                if let data = data {

                                    do {
                                        
                                        let decoder = JSONDecoder()
                                        let checkIn = try decoder.decode(CheckIn.self, from: data)
                                        
                                        if (checkIn.train.line == nil) {
                                            
                                            self.TrainType = checkIn.train.type + " " + checkIn.train.no
                                            
                                        } else {
                                            
                                            self.TrainType = checkIn.train.type + (checkIn.train.line != nil ? " " + checkIn.train.line! : "")
                                            
                                        }
                                        
                                        self.Destination = "nach "+checkIn.toStation.name
                                        
                                        if (checkIn.checkedIn == true) {
                                            
                                            self.Status = "Unterwegs mit:"
                                            
                                        } else {
                                            
                                            self.Status = "Zuletzt gesehen in:"
                                            
                                        }
                                    } catch {
                                        print("Error decoding data: \(error)")
                                    }
                            }
            }
            
            task.resume()
            
        }
        
    }

    
    var body: some View {
       
        HStack(spacing:10){
            Image(systemName: "tram.fill")
                .font(.system(size: 13))
                .foregroundColor(.indigo)
                .offset(y: -26)
            Text("Travelynx Status")
                .font(.system(size: 18))
                .fontWeight(.bold)
                .offset(y: -26)
        }
        
        VStack(alignment: .leading) {
            Text(Status)
                .font(.system(size: 12))
                .fontWeight(.regular)
                .offset(x:10 ,y:-10)
            Text(TrainType)
                .font(.system(size: 20))
                .fontWeight(.bold)
                .offset(x:10)
            Text(Destination)
                .font(.system(size: 12))
                .fontWeight(.regular)
                .offset(x:10)
            Button("Refresh") { fetchDataFromServer() }
                .offset(x: 0, y: 35)

            
        }
        
        .onAppear {
            fetchDataFromServer()
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                            fetchDataFromServer()
            }
        }
        
    }

}


struct CheckIn: Decodable {
    
    struct Location: Codable {
        let ds100: String
        let latitude: Double
        let longitude: Double
        let name: String
        let realTime: Int
        let scheduledTime: Int
        let uic: Int
    }
    
    struct Train: Codable {
        let id: String
        let line: String?
        let no: String
        let type: String
    }
    
    struct Visibility: Codable {
        let desc: String
        let level: Int
    }
    
    let actionTime: Int
    let checkedIn: Bool
    let comment: String?
    let deprecated: Bool
    let fromStation: Location
    //let intermediateStops: Array // You can replace Any with the appropriate type
    let toStation: Location
    let train: Train
    let visibility: Visibility
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
