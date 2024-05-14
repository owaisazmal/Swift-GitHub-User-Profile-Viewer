//
//  ContentView.swift
//  callsSample
//
//  Created by Khan, Owais on 5/13/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack(spacing: 20) {
            
            AsyncImage(url: URL(string: user?.avatar_url ?? "")){ image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
                    
            }
            .frame(width: 120, height: 120)
            
            Text(user?.login ?? "Login Placeholder")
                .bold()
                .font(.title3)
            
            Text(user?.bio ?? "Bio Placeholder")
                .padding()
            
            Spacer()

        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHerror.invalidURL{
                print("Invalid URL")
            } catch GHerror.invalidData{
                print("Invalid data")
            } catch GHerror.invalidResponse{
                print("Invalid Response")
            } catch {
                print("Unexpected Error")
            }
        }
    }
    func getUser() async throws -> GitHubUser{
        let endpoint = "https://api.github.com/users/owaisazmal"
        
        guard let url = URL(string: endpoint) else {
            throw GHerror.invalidURL
        }
        
        let(data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw GHerror.invalidResponse
        }
        do{
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        }catch{
            throw GHerror.invalidData
        }
    }
}

//#Preview {
//    ContentView()
//}

struct ContentView_Previews: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
}

struct GitHubUser: Codable{
    let login: String
    let avatar_url: String
    let bio: String
    
}

enum GHerror:Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
