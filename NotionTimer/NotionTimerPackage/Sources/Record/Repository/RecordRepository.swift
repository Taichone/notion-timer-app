//
//  File.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/21.
//
/*
import Foundation
import SwiftData

public enum RecordRepositoryError: Error {
    case duplicateLabel
    case taskCategoryNotFound
    case fetchRecordsFailed
    case saveRecordFailed
}

public class RecordRepository: ObservableObject {
    @Published public var records: [Record] = []
    private let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }

    public func fetchRecords() throws {
        let fetchDescriptor = FetchDescriptor<Record>()
        do {
            records = try context.fetch(fetchDescriptor)
        } catch {
            throw RecordRepositoryError.fetchRecordsFailed
        }
    }

    public func addRecord(taskCategory: TaskCategory, time: Int = 0) throws {
        guard !records.contains(where: { $0.taskCategory.name == taskCategory.name }) else {
            throw RecordRepositoryError.duplicateLabel
        }
        let newRecord = Record(taskCategory: taskCategory, time: time)
        context.insert(newRecord)
        try saveContext()
        records.append(newRecord)
    }
    
    public func renameLabel(_ taskCategory: TaskCategory, to newName: String) throws {
        guard let record = records.first(where: { $0.taskCategory.name == taskCategory.name }) else {
            throw RecordRepositoryError.taskCategoryNotFound
        }
        record.taskCategory.name = newName
        try saveContext()
    }

    private func saveContext() throws {
        do {
            try context.save()
        } catch {
            throw RecordRepositoryError.saveRecordFailed
        }
    }
}
*/
