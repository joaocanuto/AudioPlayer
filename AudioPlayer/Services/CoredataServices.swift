//
//  CoredataServices.swift
//  AudioPlayer
//
//  Created by Joao Guilherme Araujo Canuto on 04/09/23.
//

import Foundation
import CoreData

class CoreDataStack {
    let persistentContainer: NSPersistentContainer
    static let shared = CoreDataStack()

    private init() {
        persistentContainer = NSPersistentContainer(name: "AudioDB")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                print("Created")
                try context.save()
            } catch {
                print("Not Created")
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

class CoredataServices {
    func createAudio(url: String){
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let audio = Audio(context: context)
        //audio.id = UUID()
        audio.url = url
        CoreDataStack.shared.saveContext()
    }
    func fetchAudio() -> [Audio] {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Audio> = Audio.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func fetchAudioModel() -> [AudioModel] {
        let audiosClass = fetchAudio()
        var audios: [AudioModel] = []
        audiosClass.forEach {
            audios.append(AudioModel(id: $0.id ?? UUID(), url: $0.url ?? ""))
        }
        return audios
    }
    
    func deleteAll(){
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let audioClass = fetchAudio()
        audioClass.forEach { audio in
            context.delete(audio)
        }
        
    }
    
}
