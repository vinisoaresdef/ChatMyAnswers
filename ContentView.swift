//
//  ContentView.swift
//  ChatGPT
//
//  Created by Vinicius Soares on 25/02/23.

import SwiftUI
import Combine

struct ContentView: View {
    @State var chatMessages: [ChatMessage] = []
    @State var messageText: String = ""
    let openAIService = OpenIAService() //instanciando o server
    @State var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            //Cabeçalho ==========================================
            
            HStack{
                Text("My Answers")
                    .font(.system(size: 20, weight: .light, design: .serif))
                    .italic()
                
                //Terminar sobre o botão de LIMPAR
                Button{
                    
                    
                
                } label: {
                    Text("Limpar")
                }
            }
            //Local de Texto ==========================================

            ScrollView {
   
                    LazyVStack {
                        ForEach(chatMessages, id: \.id) { message in
                            messageView(message: message)
                        }
                    }
                    
                }
            
            
            //Local de Escrita ==========================================

            HStack {
                TextField("Escreva uma mensagem", text: $messageText) {}
                    .padding()
                    .background(.gray.opacity(0.1))
                    .cornerRadius(12)
                Button {
                    sendMesssage()
                } label: {
                    Text("Enviar")
                        .foregroundColor(.white)
                        .padding()
                        .background(.black)
                        .cornerRadius(12)
                    
                }
                
            }
        }
        .padding()
    }
    
    func messageView(message: ChatMessage) -> some View {
        HStack{

            if message.sender == .me { Spacer() }
            Text(message.content)
            .foregroundColor(message.sender == .me ? .white : .black)
            .padding()
            .background(message.sender == .me ? .green : .gray.opacity(0.1 ))
            .cornerRadius(16)
            if message.sender == .gpt {Spacer() }
        }
    }
    
    func sendMesssage() {
        let myMessage = ChatMessage(id: UUID().uuidString, content: messageText, dateCreated: Date(), sender: .me)
        chatMessages.append(myMessage)
        openAIService.sendMessage(message: messageText).sink { completion in
            //Handle Errors
            
        } receiveValue: { response  in
            guard let textResponse = response.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: "\""))) else { return }
            let gptMessage = ChatMessage(id: response.id, content: textResponse, dateCreated: Date(), sender: .gpt)
            chatMessages.append(gptMessage)
        }
        .store(in: &cancellables)
        messageText = ""
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ChatMessage {
    let id: String
    let content: String
    let dateCreated: Date
    let sender: MessageSender
}

enum MessageSender {
    case me
    case gpt
}

extension ChatMessage: Equatable {
    
}
