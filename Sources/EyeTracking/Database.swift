import Foundation
import GRDB
import os.log

/// Database is a GRDB wrapper for managing a single SQLite table that stores `Session` objects.
enum Database {
    /// Path to the database. This is stored in the app's caches directory.
    private static let path: String = {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cacheURL.appendingPathComponent("eyeTracking.sqlite", isDirectory: false).absoluteString
    }()
}

// MARK: - Writing

extension Database {
    ///
    /// Private function for creating the `Session` table, if it does not yet exist.
    ///
    /// - parameter db: Call this function within a transaction and pass the transaction's db value.
    ///
    /// - Throws: Passes through any throw from GRDB.
    ///
    private static func createTables(in db: GRDB.Database) throws {
        try db.create(table: "session", ifNotExists: true) { t in
            t.column("id", .text).notNull().unique().primaryKey()
            t.column("appID", .text).notNull()
            t.column("beginTime", .double).notNull()
            t.column("deviceInfo", .text).notNull()
            t.column("endTime", .double)
            t.column("scanPath", .text).notNull()
            t.column("blendShapes", .text).notNull()
        }
    }

    ///
    /// Writes a single `Session` to the database.
    /// Will update if the `Session` already exists.
    ///
    /// - Throws: Passes through any throw from GRDB.
    ///
    static func write(_ session: Session) throws {
        let dbQueue = try DatabaseQueue(path: path)

        try dbQueue.write { db in
            try createTables(in: db)
            try session.save(db)
        }
    }

    ///
    /// Writes an array of `Session` to the database.
    /// Will update each `Session` if they already exist.
    ///
    /// - parameter sessions: An array of `Session` objects
    /// to write or update in the database.
    ///
    /// - Throws: Passes through any throw from GRDB.
    ///
    static func write(_ sessions: [Session]) throws {
        let dbQueue = try DatabaseQueue(path: path)

        try dbQueue.write { db in
            try createTables(in: db)
            try sessions.forEach { try $0.save(db) }
        }
    }
}

// MARK: - Reading

extension Database {
    ///
    /// Fetches a `Session` from the database for a given `sessionID`.
    ///
    /// - parameter sessionID: String primary key for the requested `Session`.
    ///
    static func fetch(_ sessionID: String) -> Session? {
        do {
            let dbQueue = try DatabaseQueue(path: path)

            return try dbQueue.read { db in
                return try Session.fetchOne(db, key: sessionID)
            }
        } catch {
            os_log(
                "%{public}@",
                log: Log.general,
                type: .fault,
                "⛔️ Fetching sessionID \(sessionID) from database failed with error: \(error.localizedDescription)."
            )
            return nil
        }
    }

    ///
    /// Fetches all `Session`s in the database and returns them in an array.
    ///
    static func fetchAll() -> [Session]? {
        do {
            let dbQueue = try DatabaseQueue(path: path)

            return try dbQueue.read { db in
                return try Session.fetchAll(db)
            }
        } catch {
            os_log(
                "%{public}@",
                log: Log.general,
                type: .fault,
                "⛔️ Fetching sessions from database failed with error: \(error.localizedDescription)."
            )
            return nil
        }
    }
}

// MARK: - Deleting

extension Database {
    ///
    /// Delete a given `Session` from the database.
    ///
    /// - parameter session: The `Session` object you wish to delete.
    ///
    /// - Throws: Passes through any throw from GRDB.
    ///
    static func delete(_ session: Session) throws {
        let dbQueue = try DatabaseQueue(path: path)

        _ = try dbQueue.write { db in
            try session.delete(db)
        }
    }

    ///
    /// Deletes all `Session` objects from the database.
    /// Does _not_ delete the database itself.
    ///
    /// - Throws: Passes through any throw from GRDB.
    ///
    static func deleteAll() throws {
        let dbQueue = try DatabaseQueue(path: path)

        _ = try dbQueue.write { db in
            try Session.deleteAll(db)
        }
    }

    ///
    /// Delete the database and everything in it.
    ///
    /// - Throws: Passes through any throw from GRDB.
    ///
    static func deleteDatabase() throws {
        try DatabaseQueue(path: path).erase()
    }
}
