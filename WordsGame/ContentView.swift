//
//  ContentView.swift
//  WordsGame
//
//  Created by Shivam Rishi on 15/07/20.
//  Copyright © 2020 shivam. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var currentWord = ""
    @State private var usedWords = [String]()
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
 
    @State private var timeRem = 60
    @State private var isActive = true
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        NavigationView
            {
                
                VStack
                    {
                        TextField("Enter new word", text: $newWord, onCommit: addNewWord )
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .padding()
                        List(usedWords, id: \.self)
                        {
                            Image(systemName: "\($0.count).circle")
                            Text($0).font(.body)
                        }
                        
                }
                .navigationBarTitle(Text(currentWord))
                    
                .navigationBarItems(trailing:
                    VStack
                        {
                            Button(action: {
                                self.newGame()
                            })
                            {
                                Text("Change Word").font(.headline).fontWeight(.bold).foregroundColor(.red)
                            }
                            Spacer()
                            HStack
                                {
                                    Text("Timer: \(timeRem)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(2)
                                        .background(
                                            Capsule()
                                                .fill().foregroundColor(.black)
                                                .opacity(0.8)
                                            
                                            
                                    )
                                    
                                    Text("Total words:- \(score)").font(.headline).fontWeight(.bold).foregroundColor(.green)
                            }
                            
                    }.onReceive(timer, perform: { (time) in
                        guard self.isActive else { return}
                        if self.timeRem > 0 {
                            self.timeRem -= 1
                        } else if self.timeRem == 0
                        {
                            self.newGame()
                            
                        }
                        
                        
                    })
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification), perform: { _ in
                            self.isActive = false
                        })
                        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification), perform: { _ in
                            self.isActive = true
                        })
                )
                    
                    
                    
                    
                    
                    .onAppear {
                        self.startGame()
                }
                .alert(isPresented: $showingError) { () -> Alert in
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
        }
    }
    
    func addNewWord()
    {
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            checkError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            checkError(title: "Word not recognized", message: "You can't just make them up")
            
            return
        }
        
        guard isReal(word: answer) else {
            checkError(title: "Word not possible", message: "That isn't a real word")
            return
        }
        
        usedWords.insert(answer, at: 0)
        score = score + 1
        newWord = ""
        
        
    }
    
    func newGame()
    {
        startGame()
        usedWords.removeAll()
        score = 0
        self.timeRem = 60
    }
    
    func startGame()
    {
        if let startWordUrl = Bundle.main.url(forResource: "start", withExtension: "txt")
        {
            
            if let startWords = try? String(contentsOf: startWordUrl)
            {
                let allWords = startWords.components(separatedBy: "\n")
                currentWord = allWords.randomElement() ?? "silkworm"
                return
            }
            
            
        }
        
        fatalError("Could not load file")
        
        
    }
    
    func isOriginal(word:String) -> Bool
    {
        return !usedWords.contains(word)
    }
    
    func isPossible(word:String) -> Bool
    {
        var tempWord = currentWord.lowercased()
        
        for letter in word
        {
            
            if let pos = tempWord.firstIndex(of: letter)
            {
                tempWord.remove(at: pos)
            } else {
                return false
            }
            
            
        }
        
        return true
    }
    
    func isReal(word:String) -> Bool
    {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func checkError(title:String,message:String)
    {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
