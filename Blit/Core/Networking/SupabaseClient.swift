import Foundation
import Supabase

enum SupabaseConfig {
    static var url: URL {
        guard let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
              !urlString.isEmpty,
              urlString != "placeholder",
              let url = URL(string: urlString) else {
            #if DEBUG
            return URL(string: "https://placeholder.supabase.co")!
            #else
            preconditionFailure("SUPABASE_URL not configured in xcconfig")
            #endif
        }
        return url
    }

    static var anonKey: String {
        guard let key = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String,
              !key.isEmpty,
              key != "placeholder" else {
            #if DEBUG
            return "placeholder-key"
            #else
            preconditionFailure("SUPABASE_ANON_KEY not configured in xcconfig")
            #endif
        }
        return key
    }

    static let redirectURL = URL(string: "blit://auth-callback")!
}

let supabase = SupabaseClient(
    supabaseURL: SupabaseConfig.url,
    supabaseKey: SupabaseConfig.anonKey
)
