import Foundation
import Observation

@Observable final class ServiceContainer: @unchecked Sendable {
    let auth: any AuthService
    let database: any DatabaseService
    let realtime: any RealtimeService
    let linkShare: any LinkShareService

    init(
        auth: any AuthService,
        database: any DatabaseService,
        realtime: any RealtimeService,
        linkShare: any LinkShareService
    ) {
        self.auth = auth
        self.database = database
        self.realtime = realtime
        self.linkShare = linkShare
    }
}
